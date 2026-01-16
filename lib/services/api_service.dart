import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// ignore_for_file: avoid_print
class ApiService {
  // ================= BASE URL =================
  static const String baseUrl =
      'https://nubbtodoapi.kode4u.tech/api';

  // ================= TOKEN STORAGE =================
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

static Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
}

  // ================= AUTH =================
  static Future<bool> register(
      String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'register',
          'username': username,
          'password': password,
        }),
      );
      
      print('REGISTER STATUS => ${res.statusCode}');
      print('REGISTER BODY => ${res.body}');

      return res.statusCode == 200;
    } catch (e) {
      print('REGISTER ERROR => $e');
      return false;
    }
  }

  static Future<bool> login(
      String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'login',
          'username': username,
          'password': password,
        }),
      );

      print('LOGIN STATUS => ${res.statusCode}');
      print('LOGIN BODY => ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data['token'] != null) {
          await saveToken(data['token']);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('LOGIN ERROR => $e');
      return false;
    }
  }

  // ================= TODOS =================
 static Future<List<dynamic>> getTodos() async {
  final token = await getToken();

  final res = await http.get(
    Uri.parse('$baseUrl/todos.php'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  print('GET TODOS STATUS => ${res.statusCode}');
  print('GET TODOS BODY => ${res.body}');

  if (res.statusCode == 200) {
    final decoded = jsonDecode(res.body);

    if (decoded is Map && decoded['data'] is List) {
      return decoded['data']; 
    } else {
      return [];
    }
  } else {
    throw Exception('Failed to load todos');
  }
}

  static Future<void> addTodo(Map<String, dynamic> body) async {
    final token = await getToken();

    final res = await http.post(
      Uri.parse('$baseUrl/todos.php'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('ADD TODO STATUS => ${res.statusCode}');
    print('ADD TODO BODY => ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed to add todo');
    }
  }

  static Future<void> updateTodo(
      Map<String, dynamic> body) async {
    final token = await getToken();

    final res = await http.put(
      Uri.parse('$baseUrl/todos.php'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('UPDATE TODO STATUS => ${res.statusCode}');
    print('UPDATE TODO BODY => ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed to update todo');
    }
  }

  static Future<void> deleteTodo(int id) async {
    final token = await getToken();

    final res = await http.delete(
      Uri.parse('$baseUrl/todos.php'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'id': id}),
    );

    print('DELETE TODO STATUS => ${res.statusCode}');
    print('DELETE TODO BODY => ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed to delete todo');
    }
  }

  // ================= FUTURE: RESTORE =================
  
  static Future<void> restoreTodo(int id) async {
    final token = await getToken();

    await http.post(
      Uri.parse('$baseUrl/todos.php?action=restore'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'id': id}),
    );
  }
  
}
