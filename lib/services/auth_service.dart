import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class AuthService {
  final String apiUrl = "http://127.0.0.1:8000/api/login"; // Replace with your backend URL

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']; // Assuming token is returned
        final userId = data['user_id']; // Assuming user_id is returned

        // Store the token and userId in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setInt('user_id', userId);

        return {'token': token, 'user_id': userId};
      } else {
        print("Login failed: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to login. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred during login: $e");
      throw Exception("Error during login: $e");
    }
  }

  Future<int?> getUserId() async {
    // Retrieve the user ID from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id'); // Return the stored user_id
  }

  Future<String?> getToken() async {
    // Retrieve the token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Return the stored token
  }

  Future<bool> isLoggedIn() async {
    // Check if the user is logged in by checking if the token exists in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }
}