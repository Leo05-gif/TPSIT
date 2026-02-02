import 'package:flutter/widgets.dart';
import 'todo_model.dart';
import 'helper.dart';

class TodoListNotifier extends ChangeNotifier {
  final int cardId;
  final List<TodoModel> _todos = [];

  TodoListNotifier({required this.cardId}) {
    _init();
  }

  int get length => _todos.length;

  TodoModel getTodo(int index) => _todos[index];

  Future<void> _init() async {
    await DatabaseHelper.init();
    await _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await DatabaseHelper.getTodosByCard(cardId);
    _todos
      ..clear()
      ..addAll(todos);
    notifyListeners();
  }

  Future<void> addTodo([String name = '']) async {
    final todo = TodoModel(
      id: null,
      name: name,
      checked: false,
      cardId: cardId,
    );

    _todos.insert(0, todo);
    notifyListeners();

    await DatabaseHelper.insertTodo(todo);
  }

  Future<void> changeTodo(TodoModel todo) async {
    todo.checked = !todo.checked;

    _todos.remove(todo);
    if (!todo.checked) {
      _todos.add(todo);
    } else {
      _todos.insert(0, todo);
    }

    notifyListeners();
    await DatabaseHelper.updateTodo(todo);
  }

  Future<void> changeTitleTodo(TodoModel todo, String newTitle) async {
    todo.name = newTitle;
    notifyListeners();
    await DatabaseHelper.updateTodo(todo);
  }

  Future<void> deleteTodo(TodoModel todo) async {
    _todos.remove(todo);
    notifyListeners();
    await DatabaseHelper.deleteTodo(todo);
  }
}
