{
  lib,
  appimageTools,
  fetchurl,
  writeShellScript,
  desktop-file-utils,
}:

let
  pname = "rakazo-desktop";
  version = "0.12.0";

  src = fetchurl {
    url = "https://github.com/elie222/rakazo/releases/download/v${version}/Rakazo-${version}.AppImage";
    hash = "sha256-6uhZeW2FgtS0lJU3liuSADvQiSbIuuvQ7iCtbKQcwu0=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
  launch = writeShellScript "rakazo-launch" ''
    # This immutable installation is updated through Nix, not electron-updater.
    export RAKAZO_DISABLE_AUTO_UPDATE=1
    unset APPIMAGE APPDIR
    # Bypass AppRun's automatic --no-sandbox fallback. Keep Chromium's user-
    # namespace sandbox; only its unusable setuid helper is disabled.
    exec ${appimageContents}/rakazo --disable-setuid-sandbox "$@"
  '';
in
appimageTools.wrapType2 {
  inherit pname version src;
  executableName = "rakazo";
  runScript = launch;
  nativeBuildInputs = [ desktop-file-utils ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/rakazo.desktop \
      $out/share/applications/rakazo.desktop
    substituteInPlace $out/share/applications/rakazo.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=rakazo %U'
    install -Dm444 ${appimageContents}/.DirIcon \
      $out/share/icons/hicolor/1024x1024/apps/rakazo.png
    desktop-file-validate $out/share/applications/rakazo.desktop
  '';

  passthru = { inherit appimageContents; };

  meta = {
    description = "Official Rakazo desktop client for existing or self-hosted instances";
    homepage = "https://rakazo.com";
    changelog = "https://github.com/elie222/rakazo/releases/tag/v${version}";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "rakazo";
  };
}
