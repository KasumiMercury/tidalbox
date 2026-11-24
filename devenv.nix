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
  sc3Plugins =
    if pkgs.stdenv.isDarwin
    then
      let
        zip = pkgs.fetchzip {
          url = "https://github.com/supercollider/sc3-plugins/releases/download/Version-3.14.1/sc3-plugins-3.14.1-macOS.zip";
          hash = "sha256-AgskwJd1dloDFe9kAw8M7nOisPb1MsN/njMMv3cJ6IQ=";
          postFetch = "find $out -name '._*' -delete";
        };
      in
      {
        classes = "${zip}/SC3plugins";
        ugens = "${zip}/SC3plugins";
      }
    else
      let
        pkg = pkgs.supercolliderPlugins.sc3-plugins;
      in
      {
        classes = "${pkg}/share/SuperCollider/Extensions";
        ugens = "${pkg}/lib/SuperCollider/plugins";
      };
  builtinUgens =
    if pkgs.stdenv.isDarwin
    then "/Applications/SuperCollider.app/Contents/Resources/plugins"
    else "${pkgs.supercollider}/lib/SuperCollider/plugins";
  sclangConf = pkgs.writeText "sclang_conf.yaml" ''
    includePaths:
      - ${superdirt}
      - ${vowel}
      - ${sc3Plugins.classes}
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
  env.SC_UGEN_PATHS = "${builtinUgens}:${sc3Plugins.ugens}";

  scripts = {
    sclang.exec = ''exec ${sclangBin} -l ${sclangConf} "$@"'';
    superdirt.exec = ''sclang "$DEVENV_ROOT/superdirt.scd"'';
    tidal.exec = ''ghci -ghci-script "$DEVENV_ROOT/BootTidal.hs"'';
  };
}
