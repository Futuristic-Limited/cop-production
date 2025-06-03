import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  Future<User?> login(String email, String password) async {
    final url = Uri.parse('$apiBaseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data.containsKey('data') && data['data'].containsKey('error')) {
        //print(data['data']['error']);
        //return data['data']['error'];
        return User(error: data['data']['error']);
      }else{
        return User.fromJson(data['data']['user']);
      }

    } else {
      throw Exception('Failed to login: ${data['data']['error']}');//instead of this using exact message from api
    }
  }
}
