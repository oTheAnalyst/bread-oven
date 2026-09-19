{
  description = "A demo of sqlite-web and multiple postgres services";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/x86_64-linux";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    services-flake.url = "github:juspay/services-flake";
    postgres_devenv.url = "github:oTheAnalyst/postgres_devenv";
    postgres_devenv.flake = false;
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;
      imports = [
        inputs.process-compose-flake.flakeModule
      ];
      perSystem = {
        self',
        pkgs,
        config,
        lib,
        ...
      }: {
        # `process-compose.foo` will add a flake package output called "foo".
        # Therefore, this will add a default package that you can build using
        # `nix build` and run using `nix run`.
        process-compose."bread-oven" = {config, ...}: let
          dbName = "bread";
        in {
          imports = [
            inputs.services-flake.processComposeModules.default
          ];

          services.postgres."pg1" = {
            enable = true;
            initialDatabases = [
              {
                name = dbName;
                schemas = [./fec_schema.sql];
              }
            ];
          };

          settings.processes.pgweb = let
            pgcfg = config.services.postgres.pg1;
          in {
            environment.PGWEB_DATABASE_URL = pgcfg.connectionURI {inherit dbName;};
            command = pkgs.pgweb;
            depends_on."pg1".condition = "process_healthy";
          };
          settings.processes.test = {
            command = pkgs.writeShellApplication {
              name = "pg1-test";
              runtimeInputs = [config.services.postgres.pg1.package];
              text = ''
                echo 'SELECT version();' | psql -h 127.0.0.1 ${dbName}
              '';
            };
            depends_on."pg1".condition = "process_healthy";
          };
        };
        packages = {
          oth26 = pkgs.fetchzip {
            url = "https://www.fec.gov/files/bulk-downloads/2026/oth26.zip";
            sha256 = "dRoFT0QpGJ4re1+IkKqOZvQuRcy1hMghjDlChItm5Vs=";
          };
          indiv26 = pkgs.fetchzip {
            stripRoot = false;
            url = "https://www.fec.gov/files/bulk-downloads/2026/indiv26.zip";
            sha256 = "0YR8tgSp3b36r9ys/cNRo1Z8V8I+ybUIibHIMaS8pO0=";
            postFetch = "rm -f $out/by_date/itcont_2026_invalid_dates.txt";
          };
          pass226 = pkgs.fetchzip {
            url = "https://www.fec.gov/files/bulk-downloads/2026/pas226.zip";
            sha256 = "N5Is8VnGPjsMQS4BwDU+1A1U3uUAkuAmJd43rqS5uNA=";
          };

          ingestme =
            pkgs.runCommand "ingestme" {
              nativeBuildInputs = with pkgs; [duckdb];
              #bash
            } ''
              mkdir $out
              duckdb $out/database.db -c "
              create schema stg;
              create table stg.one_commitee_to_another as select *
              from read_csv('${self'.packages.oth26}/itoth.txt',all_varchar=true);
              create table stg.individual_contributions as select *
              from read_csv('${self'.packages.indiv26}/itcont.txt');
              create table stg.individual_contributions_mega_with_invalid_date as select *
              from read_csv('${self'.packages.indiv26}/by_date/*.txt',all_varchar=true);
              create table stg.committees_to_canidates_independent_expenditures as select *
              from read_csv('${self'.packages.pass226}/itpas2.txt',all_varchar=true);
              "
            '';
        };

        packages.default = self'.packages.bread-oven;
        devShells.default = let
          myPythonPackages = ps:
            with ps; [
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
            RPostgreSQL
            dplyr
            treemap
            ggplot2
            hrbrthemes
          ];
          #  load =
          #    pkgs.writeShellScriptBin "load"
          #    ''pg_restore -h localhost -d bread -v --no-acl --no-owner ${self'.packages.sched_a}'';
          sendb =
            pkgs.writeShellScriptBin "sendb"
            ''psql -h localhost -d bread'';
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
              sendb
              nix-output-monitor
              cowsay
              postgresql
              pgcli
              sqlfluff
              duckdb
              devenv
              pkgs.texliveSmall
              ((quarto.override {
                  extraPythonPackages = myPythonPackages;
                  extraRPackages = myRPackages;
                }).overrideAttrs (oldAttrs: {
                  # Remove this overrideAttrs patch when fixed.
                  # See https://github.com/NixOS/nixpkgs/issues/519484#issuecomment-4667477454
                  postPatch =
                    (oldAttrs.postPatch or "")
                    + ''
                      substituteInPlace bin/quarto.js \
                        --replace-fail "syntax-highlighting" "highlight-style"
                    '';
                }))
              (rWrapper.override {packages = myRPackages;})
              pythonEnv
              #
              # In the devShell, run `bread-oven` to run the app
              self'.packages.bread-oven
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
                fi
              '';
            nativeBuildInputs = [pkgs.just];
          };
      };
    };
}
