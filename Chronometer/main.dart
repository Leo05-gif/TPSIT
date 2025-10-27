import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

enum firstStatus { START, STOP, RESET }
enum secondStatus { PAUSE, RESUME }

Stream<int> secondGenerator(Stream<String> tick) async* {
  int value = 0;
  await for (final s in tick) {
    value++;
    yield value;
  }
}

Stream<String> tickGenerator(Duration inverval) async* {
  while (true) {
    await Future.delayed(inverval);
    yield "tick";
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INFERIOR MIND',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(title: 'INFERIOR MIND'),
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

  //var secondGen = secondGenerator(tickGenerator(Duration(seconds: 1)));
  late StreamSubscription<int>? secondSub;

  var _firstStatus = firstStatus.START;
  var _secondStatus = secondStatus.PAUSE;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: (TextStyle(color: Colors.red)),),
        centerTitle: true,
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
      ),
      body: Center(
      ),
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(onPressed: () {
              switch (_firstStatus) {
                case firstStatus.START:
                  var secondGen = secondGenerator(tickGenerator(Duration(seconds: 1)));
                  secondSub = secondGen.listen((onData) {
                    print(onData);
                  });
                  _firstStatus = firstStatus.STOP;
                case firstStatus.STOP:
                  secondSub?.pause();
                  _firstStatus = firstStatus.RESET;
                case firstStatus.RESET:
                  secondSub?.cancel();
                  secondSub = null;
                  _firstStatus = firstStatus.START;
              }
            }),
            const SizedBox(width: 20),
            FloatingActionButton(onPressed: () {
              switch (_secondStatus) {
                case secondStatus.PAUSE:
                  print("pause");
                  _secondStatus = secondStatus.RESUME;
                case secondStatus.RESUME:
                  print("resume");
                  _secondStatus = secondStatus.PAUSE;
              }
            })
          ],
      ),
    );
  }
}
