import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';
import 'todo_notifier.dart';

class TodoItem extends StatefulWidget {
  TodoItem({required this.todo}) : super(key: ObjectKey(todo));

  final Todo todo;

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  final TextEditingController _controller = TextEditingController();
  bool _enabled = false;

  @override
  void initState() {
    _controller.text = widget.todo.name;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TodoListNotifier notifier = context.watch<TodoListNotifier>();

    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: Container(
        width: 250,
        height: 250,
        child: Card(
          child: InkWell(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [BackButton()],
                ),
                TextField(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
