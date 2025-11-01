# chronometer

Implementazione in Dart col framework Flutter di un cronometro.

## Scelte
- void startTicker(): Stream periodico che emette un tick. Ogni volta che emette un evento, esso viene aggiunto alla variabile "_controller" (uno streamController) finché lo streamController non viene chiuso, cioè per tutta la durata del programma.
- Stream<int> _secondsGenerator() async*: Stream che incrementa i secondi fintantoché l'utente non mette in pausa il cronometro.
- Presenza di due buttoni per la gestione del cronometro.
- Font personalizzato per il testo del cronometro.
