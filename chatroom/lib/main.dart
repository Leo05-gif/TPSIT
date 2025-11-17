import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHATROOM',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(title: 'CHATROOM'),
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

  var testo = <Text>[];

  @override
  void initState() {
    super.initState();
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
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10.0),
              color: Colors.amber[600],
              width: 500,
              height: 500,
              alignment: Alignment.center,
              child: ListView.builder(
                itemCount: testo.length,
                itemBuilder: (context, int index) {
                  return testo[index];
                },
              ),
            ),
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        setState(() {
          testo.add(Text("data", style: TextStyle(fontSize: 24)));
        });
      }),
    );
  }
}