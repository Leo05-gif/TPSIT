import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiClient.dart';

class SessionRequests {
  final _h = {"Content-Type": "application/json"};
  String get _base => ApiClient.baseUrl;

  Future<http.Response> create(String token, int clubId, String bookTitle, String description) =>
      ApiClient.post(Uri.parse('$_base/service/session/create'),
          headers: _h,
          body: jsonEncode({"token": token, "club_id": clubId, "book_title": bookTitle, "description": description}));

  Future<http.Response> delete(String token, int clubId, int sessionId) =>
      ApiClient.delete(Uri.parse('$_base/service/session/delete'),
          headers: _h,
          body: jsonEncode({"token": token, "club_id": clubId, "session_id": sessionId}));

  Future<http.Response> get(String token, int clubId) =>
      ApiClient.get(
          Uri.parse('$_base/service/session/get')
              .replace(queryParameters: {"token": token, "club_id": clubId.toString()}),
          headers: _h);

  Future<http.Response> complete(String token, int clubId, int sessionId, int value) =>
      ApiClient.put(Uri.parse('$_base/service/session/complete'),
          headers: _h,
          body: jsonEncode({"token": token, "club_id": clubId, "session_id": sessionId, "value": value}));
}