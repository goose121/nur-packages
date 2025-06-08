# When you use pkgs.callPackage, parameters here will be filled with packages from Nixpkgs (if there's a match)
{ lib
, stdenv
, fetchFromGitHub
, vala
, glib
, libgee
, pkg-config
, redshift
, ...
} @ args:

stdenv.mkDerivation rec {
  # Specify package name and version
  pname = "redshift-scheduler";
  version = "1.3.1";

  # Download source code from GitHub
  src = fetchFromGitHub ({
    owner = "spantaleev";
    repo = "redshift-scheduler";
    # Commit or tag, note that fetchFromGitHub cannot follow a branch!
    rev = "1.3.1";
    # Download git submodules, most packages don't need this
    fetchSubmodules = false;
    # Don't know how to calculate the SHA256 here? Comment it out and build the package
    # Nix will raise an error and show the correct hash
    sha256 = "sha256-K2CCs74d52yZVzMJRv3nqVlnVPac6DjAfEEng2owl78=";
  });

  # Parallel building, drastically speeds up packaging, enabled by default.
  # You only want to turn this off for one of the rare packages that fails with this.
  enableParallelBuilding = true;
  # If you encounter some weird error when packaging CMake-based software, try enabling this
  # This disables some automatic fixes applied to CMake-based software
  dontFixCmake = true;

  # This thing is in Vala
  nativeBuildInputs = [ vala ];

  buildInputs = [
    glib
    libgee
    pkg-config
    redshift
  ];

  # build.sh starts with invalid shebang, remove it then do bash
  buildPhase = ''
    tail -n +1 build.sh | bash
  '';

  installPhase = ''
    mkdir -p $out
    ls -la $in
    install -Dm 644 resources/rules.conf.dist $out/share/redshift-scheduler/rules.conf.dist
	  install -Dm 644 resources/redshift-scheduler.desktop $out/share/applications/redshift-scheduler.desktop
	  install -Dm 755 build/redshift-scheduler $out/bin/redshift-scheduler
  '';

  # stdenv.mkDerivation automatically does the rest for you
}
