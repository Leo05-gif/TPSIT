import 'dart:convert';

import 'package:http/http.dart' as http;

class UserRequests {
  Future<dynamic> login(String username, String password) async {
    try {
      var url = Uri.parse('http://10.34.157.239:8000/service/user/login');

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<dynamic> register(String username, String password) async {
    try {
      var url = Uri.parse('http://10.34.157.239:8000/service/user/register');
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
      var url = Uri.parse('http://10.34.157.239:8000/service/user/delete');

      var response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token, "password": password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception(e);
    }
  }
}
