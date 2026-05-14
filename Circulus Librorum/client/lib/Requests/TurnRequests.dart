import 'dart:convert';

import 'package:http/http.dart' as http;

class TurnRequests {
  Future<http.Response> create(
    String token,
    int clubId,
    int sessionId,
    String from,
    String till,
  ) async {
    try {
      var url = Uri.parse('http://localhost:8000/service/turn/create');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "club_id": clubId,
          "session_id": sessionId,
          "from": from,
          "till": till,
        }),
      );
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<http.Response> delete(String token, int clubId, int turnId) async {
    try {
      var url = Uri.parse('http://localhost:8000/service/turn/delete');
      var response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "club_id": clubId,
          "turn_id": turnId,
        }),
      );
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<http.Response> get(String token, int sessionId) async {
    try {
      var url = Uri.parse('http://localhost:8000/service/turn/get').replace(
        queryParameters: {"token": token, "session_id": sessionId.toString()},
      );
      var response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<http.Response> complete(
    String token,
    int clubId,
    int turnId,
    int value,
  ) async {
    try {
      var url = Uri.parse('http://localhost:8000/service/turn/complete');
      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "club_id": clubId,
          "turn_id": turnId,
          "value": value,
        }),
      );
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }
}
