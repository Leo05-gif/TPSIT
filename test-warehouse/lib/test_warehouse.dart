import 'dart:convert';

import 'package:http/http.dart' as http;

Future<void> main() async {
  var url = Uri.parse('http://127.0.0.1:3000/products');
  var response = await http.get(url);
  print(response.body);
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
  print(responsebella.body);
  print(responsebella.statusCode);
}