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

        # scheme-medium covers the vast majority of what we need;
        # we only add packages not included in it.
        texlive = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-medium   # latex, amsmath, amsfonts, babel, fontspec, geometry,
                            # graphicx, hyperref, listings, microtype, pgf/tikz,
                            # titlesec, xcolor, fancyhdr, booktabs, caption,
                            # enumitem, pdflscape, calc, makeidx, lm, luatex, ...
            # extras not in scheme-medium
            tcolorbox
            environ
            trimspaces
            pagecolor
            background
            bookmark
            hypcap
            biblatex
            biber
            glossaries
            mfirstuc
            xfor
            datatool
            substr
            lipsum
            luatexbase
            ;
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
