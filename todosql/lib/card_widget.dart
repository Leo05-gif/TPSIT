import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todosql/todo_notifier.dart';
import 'package:todosql/todo_widget.dart';
import 'package:todosql/card_notifier.dart'; // ← import your CardNotifier

import 'card_model.dart';
import 'helper.dart';
import 'todo_model.dart';

class CardWidget extends StatefulWidget {
  CardWidget({required this.card}) : super(key: ObjectKey(card));

  final CardModel card;

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TodoListNotifier(cardId: widget.card.id!)),
      ],
      child: Builder(
        builder: (context) {
          final todoNotifier = context.watch<TodoListNotifier>();
          final cardNotifier = context.watch<CardNotifier>();

          return Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 5.0),
            child: SizedBox(
              width: 250,
              height: 250,
              child: Card(
                child: InkWell(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () { 
                              cardNotifier.deleteCard(widget.card);
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: todoNotifier.length,
                          itemBuilder: (context, index) {
                            TodoModel todo = todoNotifier.getTodo(index);
                            return TodoItem(todo: todo);
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              todoNotifier.addTodo();
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
