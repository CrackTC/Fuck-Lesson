{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python-pkgs = ps: with ps; [
          requests
          pycryptodomex
          (
            buildPythonPackage rec {
              pname = "ddddocr";
              version = "1.4.10";
              src = fetchPypi {
                inherit pname version;
                sha256 = "sha256-2oNcoUXmNii+wXKwU54Z2Aj5poi+JUdE+PONjQ6g0Kc=";
              };
              doCheck = false;
              propagatedBuildInputs = [
                onnxruntime
                pillow
                opencv4
              ];
            }
          )
        ];
        buildInputs = with pkgs; [ (python3.withPackages python-pkgs) ];
      in
      {
        devShells.default = pkgs.mkShell {
          packages = buildInputs ++ [ pkgs.fish ];
          shellHook = "exec fish";
        };

        packages.default = pkgs.stdenv.mkDerivation {
          name = "fuck-lesson";
          version = "unstable-2023-12-30";

          src = ./.;
          inherit buildInputs;

          installPhase = ''
            mkdir -p $out/bin
            cp ./icourses.py $out/bin/icourses
            chmod +x $out/bin/icourses
          '';

          meta = with pkgs.lib; {
            description = "吉林大学抢课脚本";
            homepage = "https://github.com/H4ckF0rFun/Fuck-Lesson";
            license = licenses.free;
            platforms = [ system ];
            mainProgram = "icourses";
            sourceProvenance = with sourceTypes; [ fromSource ];
          };
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/icourses";
        };
      });
}
