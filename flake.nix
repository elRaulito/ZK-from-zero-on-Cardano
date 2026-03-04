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
          inherit (pkgs.texlive)
            scheme-basic
            # engine
            luatex
            luatexbase
            # document class
            latex
            latexmk
            # fonts
            fontspec
            inconsolata
            lm
            lm-math
            # math
            amsmath
            amsfonts
            amssymb
            amsthm
            # layout
            geometry
            fancyhdr
            titlesec
            titletoc
            enumitem
            microtype
            pdflscape
            # graphics and tikz
            tikz-cd
            pgf
            # color
            xcolor
            pagecolor
            # tables
            booktabs
            # boxes
            tcolorbox
            environ
            # hyperlinks
            hyperref
            bookmark
            hypcap
            # bibliography
            biblatex
            bibtex
            # captions
            caption
            # code listings
            listings
            # glossaries
            glossaries
            mfirstuc
            xfor
            datatool
            substr
            # misc
            babel
            babel-english
            background
            calc
            graphicx
            makeidx
            lipsum
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

            # Copy font files so lualatex can find them
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
