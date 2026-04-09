{ lib
, stdenv
, cmake
, pkg-config
, obs-studio
, python3
}:

stdenv.mkDerivation rec {
  pname = "obs-snekstudio-source";
  version = "0.1.0";

  src = lib.cleanSourceWith {
    src = ../..;
    filter = path: type:
      let
        baseName = builtins.baseNameOf path;
      in !(builtins.elem baseName [ ".venv" ".vscode" "build" "dist" "stage" "__pycache__" ]);
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    python3
  ];

  buildInputs = [ obs-studio ];

  postPatch = ''
    patchShebangs scripts
  '';

  meta = with lib; {
    description = "OBS Studio plugin and demo publisher for cooperative SnekStudio capture";
    license = licenses.unfree;
    platforms = platforms.linux;
    mainProgram = "snekstudio-demo-publisher";
  };
}