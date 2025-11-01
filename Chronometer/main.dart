import 'dart:async';
import 'package:flutter/material.dart';

enum firstStatus { START, STOP, RESET }
enum secondStatus { PAUSE, RESUME }

void main() {
  runApp(const MyApp());
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

  Stream<String> tickGen = Stream<String>.periodic(const Duration(seconds:  1), (_)  => "tick").asBroadcastStream();

  StreamController? controller;
  Stream<int>? stream = null;
  late StreamSubscription<int>? subscription;


  firstStatus _firstStatus = firstStatus.START;
  secondStatus _secondStatus = secondStatus.PAUSE;

  String timerString = "";
  int seconds = 0;

  Stream<int> secondGenerator(Stream<String> tick) async* {
    int value = 0;
    await for (final s in tick) {
      value += 3661;
      yield value;
    }
  }

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
                stream  = secondGenerator(tickGen);
                subscription = stream?.listen((onData) {
                  setState(() {
                    seconds = onData;
                  });
                });
                _firstStatus = firstStatus.STOP;
                break;

              case firstStatus.STOP:
                subscription?.pause();
                _firstStatus = firstStatus.RESET;
                break;

              case firstStatus.RESET:
                subscription?.cancel();
                stream = null;
                _firstStatus = firstStatus.START;
                break;
            }

          }),
          const SizedBox(width: 20),
          FloatingActionButton(onPressed: () {

            switch (_secondStatus) {
              case secondStatus.PAUSE:
                subscription?.pause();
                _secondStatus = secondStatus.RESUME;
                break;

              case secondStatus.RESUME:
                subscription?.resume();
                _secondStatus = secondStatus.PAUSE;
                break;
            }
          })
        ],
      ),
    );
  }
}