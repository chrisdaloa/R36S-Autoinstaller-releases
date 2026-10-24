# Fixing swapped or inverted analog sticks

🇮🇹 [Versione italiana](./GUIDA.md)

On some "clone" R36S consoles (boards such as **G80C-MB** and **G80CA-MB**) the sticks are wired in a different order than expected: to go up and down you have to move the stick left and right, or one of the two works backwards.

These two files fix it directly from the console, without touching the firmware or your games.

> [!WARNING]
> Test version, provided as is and without warranty. It only works on boards with this stick layout: if yours is different, it **changes nothing** and tells you on screen. Every modified file is saved first and you can undo everything.

## What to do

1. Download **[Correggi Stick.sh](Correggi%20Stick.sh)** and **[Annulla Correzione Stick.sh](Annulla%20Correzione%20Stick.sh)** (these names are in Italian: "Fix Stick" and "Undo Stick Fix").
2. Turn the console off, put the SD card in your PC and open the ROM partition (usually **EASYROMS**).
3. Copy the two files into the **`tools`** folder (create it if it isn't there).
4. Put the SD card back in the console and turn it on.
5. In EmulationStation open **Tools** and run **Correggi Stick**. Read the message on screen and wait about 20 seconds.
6. Exit EmulationStation (**Start → Quit**), restart it and test both sticks.

## If it's not right

Run **Annulla Correzione Stick** from the same menu: it puts everything back as it was.

## If nothing happens, or you have doubts

The result of the last operation is saved in the file **`fix_stick_risultato.txt`**, in the same `tools` folder (you can read it from the PC; its content is in Italian). If you ask for help on the [Discord server](https://discord.gg/tusqNhr2V), attach that file and state your **motherboard model** (it is printed on the board).

## Good to know

- A dArkOSen update may put the sticks back as before: in that case just run **Correggi Stick** again.
- The **PortMaster** profile is corrected with the same criterion but has not been tested with a game: if in a port a stick is still inverted, please report it.

## Did it help?

If the script fixed your problem, you can buy me a coffee on [Ko-fi](https://ko-fi.com/chrisdaloa) ☕ It is entirely optional.
