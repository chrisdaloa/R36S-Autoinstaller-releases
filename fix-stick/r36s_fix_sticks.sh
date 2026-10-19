#!/bin/bash
# Corregge gli stick analogici scambiati/invertiti sulle R36S con
# amux-channel-mapping = <2 3 1 0> (famiglia "clone", es. G80C-MB).
# Va eseguito SULLA CONSOLE (utente ark), anche da PC con:
#   ssh ark@<IP> 'bash -s' < r36s_fix_sticks.sh -- [--check|--restore|--force]
#
# Modifica solo il profilo "GO-Super Gamepad" in:
#   - RetroArch 64 e 32 bit (autoconfig/udev)
#   - EmulationStation (/etc/emulationstation/es_input.cfg)
#   - PortMaster (gamecontrollerdb.txt, due copie)
# Scrive valori assoluti: rilanciarlo e' sicuro. Backup *.bak-pre-sticks (una volta sola).

set -eu

MODE=apply
FORCE=0
for a in "$@"; do
  case "$a" in
    --check) MODE=check ;;
    --restore) MODE=restore ;;
    --force) FORCE=1 ;;
    --) ;;
    *) echo "Opzione sconosciuta: $a (usa --check, --restore, --force)"; exit 2 ;;
  esac
done

ROOT="${ROOT:-}"   # prefisso per i test fuori dalla console
RA64="$ROOT/home/ark/.config/retroarch/autoconfig/udev/GO-Super Gamepad.cfg"
RA32="$ROOT/home/ark/.config/retroarch32/autoconfig/udev/GO-Super Gamepad.cfg"
ES="$ROOT/etc/emulationstation/es_input.cfg"
PM1="$ROOT/opt/system/Tools/PortMaster/gamecontrollerdb.txt"
PM2="$ROOT/opt/system/Tools/PortMaster/batocera/gamecontrollerdb.txt"
FILES=("$RA64" "$RA32" "$ES" "$PM1" "$PM2")

SUDO=""
[ -z "$ROOT" ] && [ "$(id -u)" -ne 0 ] && SUDO="sudo"

# --- ripristino -------------------------------------------------------------
if [ "$MODE" = restore ]; then
  for f in "${FILES[@]}"; do
    if [ -f "$f.bak-pre-sticks" ]; then
      $SUDO cp -p "$f.bak-pre-sticks" "$f" && echo "ripristinato: $f"
    else
      echo "nessun backup: $f"
    fi
  done
  exit 0
fi

# --- controllo hardware -----------------------------------------------------
MAP_FILE="$ROOT/sys/firmware/devicetree/base/odroidgo3-joypad/amux-channel-mapping"
MAP="sconosciuto"
if [ -r "$MAP_FILE" ]; then
  MAP=$(od -An -tu4 --endian=big -v "$MAP_FILE" | xargs)
fi
echo "amux-channel-mapping rilevato: $MAP"
if [ "$MAP" != "2 3 1 0" ] && [ "$FORCE" -ne 1 ]; then
  echo "Questa console non ha la mappatura attesa (2 3 1 0): la correzione potrebbe essere sbagliata."
  echo "Misura gli assi con evtest, oppure rilancia con --force se sei sicuro."
  exit 1
fi
[ "$MODE" = check ] && { echo "OK: hardware compatibile."; exit 0; }

for f in "${FILES[@]}"; do
  [ -f "$f" ] || { echo "File mancante: $f"; exit 1; }
done

# --- backup (una volta sola) ------------------------------------------------
for f in "${FILES[@]}"; do
  [ -f "$f.bak-pre-sticks" ] || $SUDO cp -p "$f" "$f.bak-pre-sticks"
done

# --- RetroArch (64 e 32 bit) ------------------------------------------------
for f in "$RA64" "$RA32"; do
  $SUDO sed -i \
    -e 's/^input_l_x_plus_axis.*/input_l_x_plus_axis = "-3"/' \
    -e 's/^input_l_x_minus_axis.*/input_l_x_minus_axis = "+3"/' \
    -e 's/^input_l_y_plus_axis.*/input_l_y_plus_axis = "-2"/' \
    -e 's/^input_l_y_minus_axis.*/input_l_y_minus_axis = "+2"/' \
    -e 's/^input_r_x_plus_axis.*/input_r_x_plus_axis = "-0"/' \
    -e 's/^input_r_x_minus_axis.*/input_r_x_minus_axis = "+0"/' \
    -e 's/^input_r_y_plus_axis.*/input_r_y_plus_axis = "-1"/' \
    -e 's/^input_r_y_minus_axis.*/input_r_y_minus_axis = "+1"/' \
    "$f"
done

# --- EmulationStation (solo il blocco GO-Super Gamepad) ---------------------
es_axis() { # nome id valore
  echo "s|\\(name=\"$1\" type=\"axis\"\\) id=\"[0-9]*\" value=\"-\\?[0-9]*\"|\\1 id=\"$2\" value=\"$3\"|"
}
$SUDO sed -i "/deviceName=\"GO-Super Gamepad\"/,/<\\/inputConfig>/{
$(es_axis leftanalogup 2 1)
$(es_axis leftanalogdown 2 -1)
$(es_axis leftanalogleft 3 1)
$(es_axis leftanalogright 3 -1)
$(es_axis rightanalogup 1 1)
$(es_axis rightanalogdown 1 -1)
$(es_axis rightanalogleft 0 1)
$(es_axis rightanalogright 0 -1)
}" "$ES"

# --- PortMaster -------------------------------------------------------------
for f in "$PM1" "$PM2"; do
  $SUDO sed -i '/,GO-Super Gamepad,/{
s/leftx:a[0-9]*~\{0,1\},/leftx:a3~,/
s/lefty:a[0-9]*~\{0,1\},/lefty:a2~,/
s/rightx:a[0-9]*~\{0,1\},/rightx:a0~,/
s/righty:a[0-9]*~\{0,1\},/righty:a1~,/
}' "$f"
done

sync
echo "Fatto. Riavvia EmulationStation (o la console) e prova entrambi gli stick."
echo "Per annullare: $0 --restore"
