import 'dart:convert';

import 'package:http/http.dart' as http;

import 'Product.dart';

Future<void> main() async {
  var url = Uri.parse('http://127.0.0.1:3000/products');
  var response = await http.get(url);
  print(response.statusCode);
  var responsebella = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "name": "palla",
      "description": "bianca",
      "category": "oggetto",
      "price": 12,
      "n": 1
    }),
  );

  var data = jsonDecode(response.body);
  List<Product> lista = [];

  for (var product in data) {
    lista.add(Product.fromMap(product));
  }

  print(lista[0].price);


}