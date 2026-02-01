import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todosql/card_notifier.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      home: ChangeNotifierProvider<CardNotifier>(
        create: (notifier) => CardNotifier(),
        child: const MyHomePage(title: 'Todo List'),
      ),
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
  @override
  Widget build(BuildContext context) {
    final CardNotifier notifier = context.watch<CardNotifier>();

    return Scaffold(
      appBar: AppBar(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        title: Text(widget.title),
      ),
      body: Center(
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: notifier.length,
          itemBuilder: (context, index) {
            final card = notifier.getCard(index);
            return card;
          },
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => notifier.addCard(),
        tooltip: 'add card',
        child: const Icon(Icons.add),
      ),
    );
  }
}
