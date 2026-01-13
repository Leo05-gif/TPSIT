import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';
import 'notifier.dart';
import 'widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'am043 todo list',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.red)),
      home: ChangeNotifierProvider<TodoListNotifier>(
        create: (notifier) => TodoListNotifier(),
        child: const MyHomePage(title: 'am043 todo list'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final TodoListNotifier notifier = context.watch<TodoListNotifier>();

    return Scaffold(
      appBar: AppBar(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: notifier.length,
          itemBuilder: (context, index) {
            Todo todo = notifier.getTodo(index);
            return TodoItem(todo: todo);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => notifier.addTodo('tap here ...'),
        tooltip: 'add todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
