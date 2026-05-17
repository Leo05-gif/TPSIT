# Circulus Librorum
## Sommario
Applicazione per la gestione e l'organizzazione di club di lettura. Ogni utente può creare il proprio club, divenendone gestore. Egli condivide un token d'invito ad altri utenti. Il gestore stabilisce la lettura - definendo vari paramentri - e fissa il turno, ovvero la data entro cui bisogna leggere un certo numero di pagine / capitoli. L'utente conferma l'avvenuta lettura per quel turno. 

# Risorse utilizzate

- **https://dbdiagram.io/**

**PHP**

- **https://www.php.net/manual/en/mysqli.quickstart.prepared-statements.php**
- **https://www.php.net/manual/en/security.database.sql-injection.php**
- **https://www.php.net/manual/en/wrappers.php.php**
- **https://www.php.net/manual/en/reserved.variables.httpresponseheader.php**
- **https://it.wikipedia.org/wiki/Autenticazione**

# DIARIO

<img width="1102" height="680" alt="db" src="https://github.com/user-attachments/assets/374fbd87-3567-4b41-81fd-c860b8967e0b" />

## STEP 1
Il file index.php fa da entry point e gestisce in modo opportuno ogni chiamate all'API da parte del client.

Implementazione della parte riguardante la registrazione, login, autenticazione ed eliminazione di un utente. 

All'utente viene assegnato un *token* univoco (le funzioni relative alla gestione dei token sono definite in utils/token.php) valido fino al prossimo login oppure fino alla scadenza del token stesso (expires_at) con lo scopo di verificare la validità delle richieste effettuate dal client, ovvero di non permettere a terzi di fare chiamate all'API. Il token viene generato dalla seguente funzione:


```
function generate_token(): string {
    return bin2hex(random_bytes(64));
}
```

La funzione `random_bytes()` genera una seguenza casuale di lunghezza n (in questo caso n = 64) di bytes mentre `bin2hex()` converte siffatti bytes in valori esadecimali ritornando una stringa lunga 128 caratteri. Questo token verrà spedito al client al momento del login.

Questo sistema permette una sola "sessione" per utente, ma ritengo che sia sufficiente per gli scopi del progetto.

Per eliminare l'account il client spedisce il token della propria "sessione" e la password, per un'ulteriore verifica. La relativa riga della sessione presente nella tabella *users_tokens* sarà cancellata all'eliminazione dell'utente grazie al constrain "ON DELETE CASCADE"

## STEP 2
Implementazione dei servizi riguardanti la gestione dei club.

Colui che crea il club ne diventa il gestore, ovvero è l'unico in grado di effettuare operazioni relativi alla sua amministrazione (cancellazione, creazione inviti). Perciò li script che si occupano di siffatte operazioni verificano che tale utente sia il capo di tale gruppo.

L'invito è un codice alfanumerico univoco formato da otto caratteri utilizzabile soltanto una volta. Le operazioni di creazione e validazione sono analoghe a quelli usati da lato utente, con l'unica differenza che se l'invito è scaduto viene eliminato.

## STEP 3
Implementazione dei servizi delle sessioni. Nulla di rilevante da documentare in quanto le funzioni CRUD sono analoghe a quelle già implementate. Tuttavia, l'unica novità è la funzione "complete" che permette al gestore del gruppo di contrassegnare come completata la sessione.

## STEP 4
Implementazione dei servizi dei turni. API analoga a quella delle sessioni.

## STEP 5
Incominciata l'implementazione del client. Siffatto punto riguarda la gestione delle richieste, ossia ho scritto le classi che contengono le funzioni che si occupano di effettuare le richieste (utilizzando il metodo HTTP corretto, come richiesto dalla consegna). Le funzioni in sé non fanno nulla di complesso, si limitano a prendere il dato json e ritornarlo così com'è.

## STEP 6
Implementazione del database interno, inclusi i modelli e le funzioni di query. I modelli sono simili a quelli costruiti in classe, l'unica particolarità si trova nell'utlizzo della funzione `toIso8601String()` per convertire una stringa in una rappresentazione estesa ISO-8601 a piena precisione.

La classe `LocalDatabase` contiene tutte le query e, in particolare, la funzione `syncClubData()` che si occupa di sincronizzare i dati in memoria con quelli salvati nel database. Il parametro *conflictAlgorithm* viene settato in *ConflictAlgorithm.replace*, che vuol dire: "in caso di conflitto cancella la vecchia riga e inserisci quella nuova". 

## STEP 7
Implementazione delle schermate di login e registrazione. Entrambe utilizzano un `Form` con validazione lato client: i campi devono contenere almeno quattro caratteri e, nel caso della registrazione, le due password devono coincidere. In caso di errore, sia lato client che lato server, viene mostrato un `AlertDialog` con il relativo messaggio.

Al login avvenuto con successo, utente e token vengono salvati nel database locale e l'utente viene reindirizzato alla schermata principale. La registrazione, invece, reindirizza al login.

## STEP 8
Implementazione della schermata principale e delle schermate dei club e delle sessioni.

La schermata principale mostra i club di cui l'utente è membro sotto forma di card cliccabili. Ogni card indica se l'utente è gestore del club tramite un'etichetta apposita. I dati vengono recuperati dal server e salvati in locale; in caso di assenza di connessione si ricorre ai dati già in cache.

La schermata del club mostra le sessioni associate, anch'esse come card con un indicatore di stato (attiva o completata). Il gestore può aggiungere ed eliminare sessioni tramite un bottom sheet, e generare un codice d'invito visualizzato in un dialog. La schermata della sessione mostra i turni con le rispettive date di inizio e fine. Il gestore può aggiungere ed eliminare turni, scegliendo le date tramite un date picker, e contrassegnarli come completati.

## STEP 9
Implementazione della modalità offline e della sincronizzazione.

È stato introdotto un meccanismo di coda di sincronizzazione: ogni operazione che modifica dati (completamento di un turno o di una sessione, creazione o eliminazione di sessioni e turni) viene prima tentata in rete; se il server non è raggiungibile, la modifica viene applicata localmente e l'operazione viene salvata nella tabella `sync_queue` del database locale.

La classe `SyncService` gestisce un timer periodico che tenta di svuotare la coda ogni trenta secondi, riproponendo le operazioni pendenti nell'ordine in cui erano state accodate. Le operazioni riuscite vengono rimosse dalla coda.

Per evitare che l'assenza di connessione blocchi indefinitamente l'interfaccia, tutte le richieste HTTP passano per la classe `ApiClient`, che impone un timeout di sei secondi. Allo scadere del timeout viene sollevata un'eccezione, catturata dai blocchi `catch` delle singole schermate, le quali ricadono sui dati locali senza mostrare errori all'utente.

All'avvio, la schermata `SplashPage` verifica la presenza di un token valido in cache: se trovato, avvia il `SyncService` e porta l'utente direttamente alla schermata principale, senza richiedere un nuovo login. Al logout, il `SyncService` viene fermato e il database locale viene svuotato completamente.
