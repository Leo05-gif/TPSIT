import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiClient.dart';

class ClubRequests {
  final _h = {"Content-Type": "application/json"};
  String get _base => ApiClient.baseUrl;

  Future<http.Response> create(String token, String name, String description) =>
      ApiClient.post(Uri.parse('$_base/service/club/create'),
          headers: _h,
          body: jsonEncode({"token": token, "name": name, "description": description}));

  Future<http.Response> delete(String token, int id) =>
      ApiClient.delete(Uri.parse('$_base/service/club/delete'),
          headers: _h,
          body: jsonEncode({"token": token, "club_id": id}));

  Future<http.Response> get(String token) =>
      ApiClient.get(
          Uri.parse('$_base/service/club/get')
              .replace(queryParameters: {"token": token}),
          headers: _h);

  Future<http.Response> join(String token, String invite) =>
      ApiClient.post(Uri.parse('$_base/service/club/join'),
          headers: _h,
          body: jsonEncode({"token": token, "invite": invite}));

  Future<http.Response> invite(String token, int id) =>
      ApiClient.post(Uri.parse('$_base/service/club/invite'),
          headers: _h,
          body: jsonEncode({"token": token, "club_id": id}));
}