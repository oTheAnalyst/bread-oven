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
                schemas = ["/home/pretender/Public/postgres-devenv/sql/ddl.sql"];
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
        packages.default = self'.packages.bread-oven;
        devShells.default = let
          bread =
            pkgs.writeShellScriptBin "bread"
            ''pgcli -h localhost -d bread'';
          sendb =
            pkgs.writeShellScriptBin "sendb"
            ''psql -h localhost -d bread'';
          redev =
            pkgs.writeShellScriptBin "redev"
            ''rm -rf .devenv && devenv up'';
          ingest =
            pkgs.writeShellScriptBin "ingest"
            ''
              cd "$(git rev-parse --show-toplevel)" && 
               duckdb < sql/ingestion.sql &&
                              echo "ingestion completed!" | cowsay'';
          etl =
            pkgs.writeShellScriptBin "etl"
            # bash
            ''
              cd "$(git rev-parse --show-toplevel)" && 
               sendb < sql/intermediate/full_table.sql &&
               sendb < sql/intermediate/clean_category.sql &&
               sendb < sql/intermediate/clean_transaction.sql &&
               sendb < sql/mart/insert_account.sql &&
               sendb < sql/mart/insert_calender.sql &&
               sendb < sql/mart/insert_transaction.sql &&
               sendb < sql/mart/insert_category.sql &&
               sendb < sql/mart/insert_fact.sql &&
               sendb < sql/mart/view_expenditures.sql &&
               sendb < sql/mart/view_net_income.sql &&
               sendb < sql/mart/view_revenue.sql &&
               sendb < sql/mart/view_transaction_type.sql &&
                              echo "ETL completed!" | cowsay'';
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
        in
          pkgs.mkShell {
            inputsFrom = [
              # Add the packages of the enabled services in the devShell
              #
              # For example: `psql` to interact with `postgres` server or `redis-cli` with `redis-server`
              config.process-compose."bread-oven".services.outputs.devShell
            ];
            packages = with pkgs; [
              # Add the process-compose app in the devShell
              sendb
              etl
              redev
              bread
              ingest
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
            shellHook = ''
              echo "Looks like you comleted the flake services new build" |
              echo "Quickstart: run 'quarto render document.qmd'" |
                cowsay
            '';
            nativeBuildInputs = [pkgs.just];
          };
      };
    };
}
