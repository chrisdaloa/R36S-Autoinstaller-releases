# Stick analogici scambiati o invertiti su R36S

Su alcune R36S "clone" (schede madri come la **G80C-MB**) gli stick analogici sono collegati in un ordine diverso da quello previsto dal firmware. Il sintomo tipico è che **per muovere lo stick su e giù devi spingerlo a destra e a sinistra**, oppure uno dei due stick va al contrario.

Lo script `r36s_fix_sticks.sh` sistema il problema nei profili del controller, **senza toccare il firmware né i giochi**.

> [!WARNING]
> Lo script è stato provato a fondo solo su una console (scheda `G80C-MB V1.1`) e funziona **solo** su console che hanno quella stessa disposizione degli stick. Prima di modificare qualunque cosa controlla l'hardware da solo e **si ferma** se la console è diversa: in quel caso non forzarlo, chiedi aiuto alla community.
> Usalo a tuo rischio: ogni file modificato viene salvato prima, e puoi annullare tutto in qualsiasi momento (vedi sotto).

## Cosa ti serve

- La console accesa e collegata al **Wi-Fi** (stessa rete del PC).
- L'**indirizzo IP** della console (la trovi nelle impostazioni di rete della console, oppure nell'elenco dei dispositivi del router).
- Un PC Windows 10/11 (basta **PowerShell**) oppure Linux/Mac.
- Il file [`r36s_fix_sticks.sh`](r36s_fix_sticks.sh) scaricato in una cartella, per esempio `Download`.

Utente e password predefiniti di dArkOSen sono entrambi `ark`, se non li hai cambiati.

## Procedura (PowerShell su Windows)

Sostituisci `192.168.1.50` con l'IP della tua console. Apri PowerShell nella cartella dove hai scaricato lo script.

**1. Copia lo script sulla console**

```powershell
scp r36s_fix_sticks.sh ark@192.168.1.50:/tmp/
```

**2. Controlla che la tua console sia compatibile** (non modifica niente)

```powershell
ssh ark@192.168.1.50 "bash /tmp/r36s_fix_sticks.sh --check"
```

Devi leggere `OK: hardware compatibile.` Se invece compare *"Questa console non ha la mappatura attesa"*, **fermati**: la correzione non è adatta alla tua scheda.

**3. Applica la correzione**

```powershell
ssh ark@192.168.1.50 "bash /tmp/r36s_fix_sticks.sh"
```

**4. Riavvia EmulationStation** (dal menu *Start → Esci*) oppure riavvia la console, poi prova **entrambi** gli stick nel menu e in un gioco.

Su Linux e Mac i comandi sono gli stessi, da un terminale.

## Se qualcosa non va: annullare tutto

```powershell
ssh ark@192.168.1.50 "bash /tmp/r36s_fix_sticks.sh --restore"
```

Rimette i file com'erano prima. Il backup (file `.bak-pre-sticks` accanto agli originali) viene creato solo la **prima** volta, quindi puoi rilanciare lo script senza perdere lo stato originale.

## Cosa modifica esattamente

Solo il profilo del controller **"GO-Super Gamepad"** in:

| Programma | File |
|---|---|
| RetroArch (64 e 32 bit) | `~/.config/retroarch/autoconfig/udev/GO-Super Gamepad.cfg` e la copia in `retroarch32` |
| EmulationStation | `/etc/emulationstation/es_input.cfg` (solo il blocco *GO-Super Gamepad*) |
| PortMaster | `gamecontrollerdb.txt` (due copie) |

## Cose da sapere

- **Gli aggiornamenti di dArkOSen possono rimettere i file come prima.** Se dopo un aggiornamento il problema ricompare, rilancia il punto 3.
- **PortMaster** è stato corretto con lo stesso criterio ma non l'ho potuto provare con un gioco: se in un port uno stick risulta ancora al contrario, segnalalo.
- Se la tua scheda è diversa (o il controllo del punto 2 fallisce) e hai lo stesso sintomo, scrivi nel [server Discord](https://discord.gg/tusqNhr2V) indicando il **modello esatto** della scheda madre: serve misurare gli assi per ricavare la correzione giusta.
- Se un giorno scegli un'altra variante di scheda con il programma di installazione, la correzione resta valida solo se l'hardware è davvero lo stesso.

*Strumento fornito così com'è, senza garanzie. L'autore non risponde di eventuali danni alla console o alla scheda SD.*
