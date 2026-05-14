import 'dart:convert';

import 'package:http/http.dart' as http;

class UserRequests {
  Future<dynamic> login(String username, String password) async {
    try {
      var url = Uri.parse('http://localhost:8000/service/user/login');
      print("Sending request to: $url");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<dynamic> register(String username, String password) async {
    try {
      var url = Uri.parse('http://localhost:8000/service/user/register');
      print("Sending request to: $url");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<dynamic> delete(String token, String password) async {
    try {
      var url = Uri.parse('http://localhost:8000/service/user/delete');
      print("Sending request to: $url");

      var response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token, "password": password}),
      );
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception(e);
    }
  }
}
