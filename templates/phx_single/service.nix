{config, pkgs, lib, ...}:
with lib;
let
  cfg = config.services.<%= @app_name %>;
  release = pkgs.callPackage ./default.nix { port = cfg.port };
  release_name = "<%= @app_name %>";
  working_directory = "/home/<%= @app_name %>";
  environment = [
    "DATABASE_URL=ecto://postgres:postgres@localhost/<%= @app_name %>"
    "RELEASE_TMP='${working_directory}'"
    "SECRET_KEY_BASE=YOUR SECRET KEY BASE" 
    "RELEASE_COOKIE=YOUR COOKIE"
    ];
in
{
  options.services.<%= @app_name %> = {
    enable = mkEnableOption "<%= @app_name %> service";
    port = mkOption {
      type = types.port;
      default = 4000;
      description = "The port on which this will listen";
    };
  };

  config = mkIf cfg.enable {
    users.users.<%= @app_name %> = {
      isNormalUser = true;
      home = "/home/<%= @app_name %>";
      homeMode = "755";
    };
    systemd.services = {
      <%= @app_name %>_migration = {
        unitConfig = {
          Description = "<%= @app_name %> Migrator";
          PartOf = ["<%= @app_name %>.service"];
        };
        serviceConfig = {
          ExecStart = ''
            ${release}/bin/${release_name} eval "<%= @app_name %>.Release.migrate"
          '';
          Type = "oneshot";
          WorkingDirectory = working_directory;
          Environment = environment;
        };
      };
        
      <%= @app_name %>_seed = {
        unitConfig = {
          Description = "<%= @app_name %> Seed";
        };
        serviceConfig = {
          ExecStart = ''
            ${release}/bin/${release_name} eval "<%= @app_name %>.Release.seed"
          '';
          Type = "oneshot";
          WorkingDirectory = working_directory;
          Environment = environment;
        };
      };
        
      <%= @app_name %> = {
        wantedBy = [ "multi-user.target" ];
        enable = true;
        # note that if you are connecting to a postgres instance on a different host
        # postgresql.service should not be included in the requires.
        # Unit.Requires = [ "network-online.target" "postgresql.service" ];
        # requires bash
        path = [ pkgs.bash ];
        unitConfig = {
          Description = "<%= @app_name %>";
          Requires = [ "<%= @app_name %>_migration.service"];
          After = [ "<%= @app_name %>_migration.service" ];
          StartLimitInterval = 10;
          StartLimitBurst = 3;
        };
        serviceConfig ={
          Type = "exec";
          ExecStart = "${release}/bin/${release_name} start";
          ExecStop = "${release}/bin/${release_name} stop";
          ExecReload = "${release}/bin/${release_name} reload";
          Restart = "on-failure";
          RestartSec = 5;
          WorkingDirectory = working_directory;
          Environment = environment;
        };
      };
    };
  };
}
