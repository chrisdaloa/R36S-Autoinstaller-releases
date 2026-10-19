#!/bin/bash
# Corregge gli stick analogici scambiati/invertiti sulle R36S con
# amux-channel-mapping = <2 3 1 0> (famiglia "clone", es. G80C-MB, G80CA-MB).
#
# Tre modi d'uso:
#  1. Dal menu della console: copiare il file in /roms/tools (cartella "tools"
#     della SD) e avviarlo da Tools. Senza argomenti controlla l'hardware e, se
#     compatibile, applica la correzione. Se il nome del file contiene "Annull"
#     (es. "Annulla Correzione Stick.sh") ripristina invece i file originali.
#  2. Da terminale sulla console:  bash r36s_fix_sticks.sh [--check|--restore|--force]
#  3. Da PC via SSH:  scp ... ; ssh ark@<IP> "bash /tmp/r36s_fix_sticks.sh --check"
#
# Modifica solo il profilo "GO-Super Gamepad" in:
#   - RetroArch 64 e 32 bit (autoconfig/udev)
#   - EmulationStation (/etc/emulationstation/es_input.cfg)
#   - PortMaster (gamecontrollerdb.txt, due copie)
# Scrive valori assoluti: rilanciarlo e' sicuro. Backup *.bak-pre-sticks (una volta sola).
# Se qualcosa fallisce durante l'applicazione, ripristina da solo i file.
# L'esito viene scritto anche in fix_stick_risultato.txt, accanto allo script.

set -u

MODE=auto
FORCE=0
ARGS=$#
for a in "$@"; do
  case "$a" in
    --check) MODE=check ;;
    --restore) MODE=restore ;;
    --force) FORCE=1 ;;
    --) ;;
    *) echo "Opzione sconosciuta: $a (usa --check, --restore, --force)"; exit 2 ;;
  esac
done
# Avvio da menu (nessun argomento): la modalita' dipende dal nome del file.
if [ "$ARGS" -eq 0 ]; then
  case "$(basename "$0")" in *[Aa]nnull*) MODE=restore ;; esac
fi

ROOT="${ROOT:-}"   # prefisso per i test fuori dalla console
RA64="$ROOT/home/ark/.config/retroarch/autoconfig/udev/GO-Super Gamepad.cfg"
RA32="$ROOT/home/ark/.config/retroarch32/autoconfig/udev/GO-Super Gamepad.cfg"
ES="$ROOT/etc/emulationstation/es_input.cfg"
PM1="$ROOT/opt/system/Tools/PortMaster/gamecontrollerdb.txt"
PM2="$ROOT/opt/system/Tools/PortMaster/batocera/gamecontrollerdb.txt"
FILES=("$RA64" "$RA32" "$ES" "$PM1" "$PM2")

SUDO=""
[ -z "$ROOT" ] && [ "$(id -u)" -ne 0 ] && SUDO="sudo"

# --- uscita: terminale, schermo della console (tty1) e file di esito ---------
SELF_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)" || SELF_DIR=""
LOG="$SELF_DIR/fix_stick_risultato.txt"
{ [ -n "$SELF_DIR" ] && : >> "$LOG"; } 2>/dev/null || { mkdir -p "$ROOT/tmp"; LOG="$ROOT/tmp/fix_stick_risultato.txt"; }

TTY1=0
if [ -z "$ROOT" ] && [ ! -t 1 ] && [ -e /dev/tty1 ]; then
  $SUDO chmod 666 /dev/tty1 2>/dev/null
  [ -w /dev/tty1 ] && TTY1=1
fi
if [ "$TTY1" -eq 1 ]; then
  export TERM=linux
  printf '\033c' > /dev/tty1
  f=/usr/share/consolefonts/Lat7-TerminusBold22x11.psf.gz
  [ -f "$f" ] && command -v setfont >/dev/null 2>&1 && $SUDO setfont "$f" 2>/dev/null
fi

say() {
  echo "$*"
  echo "$*" >> "$LOG" 2>/dev/null
  [ "$TTY1" -eq 1 ] && echo "$*" > /dev/tty1
  return 0
}

