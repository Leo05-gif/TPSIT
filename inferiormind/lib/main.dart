import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
  final List<Color> _colours = [Colors.red.shade900, Colors.lightBlue.shade900, Colors.amber.shade900, Colors.lightGreen.shade900];
  static int _maxAttempts = 3;

  // BUTTONS RELATED
  List<int> _counters = List.filled(4, 0);
  List<Color> _currentColour = List.filled(4, Colors.blueGrey.shade900);
  List<Color> _sequence = [];

  // TEXT
  final String _attemptsText = "Tentativi Rimasti: ";
  final Color defaultTextColour = Colors.grey.shade600;
  List<String> _guessesText = List.filled(4, "");
  String _statusText = "";

  // FLAGS
  bool _gameOverFlag = false;
  bool _vittoryFlag = false;

  int _attempts = _maxAttempts;

  @override
  void initState() {
    super.initState();
    _sequence = _generateSequence();
  }

  List<Color>  _generateSequence() {
    List<Color> newSequence = [];
    for (var i = 0; i < _colours.length; i++) {
      newSequence.add(_colours[Random().nextInt(_colours.length)]);
    }
    return newSequence;
  }

  void _updateButton(int index) {
    setState(() {
      if (_counters[index] > _colours.length - 1) {
        _counters[index] = 0;
      }
      _currentColour[index] = _colours[_counters[index]];
      _counters[index]++;
    });
  }

  void _checkGameOver() {
    _attempts--;

    for (int i = 0; i < _currentColour.length; i++) {
      if (_currentColour[i].toString() == _sequence[i].toString()) {
        _guessesText[i] = "Corretto";
      } else {
        _guessesText[i] = "Sbagliato";
      }
    }
    if (_currentColour.toString() == _sequence.toString()) {
      _vittoryFlag = true;
    }
    if (_attempts == 0) {
      _gameOverFlag = true;
    }
  }

  void _updateStatusText() {
    setState(() {
      if (_vittoryFlag) {
        _statusText = "Hai Vinto!";
      }
      else if (_gameOverFlag) {
        _statusText = "Hai Perso!";
      }
    });
  }

  void _checkGame() {
    _checkGameOver();
    _updateStatusText();
    if (_vittoryFlag || _gameOverFlag) {
      Future.delayed(Duration(seconds: 2), () {
        _resetGame();
      });
    }
  }

  void _resetGame() {
    setState(() {
      // RESET BUTTONS
      _counters = List.filled(4, 0);
      _currentColour = List.filled(4, Colors.blueGrey.shade900);

      // RESET TEXT
      _guessesText = List.filled(4, "");
      _statusText = "";

      // RESET FLAGS
      _vittoryFlag = false;
      _gameOverFlag = false;

      _attempts = _maxAttempts;
      _sequence = _generateSequence();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: (TextStyle(color: defaultTextColour)),),
        centerTitle: true,
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        _updateButton(0);
                      },
                      backgroundColor: _currentColour[0],
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        _updateButton(1);
                      },
                      backgroundColor: _currentColour[1],
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        _updateButton(2);
                      },
                      backgroundColor: _currentColour[2],
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        _updateButton(3);
                      },
                      backgroundColor: _currentColour[3],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(_guessesText[0], style: (TextStyle(color: defaultTextColour)),),
                    Text(_guessesText[1], style: (TextStyle(color: defaultTextColour)),),
                    Text(_guessesText[2], style: (TextStyle(color: defaultTextColour)),),
                    Text(_guessesText[3], style: (TextStyle(color: defaultTextColour)),),
                  ],
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              _statusText,
              style: (TextStyle(fontSize:24, color: defaultTextColour)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              _attemptsText + _attempts.toString(),
              style: (TextStyle(fontSize:24, color: defaultTextColour)),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!_vittoryFlag && !_gameOverFlag) {
            _checkGame();
          }
        },
        child: Icon(Icons.add_task),
      ),
    );
  }
}