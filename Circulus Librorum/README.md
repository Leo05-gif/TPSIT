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
### Utenti
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

<img width="819" height="1198" alt="database_picture" src="https://github.com/user-attachments/assets/86cfd652-bc80-4c3f-8bd6-d1f7cfb731ca" />

## Implementazione del client

# Risorse utilizzate

- **https://dbdiagram.io/** per disegnare il database.