# Da menu lo schermo deve restare leggibile prima di tornare a EmulationStation.
finish() {
  say ""
  say "(Esito salvato in fix_stick_risultato.txt)"
  if [ "$ARGS" -eq 0 ] && [ -z "$ROOT" ] && [ -z "${SSH_CONNECTION:-}" ]; then
    sleep 20
    [ "$TTY1" -eq 1 ] && printf '\033c' > /dev/tty1
  fi
  exit "$1"
}

say "=== $(date '+%Y-%m-%d %H:%M:%S') Correzione stick R36S ==="
say "Modello: $(tr -d '\0' < "$ROOT/sys/firmware/devicetree/base/model" 2>/dev/null || echo ?)"

# --- ripristino -------------------------------------------------------------
restore_all() {
  local n=0 f
  for f in "${FILES[@]}"; do
    if [ -f "$f.bak-pre-sticks" ]; then
      $SUDO cp -p "$f.bak-pre-sticks" "$f" && n=$((n+1))
    fi
  done
  return $((n == 0))
}

if [ "$MODE" = restore ]; then
  if restore_all; then
    sync
    say "FATTO: file ripristinati."
    say "Riavvia EmulationStation (Start > Esci)."
    finish 0
  fi
  say "Niente da ripristinare:"
  say "la correzione non era stata applicata."
  finish 0
fi

# --- controllo hardware -----------------------------------------------------
MAP_FILE="$ROOT/sys/firmware/devicetree/base/odroidgo3-joypad/amux-channel-mapping"
MAP="sconosciuto"
if [ -r "$MAP_FILE" ]; then
  MAP=$(od -An -tu4 --endian=big -v "$MAP_FILE" | xargs)
fi
say "Mappatura stick: $MAP"
if [ "$MAP" != "2 3 1 0" ] && [ "$FORCE" -ne 1 ]; then
  say "NON COMPATIBILE: questa console ha"
  say "una mappatura diversa (serve 2 3 1 0)."
  say "Non e' stato modificato nulla."
  say "Chiedi aiuto nel Discord indicando"
  say "il modello della scheda madre."
  finish 1
fi
if [ "$MODE" = check ]; then
  say "OK: hardware compatibile."
  finish 0
fi

for f in "${FILES[@]}"; do
  if [ ! -f "$f" ]; then
    say "ERRORE: file mancante:"
    say "$f"
    say "Non e' stato modificato nulla."
    finish 1
  fi
done

# --- applicazione (con ripristino automatico in caso di errore) -------------
apply_all() (
  set -e
  for f in "${FILES[@]}"; do
    [ -f "$f.bak-pre-sticks" ] || $SUDO cp -p "$f" "$f.bak-pre-sticks"
  done

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

  for f in "$PM1" "$PM2"; do
    $SUDO sed -i '/,GO-Super Gamepad,/{
s/leftx:a[0-9]*~\{0,1\},/leftx:a3~,/
s/lefty:a[0-9]*~\{0,1\},/lefty:a2~,/
s/rightx:a[0-9]*~\{0,1\},/rightx:a0~,/
s/righty:a[0-9]*~\{0,1\},/righty:a1~,/
}' "$f"
  done

  # verifica finale: se non torna, il chiamante ripristina
  for f in "$RA64" "$RA32"; do
    grep -q '^input_l_x_plus_axis = "-3"' "$f"
    grep -q '^input_r_y_minus_axis = "+1"' "$f"
  done
  grep -q 'name="leftanalogup" type="axis" id="2" value="1"' "$ES"
  grep -q 'name="rightanalogright" type="axis" id="0" value="-1"' "$ES"
  for f in "$PM1" "$PM2"; do
    grep -q 'GO-Super Gamepad.*leftx:a3~,lefty:a2~.*rightx:a0~,righty:a1~' "$f"
  done
)

if apply_all; then
  sync
  say "FATTO: stick corretti."
  say "Riavvia EmulationStation (Start > Esci)"
  say "e prova entrambi gli stick."
  say "Per annullare usa 'Annulla Correzione Stick'."
  finish 0
fi

restore_all
sync
say "ERRORE durante la modifica."
say "I file sono stati ripristinati."
say "Contatta la community (Discord)."
finish 1
