import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api.dart';

class AuthService {
  // Realiza la solicitud de inicio de sesión al servidor
  // y devuelve los datos del usuario y el token de acceso
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$apiUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login - Código de estado: ${response.statusCode}');
      print('Login - Respuesta: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        final token = data['access_token'];
        final user = data['user'];

        if (token == null || user == null) {
          throw Exception(
            'Respuesta inválida del servidor: token o usuario nulo.',
          );
        }

        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          'Login fallido: ${error['message'] ?? 'Error desconocido'}',
        );
      }
    } catch (e) {
      throw Exception('Error de red o inesperado durante el login: $e');
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$apiUrl/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      print('Registro - Código de estado: ${response.statusCode}');
      print('Registro - Respuesta: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Asumimos que un código 2xx significa éxito (ejemplo: 201 Created)
        final data = jsonDecode(response.body);

        if (data['message'] == null && data['user'] == null) {
          print(
            'Registro - Respuesta exitosa pero estructura de datos inesperada.',
          );
        }

        return data;
      } else {
        // Si el estado no es 2xx, asumimos un error
        final error = jsonDecode(response.body);
        throw Exception(
          'Registro fallido: ${error['message'] ?? 'Error desconocido'}',
        );
      }
    } catch (e) {
      throw Exception('Error de red o inesperado durante el registro: $e');
    }
  }
}
