# Todo App 
Piccola applicazione per tener conto delle attività da svolgere. Modifica del esempio su gitlab [am032_todo_list](https://gitlab.com/divino.marchese/flutter/-/tree/master/am032_todo_list?ref_type=heads)

# Scelte
- Un todo consiste in un Card, composta da una InkWell per rilevare il tocco, una Checkbox per segnare il completamento e una TextField;
- Il FloatingActionButton si occupa di aggiungere nuovi todo;
- All'inizializzazione del programma l'attributo text del TextEditingController del TextField viene assegnato al titolo del todo;
- Il TextField è disabilitato, per abilitarlo e permettere la digitazione è necessario cliccare lo InkWell, ovvero il singolo todo che appare a schermo. Inoltre ha come hintText "tap here ...";
- Ho modificato la classe TodoListNotifier aggiungendo la funzione void changeTitleTodo(Todo todo, String newTitle);
