{
  pkgs ? import <nixpkgs> { }
, fenix ? import (fetchTarball "https://github.com/nix-community/fenix/archive/main.tar.gz") { }
}@args:
let toolchain = fenix.minimal.toolchain;
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.101100.ca";
      owner = "heards";
      repo = "kiku";
      rev = "df7abfc398c4c11caf4fe76e9e38920ddda47675";
      hash = "sha256-2U8Aqr/FfpMsiYqbfgk/S2AD7TLVBgHGnOyhBCGt1bQ=";
    }; in
(pkgs.makeRustPlatform {
	cargo = toolchain;
	rustc = toolchain;
}).buildRustPackage {
	buildInputs = [ pkgs.alsa-lib ];
	nativeBuildInputs = [ pkgs.pkg-config pkgs.makeWrapper ];

	pname = "kiku";
	version = "0.1.0-df7abfc";
	src = src;
	cargoLock.lockFile = "${src}/Cargo.lock";

	postFixup = ''
					wrapProgram $out/bin/kiku \
						--set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath [ pkgs.alsa-lib ]}";
				'';
}
