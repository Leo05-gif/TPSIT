import 'dart:convert';

import 'package:http/http.dart' as http;

class SessionRequests {
  Future<http.Response> create(
    String token,
    int clubId,
    String bookTitle,
    String description,
  ) async {
    try {
      var url = Uri.parse('http://localhost:8000/service/session/create');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "club_id": clubId,
          "book_title": bookTitle,
          "description": description,
        }),
      );
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<http.Response> delete(String token, int clubId, int sessionId) async {
    try {
      var url = Uri.parse('http://localhost:8000/service/session/delete');
      var response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "club_id": clubId,
          "session_id": sessionId,
        }),
      );
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<http.Response> get(String token, int clubId) async {
    try {
      var url = Uri.parse('http://localhost:8000/service/session/get').replace(
        queryParameters: {"token": token, "club_id": clubId.toString()},
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
    int sessionId,
    int value,
  ) async {
    try {
      var url = Uri.parse('http://localhost:8000/service/session/complete');
      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "club_id": clubId,
          "session_id": sessionId,
          "value": value,
        }),
      );
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }
}
