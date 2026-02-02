import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'todo_model.dart';
import 'card_model.dart';

class DatabaseHelper {
  static Future<Database> init() async {
    String path = join(await getDatabasesPath(), 'todos.db');
    return await openDatabase(path, version: 3, onCreate: _createTables, onUpgrade: _onUpgrade);
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
    CREATE TABLE todos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      checked INTEGER NOT NULL,
      cardId INTEGER NOT NULL
    );
    ''');
    await db.execute('''
    CREATE TABLE cards (
      id INTEGER PRIMARY KEY AUTOINCREMENT
    );
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT
      );
      ''');
    }
  }

  static Future<List<TodoModel>> getTodos() async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 3);
    final List<Map<String, dynamic>> result = await db.query('todos');
    if (result.isEmpty) {
      return <TodoModel>[];
    }
    return result.map((row) => TodoModel.fromMap(row)).toList();
  }

  static Future<void> insertTodo(TodoModel todo) async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 3);
    await db.insert('todos', todo.toMap());
  }

  static Future<void> updateTodo(TodoModel todo) async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 3);
    await db.update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }

  static Future<void> deleteTodo(TodoModel todo) async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 3);
    await db.delete('todos', where: 'id = ?', whereArgs: [todo.id]);
  }

  static Future<List<TodoModel>> getTodosByCard(int cardId) async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 3);
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

  static Future<List<CardModel>> getCards() async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 3);
    final List<Map<String, dynamic>> result = await db.query('cards', orderBy: 'id DESC');
    if (result.isEmpty) {
      return <CardModel>[];
    }
    return result.map((row) => CardModel.fromMap(row)).toList();
  }

  static Future<int> insertCard(CardModel card) async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 3);
    return await db.rawInsert('INSERT INTO cards (id) VALUES (NULL)');
  }

  static Future<void> updateCard(CardModel card) async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 3);
    await db.update('cards', card.toMap(), where: 'id = ?', whereArgs: [card.id]);
  }

  static Future<void> deleteCard(CardModel card) async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 3);
    await db.delete('todos', where: 'cardId = ?', whereArgs: [card.id]);
    await db.delete('cards', where: 'id = ?', whereArgs: [card.id]);
  }

  Future<int> deleteAllTodos() async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 3);
    return await db.delete('todos');
  }

  Future<int> deleteAllCards() async {
    String path = join(await getDatabasesPath(), 'todos.db');
    Database db = await openDatabase(path, version: 3);
    await db.delete('todos');
    return await db.delete('cards');
  }
}