import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'todo_model.dart';
import 'todo_notifier.dart';

class TodoItem extends StatefulWidget {
  TodoItem({required this.todo}) : super(key: ObjectKey(todo));

  final TodoModel todo;

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
      child: Card(
        child: InkWell(
          onLongPress: () => notifier.deleteTodo(widget.todo),
          onTap: () => setState(() => _enabled = true),
          child: Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: widget.todo.checked,
                    onChanged: (value) {
                      notifier.changeTodo(widget.todo);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: _enabled,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'tap here ...',
                      ),
                      onSubmitted: (value) {
                        notifier.changeTitleTodo(widget.todo, value);
                        setState(() => _enabled = false);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
