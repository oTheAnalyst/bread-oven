#!/usr/bin/env bash
set -euo pipefail

JSON_FILE="data.json"

# Use a temporary file to accumulate updates safely
TMP_FILE=$(mktemp)
cp "$JSON_FILE" "$TMP_FILE"

# Ensure temp files are cleaned up if the script exits or fails
trap 'rm -f "$TMP_FILE" "$TMP_FILE.tmp"' EXIT

for KEY in $(jq -r 'keys[]' "$JSON_FILE"); do
    echo "Checking $KEY..."
    
    URL=$(jq -r ".\"$KEY\".url" "$JSON_FILE")
    CURRENT_ETAG=$(jq -r ".\"$KEY\".etag" "$JSON_FILE")
    
    # Fetch ETag using curl, following redirects
    REMOTE_ETAG=$(curl -sIL "$URL" | grep -i '^etag:' | tail -n 1 | sed -e 's/^[Ee][Tt]ag: *//' | tr -d '"\r\n')
    
    if [ -z "$REMOTE_ETAG" ]; then
        echo "  ⚠️ Warning: No ETag returned from server for $KEY. Skipping."
        continue
    fi

    if [ "$REMOTE_ETAG" == "$CURRENT_ETAG" ]; then
        echo "  ✓ Up to date (ETag: $CURRENT_ETAG)"
    else
        echo "  ↓ Update found ($REMOTE_ETAG)! Calculating new Nix directory hash..."
        
        # 1. Update ETag but inject an empty hash into the JSON structure
        jq ".\"$KEY\".etag = \"$REMOTE_ETAG\" | .\"$KEY\".hash = \"\"" "$TMP_FILE" > "$TMP_FILE.tmp"
        mv "$TMP_FILE.tmp" "$TMP_FILE"
        
        # 2. Overwrite the real data.json immediately so Nix evaluates with the empty hash
        cp "$TMP_FILE" "$JSON_FILE"
        
        # 3. Force Nix to evaluate the fetchzip block.
        # It will fail because the hash is empty, but it will output the correct directory hash.
        # --no-link prevents creating a result symlink if it somehow succeeds.
        ERROR_OUT=$(nix build .#"$KEY" --no-link 2>&1 || true)
        
        # 4. Extract the "got:" hash from the error output
        ACTUAL_HASH=$(echo "$ERROR_OUT" | grep "got:" | awk '{print $2}')
        
        if [ -n "$ACTUAL_HASH" ]; then
            # 5. Save the correct hash back to the temp JSON file
            jq ".\"$KEY\".hash = \"$ACTUAL_HASH\"" "$TMP_FILE" > "$TMP_FILE.tmp"
            mv "$TMP_FILE.tmp" "$TMP_FILE"
            
            # Update the real file immediately so subsequent Nix builds in the loop succeed
            cp "$TMP_FILE" "$JSON_FILE"
            
            echo "  ✓ Successfully updated $KEY with new hash: $ACTUAL_HASH"
        else
            echo "  ❌ Failed to extract hash for $KEY from Nix output. Check manually."
            echo "$ERROR_OUT"
        fi
    fi
done

echo "All datasets checked and updated."
