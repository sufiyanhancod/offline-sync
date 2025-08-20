import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/features/offline_sync/models/models.dart';

// API Service (using JSONPlaceholder as dummy API)
class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  final http.Client _client = http.Client();

  Future<List<Task>> getTasks() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/todos'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        return data.take(10).map((item) {
          final Map<String, dynamic> itemMap = item as Map<String, dynamic>;
          return Task(
            uuid: itemMap['id'].toString(),
            title: itemMap['title'] as String,
            description: 'Task from server',
            isCompleted: itemMap['completed'] as bool,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }).toList();
      }
      throw Exception('Failed to load tasks');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/todos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 201) {
        return task; // JSONPlaceholder returns created item
      }
      throw Exception('Failed to create task');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/todos/1'), // Using dummy ID
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 200) {
        return task;
      }
      throw Exception('Failed to update task');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteTask(String uuid) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/todos/1'), // Using dummy ID
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
