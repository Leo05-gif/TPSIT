# ZKeep

Applicazione todo che usa un database locale SQLite per memorizzare i gruppi e le task. 

# Scelte
- Card per rappresentare sia il gruppo che le task;
- Utilizzo del ChangeNotifier per gestire l'aggiunta e la rimozione di cards/todos;
- Database:
  
**todos**

id INTEGER PRIMARY KEY AUTOINCREMENT,

name TEXT NOT NULL,

checked INTEGER NOT NULL,

cardId INTEGER NOT NULL

**cards**

id INTEGER PRIMARY KEY AUTOINCREMENT
