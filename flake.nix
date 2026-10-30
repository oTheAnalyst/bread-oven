{
  description = "A reproducable database/datapipeline using duckdb";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-26_05.url = "github:nixos/nixpkgs/release-26.05";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-26_05,
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
        import (if system == "x86_64-darwin" then nixpkgs-26_05 else nixpkgs) {
          inherit system;
          config = {
            allowUnfree = true;
            allowBroken = system == "x86_64-darwin";
          };
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
                from read_csv('${self.packages.${system}.cm26}/cm.txt',all_varchar=true,header=false,ignore_errors=true);

                create table stg.candidate_summary as select *
                from read_csv('${
                  self.packages.${system}.weball26
                }/weball26.txt',all_varchar=true,header=false,ignore_errors=true);

                create table stg.one_commitee_to_another as select *
                from read_csv('${self.packages.${system}.oth26}/itoth.txt',all_varchar=true,header=false,ignore_errors=true);

                create table stg.individual_contributions as select *
                from read_csv('${indiv26}/itcont.txt',all_varchar=true,header=false,ignore_errors=true);

                create table stg.committees_to_canidates_independent_expenditures as select *
                from read_csv('${
                  self.packages.${system}.pass226
                }/itpas2.txt',all_varchar=true,header=false,ignore_errors=true);

                create table stg.candidate_commitee_linkage as select *
                from read_csv('${self.packages.${system}.ccl26}/ccl.txt',all_varchar=true,header=false,ignore_errors=true);
                "
              '';
        }
      );

      #packages.default = self'.packages.bread-oven;
      devShells = forEachPkgs (
        pkgs: system:
        let
          myPythonPackages =
            ps: with ps; [
              numpy
              pandas
              keyring
            ];

          pythonEnv = pkgs.python3.withPackages myPythonPackages;

          myRPackages = with pkgs.rPackages; [
            reticulate
            DBI
            ggplot2
          ];

          #  load =
          #    pkgs.writeShellScriptBin "load"
          #    ''pg_restore -h localhost -d bread -v --no-acl --no-owner ${self'.packages.sched_a}'';
          sendb = pkgs.writeShellScriptBin "sendb" "psql -h localhost -d bread";
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # Add the process-compose app in the devShell
              jq
              sendb
              nix-output-monitor
              cowsay
              pgcli
              sqlfluff
              duckdb
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
          };

          full-shell = pkgs.mkShell {
            packages = with pkgs; [
              positron-bin
              rPackages.duckdb
            ];
            inputsFrom = with self.devShells.${system}; [
              default
            ];
          };
        }
      );
    };
}
