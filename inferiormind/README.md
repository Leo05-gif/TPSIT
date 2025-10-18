# inferiormind
Implementazione in Dart col framework Flutter di una versione semplificata del gioco "Master Mind". 
Il giocatore dovrà indovinare una combinazione casualmente generata ogni partita pigiando i tasti presenti sullo schermo.

## Scelte
- Massimo tre tentativi a partita per fornire una sfida al giocatore;
- Presenza di un feedback al di sotto dei tasti che indica se la combinazione scelta sia giusta oppure errata;
- Il buttone in basso a destra presenta un'icona per evidenziarne l'utilizzo all'utente;
- Una volta che il gioco giunge al termine il buttone di "verifica" viene bloccato per due secondi (utilizzando un future e controllando due flags) per dar all'utente il tempo di elaborare il risultato della partita;
- Testo di feedback che appare in alto a fine partita per indicare la vittoria o la sconfitta.
