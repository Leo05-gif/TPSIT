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

  //StreamController? controller;
  final _controller = StreamController<String>.broadcast();
  Stream<int>? _stream = null;
  late StreamSubscription<int>? _subscription;

  FirstStatus _firstStatus = FirstStatus.START;
  SecondStatus _secondStatus = SecondStatus.PAUSE;

  IconsStatus _firstIcon = IconsStatus.PLAYICON;
  IconsStatus _secondIcon = IconsStatus.PAUSEICON;

  String _timerString = "0:0:0";
  int _seconds = 0;
  bool _keepCounting = true;

  void startTicker() {
    Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_controller.isClosed) {
        _controller.add("tick");
      }
    });
  }

  Stream<int> _secondsGenerator() async* {
    int value = 0;
    await for (final s in _controller.stream) {
      if (_keepCounting) {
        value += 3661;
        yield value;
      }
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
  void initState() {
    super.initState();
    startTicker();
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
        child: Text(_timerString, style: TextStyle(fontFamily: "digital-7", fontSize: 126)),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(onPressed: () {
            switch (_firstStatus) {
              case FirstStatus.START:
                _stream  = _secondsGenerator();
                _subscription = _stream?.listen((onData) {
                  setState(() {
                    _seconds = onData;
                    _timerString = "${_seconds ~/ 3600}:${(_seconds ~/ 60) % 60}:${_seconds % 60}";
                  });
                });
                _firstStatus = FirstStatus.STOP;
                setState(() {
                  _firstIcon = IconsStatus.STOPICON;
                });
                break;

              case FirstStatus.STOP:
                _subscription?.pause();
                _firstStatus = FirstStatus.RESET;
                setState(() {
                  _firstIcon = IconsStatus.RESETICON;
                });
                break;

              case FirstStatus.RESET:
                _subscription?.cancel();
                _stream = null;
                _firstStatus = FirstStatus.START;
                setState(() {
                  _firstIcon = IconsStatus.PLAYICON;
                  _timerString = "0:0:0";
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
                _subscription?.pause();
                _secondStatus = SecondStatus.RESUME;
                setState(() {
                  _secondIcon = IconsStatus.RESUMEICON;
                });
                _keepCounting = false;
                break;

              case SecondStatus.RESUME:
                _subscription?.resume();
                _secondStatus = SecondStatus.PAUSE;
                setState(() {
                  _secondIcon = IconsStatus.PAUSEICON;
                });
                _keepCounting = true;
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