import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiClient.dart';

class TurnRequests {
  final _h = {"Content-Type": "application/json"};
  String get _base => ApiClient.baseUrl;

  Future<http.Response> create(String token, int clubId, int sessionId, String from, String till) =>
      ApiClient.post(Uri.parse('$_base/service/turn/create'),
          headers: _h,
          body: jsonEncode({"token": token, "club_id": clubId, "session_id": sessionId, "from": from, "till": till}));

  Future<http.Response> delete(String token, int clubId, int turnId) =>
      ApiClient.delete(Uri.parse('$_base/service/turn/delete'),
          headers: _h,
          body: jsonEncode({"token": token, "club_id": clubId, "turn_id": turnId}));

  Future<http.Response> get(String token, int sessionId) =>
      ApiClient.get(
          Uri.parse('$_base/service/turn/get')
              .replace(queryParameters: {"token": token, "session_id": sessionId.toString()}),
          headers: _h);

  Future<http.Response> complete(String token, int clubId, int turnId, int value) =>
      ApiClient.put(Uri.parse('$_base/service/turn/complete'),
          headers: _h,
          body: jsonEncode({"token": token, "club_id": clubId, "turn_id": turnId, "value": value}));
}