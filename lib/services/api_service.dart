import 'dart:convert';
import 'package:http/http.dart' as http;

/// Serviço para comunicação com APIs externas
class ApiService {
  final String _baseUrl = 'https://api.example.com'; // URL base fictícia
  final http.Client _httpClient;

  ApiService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();
  
  /// Realiza uma requisição GET para a API
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao realizar requisição: $e');
    }
  }
  
  /// Realiza uma requisição POST para a API
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao realizar requisição: $e');
    }
  }
  
  /// Método para liberar recursos
  void dispose() {
    _httpClient.close();
  }
} 