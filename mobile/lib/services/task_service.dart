import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api.dart';
import 'package:flutter/material.dart';

// --- Definición del Estado de la Tarea (Enum) ---
enum TaskStatus { PENDING, IN_PROCESS, COMPLETED }

extension TaskStatusExtension on TaskStatus {
  String toBackendString() {
    switch (this) {
      case TaskStatus.PENDING:
        return 'PENDING';
      case TaskStatus.IN_PROCESS:
        return 'IN_PROCESS';
      case TaskStatus.COMPLETED:
        return 'COMPLETED';
    }
  }

  Color toColor() {
    switch (this) {
      case TaskStatus.PENDING:
        return Colors.red[300]!;
      case TaskStatus.IN_PROCESS:
        return Colors.amber[400]!;
      case TaskStatus.COMPLETED:
        return Colors.green[400]!;
    }
  }

  String toDisplayString() {
    switch (this) {
      case TaskStatus.PENDING:
        return 'Pendiente';
      case TaskStatus.IN_PROCESS:
        return 'En Proceso';
      case TaskStatus.COMPLETED:
        return 'Terminada';
    }
  }
}

TaskStatus taskStatusFromString(String status) {
  switch (status.toUpperCase()) {
    case 'PENDING':
      return TaskStatus.PENDING;
    case 'IN_PROCESS':
      return TaskStatus.IN_PROCESS;
    case 'COMPLETED':
      return TaskStatus.COMPLETED;
    default:
      print('Advertencia: Estado desconocido "$status". Asignado PENDING.');
      return TaskStatus.PENDING;
  }
}

// --- Modelo de Tarea ---
class Task {
  final String id;
  String title;
  String description;
  TaskStatus status;
  final DateTime createdAt;
  DateTime? updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: taskStatusFromString(json['status'] ?? 'PENDING'),
      createdAt: DateTime.parse(json['createdat'] ?? json['createdAt']),
      updatedAt: json['updatedat'] != null
          ? DateTime.parse(json['updatedat'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description.isNotEmpty ? description : null,
      'status': status.toBackendString(),
    };
  }

  void updateStatus(TaskStatus newStatus) {
    status = newStatus;
  }
}

// --- AuthService ---
class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$apiUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login - Código: ${response.statusCode}');
      print('Login - Respuesta: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        final token = data['access_token'];
        final user = data['user'];

        if (token == null || user == null) {
          throw Exception('Token o usuario nulo en la respuesta.');
        }

        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          'Login fallido: ${error['message'] ?? 'Error desconocido'}',
        );
      }
    } catch (e) {
      throw Exception('Error durante login: $e');
    }
  }
}

// --- TaskService ---
class TaskService {
  final String _authToken;

  TaskService(this._authToken);

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_authToken',
    };
  }

  // Obtener todas las tareas
  Future<List<Task>> fetchTasks() async {
    final url = Uri.parse('$apiUrl/task');
    try {
      final response = await http.get(url, headers: _getHeaders());

      print('Fetch Tasks - Código: ${response.statusCode}');
      print('Fetch Tasks - Respuesta: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> taskJsonList = jsonDecode(response.body);
        return taskJsonList.map((json) => Task.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          'Error al cargar tareas: ${error['message'] ?? 'Error desconocido'}',
        );
      }
    } catch (e) {
      throw Exception('Error al cargar tareas: $e');
    }
  }

  // Crear tarea
  Future<Task> createTask(
    String title,
    String description,
    TaskStatus status,
  ) async {
    final url = Uri.parse('$apiUrl/task');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'title': title,
          'description': description.isNotEmpty ? description : null,
          'status': status.toBackendString(),
        }),
      );

      print('Create Task - Código: ${response.statusCode}');
      print('Create Task - Respuesta: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Task.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          'Error al crear tarea: ${error['message'] ?? 'Error desconocido'}',
        );
      }
    } catch (e) {
      throw Exception('Error al crear tarea: $e');
    }
  }

  // Actualizar tarea
  Future<Task> updateTask(
    String taskId, {
    String? title,
    String? description,
    TaskStatus? status,
  }) async {
    final url = Uri.parse('$apiUrl/task/$taskId');
    final Map<String, dynamic> body = {};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (status != null) body['status'] = status.toBackendString();

    try {
      final response = await http.patch(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      print('Update Task - Código: ${response.statusCode}');
      print('Update Task - Respuesta: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Task.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          'Error al actualizar tarea: ${error['message'] ?? 'Error desconocido'}',
        );
      }
    } catch (e) {
      throw Exception('Error al actualizar tarea: $e');
    }
  }

  // Eliminar tarea
  Future<void> deleteTask(String taskId) async {
    final url = Uri.parse('$apiUrl/task/$taskId');
    try {
      final response = await http.delete(url, headers: _getHeaders());

      print('Delete Task - Código: ${response.statusCode}');
      print('Delete Task - Respuesta: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          'Error al eliminar tarea: ${error['message'] ?? 'Error desconocido'}',
        );
      }
    } catch (e) {
      throw Exception('Error al eliminar tarea: $e');
    }
  }

  // Marcar tarea como completada
  Future<Task> markTaskAsCompleted(String taskId) {
    return updateTask(taskId, status: TaskStatus.COMPLETED);
  }
}
