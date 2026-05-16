import 'dart:convert';

import 'package:http/http.dart' as http;

class ClubRequests {
  Future<http.Response> create(
    String token,
    String name,
    String description,
  ) async {
    try {
      var url = Uri.parse('http://10.34.157.239:8000/service/club/create');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "name": name,
          "description": description,
        }),
      );
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<http.Response> delete(String token, int id) async {
    try {
      var url = Uri.parse('http://10.34.157.239:8000/service/club/delete');
      var response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token, "club_id": id}),
      );
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<http.Response> get(String token) async {
    try {
      var url = Uri.parse(
        'http://10.34.157.239:8000/service/club/get',
      ).replace(queryParameters: {"token": token});
      var response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<http.Response> join(String token, String invite) async {
    try {
      var url = Uri.parse('http://10.34.157.239:8000/service/club/join');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token, "invite": invite}),
      );
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<http.Response> invite(String token, int id) async {
    try {
      var url = Uri.parse('http://10.34.157.239:8000/service/club/invite');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token, "club_id": id}),
      );
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }
}
