import 'dart:convert';

import 'package:http/http.dart' as http;

class AgenticApiClient {
  AgenticApiClient({String? baseUrl})
      : baseUrl = baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'http://10.0.2.2:8000',
            );

  final String baseUrl;

  Future<Map<String, dynamic>> getSystemState() async {
    final response = await http.get(Uri.parse('$baseUrl/v1/system'));
    _ensureSuccess(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getGoals() async {
    final response = await http.get(Uri.parse('$baseUrl/v1/goals'));
    _ensureSuccess(response);
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createGoal(String objective) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/goals'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'objective': objective,
        'company_id': 'default-company',
        'requires_budget_approval': true,
      }),
    );
    _ensureSuccess(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> setPaused(bool paused) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/emergency-pause'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'paused': paused,
        'reason': paused
            ? 'Emergency Pause activated from Android Control Center'
            : 'Owner resumed system from Android Control Center',
      }),
    );
    _ensureSuccess(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'API ${response.statusCode}: ${response.body.isEmpty ? 'Unknown error' : response.body}',
      );
    }
  }
}
