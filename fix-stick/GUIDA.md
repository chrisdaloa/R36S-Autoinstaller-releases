# Correggere gli stick analogici scambiati o invertiti

🇬🇧 [English version](./GUIDA.en.md)

Su alcune R36S "clone" (schede come **G80C-MB** e **G80CA-MB**) gli stick sono collegati in un ordine diverso da quello previsto: per andare su e giù devi muovere lo stick a destra e a sinistra, oppure uno dei due va al contrario.

Questi due file lo sistemano direttamente dalla console, senza toccare il firmware né i giochi.

> [!WARNING]
> Versione di prova, fornita così com'è e senza garanzie. Funziona solo su schede con questa disposizione degli stick: se la tua è diversa, **non modifica niente** e te lo dice a schermo. Ogni file modificato viene salvato prima e puoi annullare tutto.

## Cosa fare

1. Scarica **[Correggi Stick.sh](Correggi%20Stick.sh)** e **[Annulla Correzione Stick.sh](Annulla%20Correzione%20Stick.sh)**.
2. Spegni la console, metti la SD nel PC e apri la partizione delle ROM (di solito **EASYROMS**).
3. Copia i due file nella cartella **`tools`** (creala se non c'è).
4. Rimetti la SD nella console e accendila.
5. In EmulationStation apri **Tools** e avvia **Correggi Stick**. Leggi il messaggio a schermo e attendi circa 20 secondi.
6. Esci da EmulationStation (**Start → Esci**), riavvialo e prova entrambi gli stick.

## Se non va bene

Avvia **Annulla Correzione Stick** dallo stesso menu: rimette tutto com'era prima.

## Se non succede niente, o hai dubbi

L'esito dell'ultima operazione è salvato nel file **`fix_stick_risultato.txt`**, nella stessa cartella `tools` (lo leggi dal PC). Se chiedi aiuto nel [server Discord](https://discord.gg/XNpjcS5km), allega quel file e indica il **modello della scheda madre** (è stampato sulla scheda).

## Cose da sapere

- Un aggiornamento di dArkOSen può rimettere gli stick come prima: in quel caso basta riavviare di nuovo **Correggi Stick**.
- Il profilo di **PortMaster** viene corretto con lo stesso criterio ma non è stato provato con un gioco: se in un port uno stick risulta ancora al contrario, segnalalo.

## Ti è stato utile?

Se lo script ti ha risolto il problema, puoi offrirmi un caffè su [Ko-fi](https://ko-fi.com/chrisdaloa) ☕ È del tutto facoltativo.
