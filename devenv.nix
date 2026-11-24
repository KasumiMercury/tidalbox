{ pkgs, lib, ... }:

let
  superdirt = pkgs.fetchgit {
    url = "https://codeberg.org/musikinformatik/SuperDirt";
    rev = "7e245e87f8f08a3d55e33a360bc97912f32fe69b";
    hash = "sha256-FFBJBlUY6jttEEkn3qldS8z2qoncSyDITUy+x/6l5F8=";
  };
  vowel = pkgs.fetchFromGitHub {
    owner = "supercollider-quarks";
    repo = "Vowel";
    rev = "ab59caa870201ecf2604b3efdd2196e21a8b5446";
    hash = "sha256-zfF6cvAGDNYWYsE8dOIo38b+dIymd17Pexg0HiPFbxM=";
  };
  dirtSamples = pkgs.fetchFromGitHub {
    owner = "tidalcycles";
    repo = "Dirt-Samples";
    rev = "c74fc80f8db8038f6a33648ffef5ac00a07ad402";
    hash = "sha256-OzVvy/L6jfEgGx3dMdhe/PkfMAWVV0HQ9wGy500++fw=";
  };
  sclangConf = pkgs.writeText "sclang_conf.yaml" ''
    includePaths:
      - ${superdirt}
      - ${vowel}
    excludePaths: []
    postInlineWarnings: false
    excludeDefaultPaths: false
  '';
  sclangBin =
    if pkgs.stdenv.isDarwin
    then "/Applications/SuperCollider.app/Contents/MacOS/sclang"
    else lib.getExe' pkgs.supercollider "sclang";
in
{
  packages = [
    (pkgs.haskellPackages.ghcWithPackages (p: [ p.tidal ]))
  ];

  env.DIRT_SAMPLES = "${dirtSamples}";

  scripts = {
    sclang.exec = ''exec ${sclangBin} -l ${sclangConf} "$@"'';
    superdirt.exec = ''sclang "$DEVENV_ROOT/superdirt.scd"'';
    tidal.exec = ''ghci -ghci-script "$DEVENV_ROOT/BootTidal.hs"'';
  };
}
