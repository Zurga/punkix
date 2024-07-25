{ pkgs ? import <nixpkgs> { }, port ? 4000, ...}:
let beamPackages = pkgs.beamPackages;
   # Define you local dependencies here 
   # localDepSources = somepath/. ;
   commit = "LATESTCOMMIT";
   inherit (beamPackages) mixRelease;
  
in mixRelease {
  pname = "<%= @app_name %>";
  version = "0.0.1";

  # Fetch from Git
  src = builtins.fetchGit {
    url = "url to repo";
    rev = commit;
    ref = "master";
  };
  # Build from local source
  # src = fs.toSource { root = ./.; fileset = sources;};

  mixNixDeps = import ./mix.nix {
    inherit (pkgs) lib;
    inherit beamPackages;
    overrides = final: prev: {
      # Maybe set other elixir version?
      # elixir = pkgs.elixir_1_16;

      # To include dependencies that exist only on disk on your computer do use the following override:
      # dep_name = beamPackages.buildMix rec {
      #   name = "dep_name";
      #   version = "dep_version"; # E.G. 0.1.0
      #   src = fs.toSource {root = directory/.; fileset = localDepSources;};
      #   beamDeps = with final; []; # All the dependencies that are needed. 
      # };
    };
  };

  #nodeDependencies = (pkgs.callPackage ./assets/default.nix { }).shell.nodeDependencies;

  # If you have build time environment variables add them here
  MIX_ENV = "prod";
  PORT = "${toString(port)}";
  nativeBuildInputs = with pkgs; [ esbuild ];
  removeCookie = false;

  # This is set to false, because Surface needs to know the filepaths to generate colocated javascript.
  erlangDeterministicBuilds = false;

  postBuild = ''
    ln -sf ${nodeDependencies}/lib/node_modules assets/node_modules
    cp ${pkgs.esbuild}/bin/esbuild _build/esbuild-linux-x64

    # for external task you need a workaround for the no deps check flag
    # https://github.com/phoenixframework/phoenix/issues/2690
    mix do deps.loadpaths --no-deps-check, assets.deploy
  '';
}

