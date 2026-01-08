import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      "https://nubbtodoapi.kode4u.tech/api";

  // REGISTER
  static Future<bool> register(String username, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "action": "register",
        "username": username,
        "password": password,
      }),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }

  // LOGIN
  static Future<bool> login(String username, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "action": "login",
        "username": username,
        "password": password,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["token"]);
      return true;
    }
    return false;
  }

  // GET TODOS (OLD + NEW)
  static Future<List> getTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return [];

    final res = await http.get(
      Uri.parse("$baseUrl/todos.php"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return decoded["todos"] ?? [];
    }
    return [];
  }

  // ADD TODO
  static Future<bool> addTodo({
    required String title,
    required String description,
    required String priority,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return false;

    final res = await http.post(
      Uri.parse("$baseUrl/todos.php"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "title": title,
        "description": description,
        "date": "2026-01-15",
        "priority": priority,
      }),
    );

    return res.statusCode == 200 || res.statusCode == 201;
  }

  // DELETE TODO
  static Future<void> deleteTodo(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    await http.delete(
      Uri.parse("$baseUrl/todos.php"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"id": id}),
    );
  }

  // LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}
