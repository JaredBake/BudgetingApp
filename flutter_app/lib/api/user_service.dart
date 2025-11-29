import 'dart:convert';

import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'base_url.dart'; 
class UserService {
  static String baseUrl = BaseUrl.getUrl();

  static Future<bool> changePassword(String newPassword) async {

    final token = localStorage.getItem('token');
    final userId = localStorage.getItem('userId');

    final jsonBody = jsonEncode({
      "Id": userId,
      'password': newPassword
    });

    final url = Uri.parse('$baseUrl/api/Users/Password');

    final passwordPut = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonBody
    );

    if (passwordPut.statusCode == 201) {
      print('Password changed successfully');
      return true;
    }
    else {
      print('Needs further testing: user_service.dart/ln:25');
      return false;
    }    
  }

  static Future<bool> deleteUser() async {
    final token = localStorage.getItem('token');
    final userId = localStorage.getItem('userId');

    final url = Uri.parse('$baseUrl/api/Users/$userId');

    final userDelete = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (userDelete.statusCode == 200) {
      localStorage.clear();
      print('User deleted successfully!');
      return true;
    } 

    print('Needs further testing: user_service.dart/ln58');
    return false;
  }
}