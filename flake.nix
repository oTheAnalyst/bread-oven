{
  description = "A demo of sqlite-web and multiple postgres services";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
        "x86_64-darwin"
      ];
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      forEachPkgs = f: lib.genAttrs systems (system: f (mkPkgs system) system);
    in
    {
      packages = forEachPkgs (
        pkgs: system:
        let

          helper =
            name: value:
            pkgs.fetchzip {
              url = value.url;
              sha256 = value.hash;
            };

          /*
            indiv26
            postFetch = "rm -f $out/by_date/itcont_2026_invalid_dates.txt";
          */
          sourceData = builtins.fromJSON (builtins.readFile ./data.json);

          rawdata = builtins.mapAttrs helper (removeAttrs sourceData [ "indiv26" ]);

          indiv26 = pkgs.fetchzip {
            stripRoot = false;
            url = sourceData.indiv26.url;
            sha256 = sourceData.indiv26.hash;
            postFetch = "rm -f $out/by_date/itcont_2026_invalid_dates.txt";
          };
        in
        rawdata
        // {
          inherit indiv26;
        }
        // {
          ingestme =
            pkgs.runCommand "ingestme"
              {
                nativeBuildInputs = with pkgs; [ duckdb ];
              } # bash

              ''
                mkdir -p $out
                duckdb $out/database.db -c "
                create schema stg;
                create table stg.committee_master as select *
                from read_csv('${self.${system}.packages.cm26}/cm.txt',all_varchar=true,header=false);
                create table stg.candidate_summary as select *
                from read_csv('${self.${system}.packages.weball26}/weball26.txt',all_varchar=true,header=false);
                create table stg.one_commitee_to_another as select *
                from read_csv('${self.${system}.packages.oth26}/itoth.txt',all_varchar=true,header=false);
                create table stg.individual_contributions as select *
                from read_csv('${indiv26}/itcont.txt',all_varchar=true,header=false);
                create table stg.committees_to_canidates_independent_expenditures as select *
                from read_csv('${self.${system}.packages.pass226}/itpas2.txt',all_varchar=true,header=false);
                create table stg.candidate_commitee_linkage as select *
                from read_csv('${self.${system}.packages.ccl26}/ccl.txt',all_varchar=true,header=false);
                "
              '';
        }
      );

      #packages.default = self'.packages.bread-oven;
      devShells = forEachPkgs (
        pkgs: system: {
          default =
            let
              myPythonPackages =
                ps: with ps; [
                  numpy
                  dash
                  pandas
                  streamlit
                  requests
                  keyring
                ];
              pythonEnv = pkgs.python3.withPackages myPythonPackages;
              myRPackages = with pkgs.rPackages; [
                reticulate
                DBI
                duckdb
                RPostgreSQL
                dplyr
                treemap
                ggplot2
                hrbrthemes
              ];
              #  load =
              #    pkgs.writeShellScriptBin "load"
              #    ''pg_restore -h localhost -d bread -v --no-acl --no-owner ${self'.packages.sched_a}'';
              sendb = pkgs.writeShellScriptBin "sendb" "psql -h localhost -d bread";
            in
            pkgs.mkShell {
              inputsFrom = [
                # Add the packages of the enabled services in the devShell
                #
                # For example: `psql` to interact with `postgres` server or `redis-cli` with `redis-server`
                #  config.process-compose."bread-oven".services.outputs.devShell
              ];
              packages = with pkgs; [
                # Add the process-compose app in the devShell
                jq
                sendb
                nix-output-monitor
                cowsay
                positron-bin
                postgresql
                pgcli
                sqlfluff
                duckdb
                devenv
                pkgs.texliveSmall
                (
                  (quarto.override {
                    extraPythonPackages = myPythonPackages;
                    extraRPackages = myRPackages;
                  }).overrideAttrs
                  (oldAttrs: {
                    # Remove this overrideAttrs patch when fixed.
                    # See https://github.com/NixOS/nixpkgs/issues/519484#issuecomment-4667477454
                    postPatch = (oldAttrs.postPatch or "") + ''
                      substituteInPlace bin/quarto.js \
                        --replace-fail "syntax-highlighting" "highlight-style"
                    '';
                  })
                )
                (rWrapper.override { packages = myRPackages; })
                pythonEnv
                #
                # In the devShell, run `bread-oven` to run the app
              ];
              shellHook =
                #bash
                ''
                  FILE=./database.db
                  ls -l $FILE
                  echo $(pwd)
                  if [ -f "$FILE" ]; then
                          echo "your database exists" |
                                  cowsay
                  else
                  echo "database building ... please wait 5 minutes" |
                  cowsay
                  nom build .#ingestme
                  cp result/database.db .
                  chmod u+w database.db
                  duckdb database.db < ./sql/ddb_sql/intemediate/first_step.sql
                  duckdb database.db < ./sql/ddb_sql/intemediate/second_step.sql
                  duckdb database.db < ./sql/ddb_sql/mart/mart_s1.sql
                  duckdb database.db < ./sql/ddb_sql/mart/mart_s2.sql
                  duckdb database.db < ./sql/ddb_sql/mart/mart_s3.sql
                  fi
                '';
              nativeBuildInputs = [ pkgs.just ];
            };
        }
      );
    };
}
