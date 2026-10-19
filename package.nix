{
  appimageTools,
  fetchurl,
  libappindicator-gtk3,
  symlinkJoin,
  webkitgtk_4_1,
}:

let
  version = "1.3.0";
  src = fetchurl {
    url = "https://github.com/SimoHypers/limusic/releases/download/v${version}/limusic_${version}_amd64.AppImage";
    hash = "sha256-skhW7OeTMN06Y/WvI5Tm+Dja50rtxh42d0Q96Qwrc4c=";
  };
  contents = appimageTools.extract {
    pname = "limusic";
    inherit version src;
  };
  runtime = appimageTools.wrapAppImage {
    pname = "limusic";
    inherit version contents;

    extraPkgs = appimagePkgs: with appimagePkgs; [
      webkitgtk_4_1
      libappindicator-gtk3
    ];
  };
in
symlinkJoin {
  name = "limusic-${version}";
  paths = [ runtime ];

  postBuild = ''
    install -Dm444 ${contents}/usr/share/applications/limusic.desktop \
      $out/share/applications/limusic.desktop
    substituteInPlace $out/share/applications/limusic.desktop \
      --replace-fail 'Exec=limusic-app' 'Exec=limusic' \
      --replace-fail 'Name=limusic' 'Name=Limusic'

    mkdir -p $out/share/icons
    cp -R ${contents}/usr/share/icons/hicolor $out/share/icons/
  '';
}
