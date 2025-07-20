import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<User>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => User.fromJson({
          'id': json['id'].toString(),
          'name': json['name'],
          'email': json['email'],
          'profileImage': null,
        })).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<User?> getUserById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$id'));
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return User.fromJson({
          'id': json['id'].toString(),
          'name': json['name'],
          'email': json['email'],
          'profileImage': null,
        });
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<User?> createUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toJson()),
      );
      
      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return User.fromJson({
          'id': json['id'].toString(),
          'name': json['name'],
          'email': json['email'],
          'profileImage': json['profileImage'],
        });
      } else {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<User?> updateUser(User user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/${user.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toJson()),
      );
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return User.fromJson({
          'id': json['id'].toString(),
          'name': json['name'],
          'email': json['email'],
          'profileImage': json['profileImage'],
        });
      } else {
        throw Exception('Failed to update user');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/users/$id'));
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}