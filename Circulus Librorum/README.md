# Circulus Librorum
## Sommario
Applicazione per la gestione e l'organizzazione di club di lettura. Ogni utente può creare il proprio club, divenendone gestore. Egli condivide un token d'invito ad altri utenti. Il gestore stabilisce la lettura - definendo vari paramentri - e fissa il turno, ovvero la data entro cui bisogna leggere un certo numero di pagine / capitoli. L'utente ha la possibilità di poter esprimere il proprio pensiero pertinente al turno sotto forma di un commento. Inoltre egli conferma l'avvenuta lettura per quel turno. 

# Tabella di marcia
## Progettazione

- database ✔️;
- UI del client.
## Implementazione del server
N.B ogni azione di cancellazione, aggiunta e modifica riguardanti le entità di un gruppo possono essere effettuate soltanto dal gestore di tale gruppo.
N.B sql injection e altre possibili vulnerabilità.
### Utenti ✔️
- registrazione utente (verifica validità username, hashing della password);
- autenticazione utente (login);
- cancellazione utente.
### Gruppi 
- creazione di un gruppo;
- eliminazione di un gruppo;
- aggiornamento del logo di un gruppo;
- fornire informazioni gruppo;
- generazione del token d'invito;
- aggiunta di un utente all'interno di un gruppo;
- rimozione utente dal gruppo (N.B uscita oppure forzata).
### Libri
- creazione di un libro;
- eliminazione libro;
- aggiornamento delle informazioni del libro;
- fornire informazioni libro.
### Sessioni
- creazione sessione;
- eliminazione sessione;
- aggiornamento delle informazioni di una sessione (N.B: is_active);
- fornire informazioni sessione;
- conferma da parte dell'utente di avvenuta lettura.
### Commenti
- aggiunta commento;
- modifica commento; (permettere solo colui che l'ha pubblicato)
- fornire informazioni commento;
- eliminazione commento.

## Implementazione del client

# Risorse utilizzate

- **https://dbdiagram.io/**

**PHP**

- **https://www.php.net/manual/en/mysqli.quickstart.prepared-statements.php**
- **https://www.php.net/manual/en/security.database.sql-injection.php**
- **https://www.php.net/manual/en/wrappers.php.php**
- **https://www.php.net/manual/en/reserved.variables.httpresponseheader.php**
- **https://it.wikipedia.org/wiki/Autenticazione**

# DIARIO

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

Colui che crea il club ne diventa il gestore, ovvero è l'unico in grado di effettuare operazioni relativi alla sua gestione (cancellazione, creazione inviti). Perciò gli script che si occupano di siffatte operazioni verificano che tale utente sia il capo di tale gruppo.

L'invito è un codice alfanumerico univoco formato da otto caratteri utilizzabile soltanto una volta. Le operazioni di creazione e validazione sono analoghe a quelli usati da lato utente, con l'unica differenza che se l'invito è scaduto viene eliminato.

## STEP 3
Implementazione dei servizi delle sessioni. Nulla di rilevante da documentare in quanto le funzioni CRUD sono analoghe a quelle già implementate. Tuttavia, l'unica novità è la funzione "complete" che permette al gestore del gruppo di contrassegnare come completata la sessione.
