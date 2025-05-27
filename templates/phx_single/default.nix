{ pkgs ? import <nixpkgs> { }, port ? 4000, appName, branch ? "main", commit ? "", ... }:
let
  beamPackages = pkgs.beamPackages;
  fs = pkgs.lib.fileset;
  inherit (beamPackages) mixRelease;
in 
mixRelease rec {
  pname = appName;
  version = "0.0.1";
  removeCookie = false;
  nativeBuildInputs = with pkgs; [ esbuild ];
  erlangDeterministicBuilds = false;

  PORT = "${toString (port)}";
  RELEASE_COOKIE = "SUPER_SECRET_SECRET_COOKIE_THAT_NEVER_TO_BE_SHARED";
  SECRET_KEY_BASE = "SUPER_SECRET_SECRET_KEYBASE_THAT_NEVER_TO_BE_SHARED";

  # Uncomment to use a git repo to pull in the source
  # src = builtins.fetchGit {
  #   url = "git@host/repo.git";
  #   rev = commit;
  #   ref = branch;
  # };

  # This will use the current directory as source
  src = fs.toSource {
    root = ./.;
    fileset = fs.difference ./. ( fs.unions [ (fs.maybeMissing ./result) ./deps ./_build ]);
  };

  mixNixDeps = import "${src}/mix.nix" {
    inherit (pkgs) lib;
    inherit beamPackages;
    overrides = final: prev: {  };
  };

  # Uncomment if you have node dependencies.
  # nodeDependencies =
  #   (pkgs.callPackage "${src}/assets/default.nix" { }).shell.nodeDependencies;

  # ln -sf ${nodeDependencies}/lib/node_modules assets/node_modules
  postBuild = ''
    cp ${pkgs.esbuild}/bin/esbuild _build/esbuild-linux-x64

    # for external task you need a workaround for the no deps check flag
    # https://github.com/phoenixframework/phoenix/issues/2690
    mix do deps.loadpaths --no-deps-check, assets.deploy
  '';
}

