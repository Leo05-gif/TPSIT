import 'package:http/http.dart' as http;

const _kTimeout = Duration(seconds: 6);

class ApiClient {
  static String baseUrl = '';

  static Future<http.Response> get(Uri url,
          {Map<String, String>? headers}) =>
      http.get(url, headers: headers).timeout(_kTimeout);

  static Future<http.Response> post(Uri url,
          {Map<String, String>? headers, Object? body}) =>
      http.post(url, headers: headers, body: body).timeout(_kTimeout);

  static Future<http.Response> put(Uri url,
          {Map<String, String>? headers, Object? body}) =>
      http.put(url, headers: headers, body: body).timeout(_kTimeout);

  static Future<http.Response> delete(Uri url,
          {Map<String, String>? headers, Object? body}) =>
      http.delete(url, headers: headers, body: body).timeout(_kTimeout);
}