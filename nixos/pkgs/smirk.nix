# smirk emoji picker, mirroring the smirk-git AUR package (binary plus smirk-toggle).
{
  lib,
  rustPlatform,
  pkg-config,
  wrapGAppsHook4,
  gtk4,
  libadwaita,
  glib,
  wl-clipboard,
  wtype,
  writeShellScript,
  src,
}:

let
  toggle = writeShellScript "smirk-toggle" ''
    # Show the resident picker over D-Bus, or cold-start it if it isn't running.
    ${lib.getExe' glib "gdbus"} call --session --dest lt.yiin.smirk --object-path /lt/yiin/smirk \
      --method org.freedesktop.Application.Activate '{}' >/dev/null 2>&1 \
      || exec @smirk@
  '';
in
rustPlatform.buildRustPackage {
  pname = "smirk";
  version = "0.1.0-unstable";
  inherit src;

  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];
  buildInputs = [
    gtk4
    libadwaita
  ];

  doCheck = false;

  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ wl-clipboard wtype ]})
  '';

  postInstall = ''
    install -Dm755 ${toggle} $out/bin/smirk-toggle
    substituteInPlace $out/bin/smirk-toggle --replace-fail @smirk@ $out/bin/smirk
  '';

  meta = {
    description = "Emoji picker for Wayland that opens in an actually reasonable time";
    homepage = "https://github.com/Yiin/smirk";
    license = lib.licenses.mit;
    mainProgram = "smirk";
    platforms = lib.platforms.linux;
  };
}
