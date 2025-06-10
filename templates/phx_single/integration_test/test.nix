let
  pkgs = import <nixpkgs> {};
in
  pkgs.testers.runNixOSTest {
  name = "test";
  nodes = {
    vm = {lib, pkgs, nodes, ...}: {
      imports = [ ../service.nix ];
      services.<%= @app_name %> = {
        enable = true;
        migrateCommand = "<%= @app_module %>.Release.migrate";
        seedCommand = "<%= @app_module %>.Release.seed";
        environments = {
          prod = {
            host = "localhost";
            ssl = false;
            port = 5000;
          };
        };
      };
    };
  };   
  testScript = ''
    vm.start()
    print(vm.execute("ls /etc/systemd/system/"))
    vm.wait_for_unit("<%= @app_name %>_seed")
    vm.wait_for_unit("<%= @app_name %>_prod")
    vm.shell_interact()          # Open an interactive shell in the VM (drop-in login shell)
  '';
}
