{
  description = "ZK from Zero on Cardano — eBook";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        texlive = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-full;
        };

      in {
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          name = "zk-from-zero-on-cardano-ebook";
          src = ./eBook;

          nativeBuildInputs = [ texlive pkgs.which ];

          buildPhase = ''
            export HOME=$TMPDIR
            export TEXMFHOME=$TMPDIR/texmf
            export TEXMFVAR=$TMPDIR/texmf-var
            export TEXMFCONFIG=$TMPDIR/texmf-config

            cp -r . $TMPDIR/build
            cd $TMPDIR/build

            lualatex -interaction=nonstopmode light.tex
            lualatex -interaction=nonstopmode light.tex
            lualatex -interaction=nonstopmode dark.tex
            lualatex -interaction=nonstopmode dark.tex
          '';

          installPhase = ''
            mkdir -p $out
            cp $TMPDIR/build/light.pdf $out/light.pdf
            cp $TMPDIR/build/dark.pdf  $out/dark.pdf
          '';
        };
      }
    );
}
