# biri built from its upstream flake, with the same niri -> biri renames as the
# biri-altinstall-git AUR package so it can be installed alongside niri.
{ niri }:

niri.overrideAttrs (old: {
  pname = "biri";

  # Upstream tests spin up a mock compositor and are slow; the fork is tested upstream.
  doCheck = false;

  postPatch = (old.postPatch or "") + ''
    sed -i \
      -e 's|ProjectDirs::from("", "", "niri")|ProjectDirs::from("", "", "biri")|' \
      -e 's|"/etc/niri/config.kdl"|"/etc/biri/config.kdl"|' \
      -e 's|env::set_var("XDG_CURRENT_DESKTOP", "niri")|env::set_var("XDG_CURRENT_DESKTOP", "biri:niri")|' \
      -e 's|^\( *\)"niri",$|\1"biri",|' \
      src/main.rs
    sed -i 's|\$XDG_CONFIG_HOME/niri/config.kdl|$XDG_CONFIG_HOME/biri/config.kdl|' src/cli.rs

    sed -i 's/\bniri\b/biri/g' resources/niri-session resources/niri.service resources/niri-shutdown.target
    sed -i \
      -e 's|^Name=Niri$|Name=Biri|' \
      -e 's|^Exec=niri-session$|Exec=biri-session|' \
      -e 's|^DesktopNames=niri$|DesktopNames=biri;niri|' \
      resources/niri.desktop

    # Fail loudly if upstream changed and a substitution silently missed.
    grep -qF 'ProjectDirs::from("", "", "biri")' src/main.rs
    grep -qF '"/etc/biri/config.kdl"' src/main.rs
    grep -qF '"XDG_CURRENT_DESKTOP", "biri:niri"' src/main.rs
    if grep -qE '^ *"niri",$' src/main.rs; then echo "biri: argv rename missed" >&2; exit 1; fi
    grep -qF 'exec biri --session' resources/niri-session
    if grep -qF 'niri.service' resources/niri-session; then echo "biri: session rename missed" >&2; exit 1; fi
    grep -qE '^ExecStart=.*/bin/biri --session$' resources/niri.service
    grep -qxF 'Exec=biri-session' resources/niri.desktop
  '';

  # Shell completions are skipped: they would collide with niri's and complete the wrong command.
  postInstall = ''
    mv $out/bin/niri $out/bin/biri
    install -Dm755 resources/niri-session $out/bin/biri-session
    install -Dm644 resources/niri.desktop $out/share/wayland-sessions/biri.desktop
    install -Dm644 resources/niri-portals.conf $out/share/xdg-desktop-portal/biri-portals.conf
    install -Dm644 resources/niri.service $out/lib/systemd/user/biri.service
    install -Dm644 resources/niri-shutdown.target $out/lib/systemd/user/biri-shutdown.target
  '';

  passthru = (old.passthru or { }) // { providedSessions = [ "biri" ]; };
  meta = old.meta // {
    description = "Niri compositor soft-fork, installed as biri";
    homepage = "https://github.com/barrulus/biri";
    mainProgram = "biri";
  };
})
