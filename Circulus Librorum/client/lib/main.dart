import 'dart:convert';
import 'package:client/ClubRequests.dart';
import 'package:client/UserRequests.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  try {
    ClubRequests c = ClubRequests();
    var response = await c.get(
      "528461af3e8d52f0fdf141cff3cb5c10df76e4a1baf88e80da9e543c4cb2c97518eced56fb70f19da11a0486f9a561bdbcddb63a82b705fa4040156201aef60d",
    );

    switch (response.statusCode) {
      case 200:
      case 201:
        print("Status: ${response.statusCode}");
        break;
      case 404:
        print("Status: 404");
        break;
      case 405:
        print("Status: 405 - Method not allowed");
        break;
      case 406:
        print("Status: 406");
        break;
      default:
        print("Status: ${response.statusCode}");
    }

    if (jsonDecode(response.body)['success']) {
      print('Success: true');
      print(response.body);
    } else {
      print('Success: false');
    }
  } catch (e) {
    print(e);
  }
}
