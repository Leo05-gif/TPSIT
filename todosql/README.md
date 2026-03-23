# ZKeep

Applicazione todo che usa un database locale SQLite per memorizzare i gruppi e le task. 

# Scelte
- Card per rappresentare sia il gruppo che le task;
- Database:
**todos**
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL,
checked INTEGER NOT NULL,
cardId INTEGER NOT NULL
**cards**
id INTEGER PRIMARY KEY AUTOINCREMENT
