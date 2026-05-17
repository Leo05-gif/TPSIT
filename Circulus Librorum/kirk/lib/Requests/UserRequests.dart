import 'dart:convert';
import 'ApiClient.dart';

class UserRequests {
  final _h = {"Content-Type": "application/json"};
  String get _base => ApiClient.baseUrl;

  Future<dynamic> login(String username, String password) async {
    final res = await ApiClient.post(Uri.parse('$_base/service/user/login'),
        headers: _h,
        body: jsonEncode({"username": username, "password": password}));
    return jsonDecode(res.body);
  }

  Future<dynamic> register(String username, String password) async {
    final res = await ApiClient.post(Uri.parse('$_base/service/user/register'),
        headers: _h,
        body: jsonEncode({"username": username, "password": password}));
    return jsonDecode(res.body);
  }

  Future<dynamic> delete(String token, String password) async {
    final res = await ApiClient.delete(Uri.parse('$_base/service/user/delete'),
        headers: _h,
        body: jsonEncode({"token": token, "password": password}));
    return jsonDecode(res.body);
  }
}