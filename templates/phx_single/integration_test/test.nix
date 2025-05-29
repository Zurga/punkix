let
  pkgs = import <nixpkgs> {};
in
  pkgs.testers.runNixOSTest {
  name = "test";
  nodes = {
    vm = {lib, pkgs, nodes, ...}: {
      imports = [ ../service.nix ];
      services.test = {
        enable = true;
        migrateCommand = "<%= @app_module %>.Release.migrate";
        seedCommand = "<%= @app_module %>.Release.seed";
        environments = {
          prod = {
            host = "localhost";
            ssl = false;
            port = 5000;
            migrateCommand = "TestXP76ASEU7K.Release.migrate";
            seedCommand = "TestXP76ASEU7K.Release.seed";
            runtimePackages = with pkgs; [curl];
          };
        };
      };
    };
  };   
  testScript = ''
    vm.start()
    print(vm.execute("ls /etc/systemd/system/"))
    vm.wait_for_unit("test_prod_seed")
    vm.wait_for_unit("test_prod")
    vm.shell_interact()          # Open an interactive shell in the VM (drop-in login shell)
  '';
}
