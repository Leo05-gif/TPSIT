# chatroom
Implementazione in Dart di un server TCP, client testuale e client mobile in flutter

## Scelte
- Suddivisione del programma in tre 'pagine', cioè Widget;
- Pagina di login dove l'utente inserisce un nickname;
- Pagina della chatroom dove l'utente visualizza e manda i messaggi;
- Pagine delle impostazioni, accessibile dalla pagina chatroom, che permette di cambiare il tema dell'applicazione (scuro->chiaro e viceversa) e il font dei messaggi (tramite l'utilizzo della classe ValueNotifier);
