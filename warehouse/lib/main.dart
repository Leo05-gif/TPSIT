import 'package:flutter/material.dart';

import 'model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  List<Product> products = [
    Product(
      name: 'product1',
      description: 'description1',
      category: 'categoria1',
      price: 1,
      n: 1,
    ),
    Product(
      name: 'product2',
      description: 'description2',
      category: 'categoria2',
      price: 1,
      n: 1,
    ),
    Product(
      name: 'product3',
      description: 'description3',
      category: 'categoria3',
      price: 1,
      n: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                Text(products[index].name),
                Text(products[index].description),
                Text(products[index].category),
                Text(products[index].price.toString()),
                Text(products[index].n.toString()),
              ],
            ),
          );
        },
      ),
    );
  }
}
