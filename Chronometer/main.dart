import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

enum firstStatus { START, STOP, RESET }
enum secondStatus { PAUSE, RESUME }

Stream<int> secondGenerator(Stream<String> tick) async* {
  int value = 0;
  await for (final s in tick) {
    value += 3661;
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
      title: 'CHRONOMETER', 
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(title: 'CHRONOMETER'),
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

  late StreamSubscription<int>? secondSub;

  firstStatus _firstStatus = firstStatus.START;
  secondStatus _secondStatus = secondStatus.PAUSE;

  String timerString = "";
  int seconds = 0;

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
        child: Text("${seconds ~/ 3600}:${(seconds ~/ 60) % 60}:${seconds % 60}"),
      ),
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(onPressed: () {

              switch (_firstStatus) {
                case firstStatus.START:
                  var secondGen = secondGenerator(tickGenerator(Duration(seconds: 1)));
                  secondSub = secondGen.listen((onData) {
                    setState(() {
                      seconds = onData;
                    });
                  });
                  _firstStatus = firstStatus.STOP;
                case firstStatus.STOP:
                  secondSub?.cancel();
                  _firstStatus = firstStatus.RESET;
                case firstStatus.RESET:
                  secondSub = null;
                  _firstStatus = firstStatus.START;
              }

            }),
            const SizedBox(width: 20),
            FloatingActionButton(onPressed: () {
              switch (_secondStatus) {
                case secondStatus.PAUSE:
                  secondSub?.pause();
                  _secondStatus = secondStatus.RESUME;
                case secondStatus.RESUME:
                  secondSub?.resume();
                  _secondStatus = secondStatus.PAUSE;
              }
            })
          ],
      ),
    );
  }
}
