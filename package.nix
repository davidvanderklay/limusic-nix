{
  appimageTools,
  fetchurl,
  libappindicator-gtk3,
  webkitgtk_4_1,
}:

let
  version = "0.7.3";
in
appimageTools.wrapType2 {
  pname = "limusic";
  inherit version;

  src = fetchurl {
    url = "https://github.com/SimoHypers/limusic/releases/download/v${version}/limusic_${version}_amd64.AppImage";
    hash = "sha256-RDwXrGkqZ8BvFiEBKKt27BA4saRhzbJUXdkQ6k+KFvw=";
  };

  extraPkgs = appimagePkgs: with appimagePkgs; [
    webkitgtk_4_1
    libappindicator-gtk3
  ];
}
