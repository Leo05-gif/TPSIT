import 'dart:async';
import 'package:flutter/material.dart';

enum FirstStatus { START, STOP, RESET }
enum SecondStatus { PAUSE, RESUME }

enum  IconsStatus { PLAYICON, STOPICON, RESETICON, PAUSEICON, RESUMEICON }

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


  FirstStatus _firstStatus = FirstStatus.START;
  SecondStatus _secondStatus = SecondStatus.PAUSE;

  IconsStatus _firstIcon = IconsStatus.PLAYICON;
  IconsStatus _secondIcon = IconsStatus.PAUSEICON;

  String _timerString = "";
  int _seconds = 0;

  Stream<int> _secondGenerator(Stream<String> tick) async* {
    int value = 0;
    await for (final s in tick) {
      value += 3661;
      yield value;
    }
  }

  IconData _getIcon(IconsStatus icon) {
    switch (icon) {
      case IconsStatus.PLAYICON:
        return Icons.play_arrow;
      case IconsStatus.STOPICON:
        return Icons.stop;
      case IconsStatus.RESETICON:
        return Icons.refresh;
      case IconsStatus.PAUSEICON:
        return Icons.pause;
      case IconsStatus.RESUMEICON:
        return Icons.play_arrow;
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
        child: Text("${_seconds ~/ 3600}:${(_seconds ~/ 60) % 60}:${_seconds % 60}", style: TextStyle(fontFamily: "digital-7", fontSize: 126),),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(onPressed: () {
            switch (_firstStatus) {
              case FirstStatus.START:
                stream  = _secondGenerator(tickGen);
                subscription = stream?.listen((onData) {
                  setState(() {
                    _seconds = onData;
                  });
                });
                _firstStatus = FirstStatus.STOP;
                setState(() {
                  _firstIcon = IconsStatus.STOPICON;
                });
                break;

              case FirstStatus.STOP:
                subscription?.pause();
                _firstStatus = FirstStatus.RESET;
                setState(() {
                  _firstIcon = IconsStatus.RESETICON;
                });
                break;

              case FirstStatus.RESET:
                subscription?.cancel();
                stream = null;
                _firstStatus = FirstStatus.START;
                setState(() {
                  _firstIcon = IconsStatus.PLAYICON;

                });
                break;
            }
          },
          child: Icon(_getIcon(_firstIcon)),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(onPressed: () {

            switch (_secondStatus) {
              case SecondStatus.PAUSE:
                subscription?.pause();
                _secondStatus = SecondStatus.RESUME;
                setState(() {
                  _secondIcon = IconsStatus.RESUMEICON;
                });
                break;

              case SecondStatus.RESUME:
                subscription?.resume();
                _secondStatus = SecondStatus.PAUSE;
                setState(() {
                  _secondIcon = IconsStatus.PAUSEICON;
                });
                break;
            }
          },
          child: Icon(_getIcon(_secondIcon)),
          )
        ],
      ),
    );
  }
}