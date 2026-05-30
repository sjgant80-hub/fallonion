#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  fallonion · sovereign Tor hidden-service mirror · ◊·κ=1
#  Serves your estate over Tor as a .onion address.
#  For censored jurisdictions · or extreme anonymity needs.
#
#  Usage:
#    bash setup.sh start    # install tor + start hidden service
#    bash setup.sh address  # print your .onion address
#    bash setup.sh stop     # stop tor
#    bash setup.sh status   # check tor + hidden service health
# ═══════════════════════════════════════════════════════════════════
set -e

CMD="${1:-help}"
HS_DIR="${FALLONION_HS_DIR:-/var/lib/tor/fallonion_hs}"
HS_PORT="${FALLONION_HS_PORT:-80}"
LOCAL_PORT="${FALLONION_LOCAL_PORT:-8443}"
TORRC="${FALLONION_TORRC:-/etc/tor/torrc.fallonion}"

case "$(uname -s)" in
  Linux*) OS=linux ;;
  Darwin*) OS=mac ;;
  *) OS=unsupported ;;
esac

install_tor() {
  if command -v tor >/dev/null; then echo "✓ tor already installed"; return; fi
  case "$OS" in
    mac) brew install tor ;;
    linux)
      if command -v apt-get >/dev/null; then sudo apt-get update && sudo apt-get install -y tor
      elif command -v dnf >/dev/null; then sudo dnf install -y tor
      else echo "✗ install tor manually for your distro"; exit 1; fi
      ;;
    *) echo "✗ unsupported OS · install Tor manually then re-run"; exit 1 ;;
  esac
}

write_torrc() {
  sudo tee "$TORRC" >/dev/null <<EOF
# fallonion · hidden service config · ◊·κ=1
HiddenServiceDir $HS_DIR
HiddenServicePort $HS_PORT 127.0.0.1:$LOCAL_PORT
HiddenServiceVersion 3
EOF
  echo "✓ torrc written to $TORRC"
  echo "  hidden service dir · $HS_DIR"
  echo "  forwards external :$HS_PORT → 127.0.0.1:$LOCAL_PORT"
}

start_tor() {
  install_tor
  write_torrc
  echo ""
  echo "◊ make sure something is serving on 127.0.0.1:$LOCAL_PORT first."
  echo "◊ recommended: run fallcdn (Caddy) on $LOCAL_PORT serving ./estate"
  echo ""
  echo "◊ start tor with this config:"
  echo "    sudo tor -f $TORRC"
  echo ""
  echo "◊ then get your .onion address:"
  echo "    bash $0 address"
}

show_address() {
  if [ ! -f "$HS_DIR/hostname" ]; then
    echo "✗ hidden service not running yet · run: bash $0 start"
    exit 1
  fi
  ADDR=$(sudo cat "$HS_DIR/hostname")
  echo ""
  echo "◊·κ=1 · your .onion address"
  echo "   $ADDR"
  echo ""
  echo "◊ share this with users in censored regions"
  echo "◊ they can reach your estate via Tor Browser at:"
  echo "   http://$ADDR/"
}

stop_tor() {
  sudo pkill -f "tor -f $TORRC" || echo "(was not running)"
  echo "✓ tor stopped"
}

status() {
  if pgrep -f "tor -f $TORRC" >/dev/null; then
    echo "✓ tor running"
    if [ -f "$HS_DIR/hostname" ]; then
      echo "  .onion · $(sudo cat $HS_DIR/hostname)"
    fi
  else
    echo "✗ tor not running"
  fi
  echo ""
  echo "  local backend on 127.0.0.1:$LOCAL_PORT · $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:$LOCAL_PORT || echo 'offline')"
}

case "$CMD" in
  start) start_tor ;;
  address|addr) show_address ;;
  stop) stop_tor ;;
  status) status ;;
  *)
    cat <<HELP
fallonion · sovereign Tor hidden-service mirror · ◊·κ=1 · prime 317

usage:
  bash setup.sh start    # install tor + write torrc for hidden service
  bash setup.sh address  # print your .onion address
  bash setup.sh status   # check service health
  bash setup.sh stop     # stop tor

env overrides:
  FALLONION_HS_DIR=/var/lib/tor/fallonion_hs
  FALLONION_HS_PORT=80
  FALLONION_LOCAL_PORT=8443

quick setup:
  1. bash setup.sh start
  2. (in another terminal) cd /path/to/estate && caddy run
  3. sudo tor -f /etc/tor/torrc.fallonion
  4. bash setup.sh address
  5. share the .onion with users in censored regions

windows note: tor available via winget · this script targets Linux/Mac.
on windows, use the official Tor Expert Bundle and configure manually.
HELP
    ;;
esac
