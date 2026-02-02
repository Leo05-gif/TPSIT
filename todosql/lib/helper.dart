import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todosql/todo_model.dart';

class DatabaseHelper {
  static Future<Database> init() async {
    // get path
    String path = join(await getDatabasesPath(), 'todos.db');

    // open/create the database
    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  static Future<void> _createTable(Database db, int version) async {
    await db.execute('''
    CREATE TABLE todos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      checked INTEGER NOT NULL,
      cardId INTEGER NOT NULL
    );
  ''');
  }


  static Future<List<TodoModel>> getTodos() async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 1);
    /*
    final List<Map<String, dynamic>> result = await db.rawQuery(
       'SELECT * FROM todos',
    );
    */
    final List<Map<String, dynamic>> result = await db.query('todos');
    if (result.isEmpty) {
      return <TodoModel>[];
    }
    // db.close();
    return result.map((row) => TodoModel.fromMap(row)).toList();
  }

  static Future<void> insertTodo(TodoModel todo) async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 1);
    // db.rawInsert('INSERT INTO todos(name, checked) values (?, ?)', [todo.name, todo.checked ? 1 : 0]);
    db.insert('todos', todo.toMap());
    // db.close();
  }

  static Future<void> updateTodo(TodoModel todo) async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 1);
    // do not check existence!
    // db.rawUpdate('UPDATE todos SET value = ? WHERE id = ?', [todo.checked ? 0 : 1, todo.id]);
    db.update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
    // db.close();
  }

  static Future<void> deleteTodo(TodoModel todo) async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 1);
    db.delete('todos', where: 'id = ?', whereArgs: [todo.id]);
    // db.close();
  }

  Future<int> deleteAll() async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 1);
    return await db.delete('todos');
  }

  static Future<List<TodoModel>> getTodosByCard(int cardId) async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 1);

    final List<Map<String, dynamic>> result = await db.query(
      'todos',
      where: 'cardId = ?',
      whereArgs: [cardId],
      orderBy: 'checked DESC, id DESC',
    );

    if (result.isEmpty) {
      return <TodoModel>[];
    }

    return result.map((row) => TodoModel.fromMap(row)).toList();
  }
}
