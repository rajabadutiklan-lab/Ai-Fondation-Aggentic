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

  Future<Map<String, dynamic>> getDashboard() => _getMap('/v1/dashboard');
  Future<Map<String, dynamic>> getSystemState() => _getMap('/v1/system');
  Future<List<dynamic>> getGoals() => _getList('/v1/goals');
  Future<List<dynamic>> getCompanies() => _getList('/v1/companies');
  Future<List<dynamic>> getApprovals() => _getList('/v1/approvals?status=pending');
  Future<List<dynamic>> getConnectors() => _getList('/v1/connectors');
  Future<List<dynamic>> getConnectorCatalog() => _getList('/v1/connectors/catalog');
  Future<List<dynamic>> getImprovements() => _getList('/v1/improvements');
  Future<List<dynamic>> getAudit() => _getList('/v1/audit?limit=50');
  Future<List<dynamic>> getProviders() => _getList('/v1/ai/providers');

  Future<Map<String, dynamic>> createGoal(String objective) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/goals'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'objective': objective,
        'company_id': 'default-company',
        'requires_budget_approval': false,
      }),
    );
    _ensureSuccess(response);
    final goal = jsonDecode(response.body) as Map<String, dynamic>;
    final goalId = '${goal['id']}';
    if (goalId.isNotEmpty) {
      await planGoal(goalId);
    }
    return goal;
  }

  Future<Map<String, dynamic>> planGoal(String goalId) =>
      _postMap('/v1/goals/$goalId/plan', const {});

  Future<Map<String, dynamic>> setPaused(bool paused) => _postMap(
        '/v1/emergency-pause',
        {
          'paused': paused,
          'reason': paused
              ? 'Emergency Pause activated from Android Control Center'
              : 'Owner resumed system from Android Control Center',
        },
      );

  Future<Map<String, dynamic>> decideApproval(
    String approvalId,
    bool approved,
  ) =>
      _postMap(
        '/v1/approvals/$approvalId/decision',
        {
          'approved': approved,
          'note': approved
              ? 'Approved from Android Control Center'
              : 'Rejected from Android Control Center',
        },
      );

  Future<Map<String, dynamic>> bootstrapCompany(String companyId) =>
      _postMap('/v1/companies/$companyId/bootstrap', const {});

  Future<Map<String, dynamic>> createCompany({
    required String name,
    required String slug,
    String objective = '',
  }) =>
      _postMap(
        '/v1/companies',
        {
          'name': name,
          'slug': slug,
          'objective': objective,
          'monthly_budget': 0,
        },
      );

  Future<Map<String, dynamic>> createConnector({
    required String companyId,
    required String kind,
    required String name,
    String endpoint = '',
    String authMode = 'api_key',
    String credentialRef = '',
  }) =>
      _postMap(
        '/v1/connectors',
        {
          'company_id': companyId,
          'kind': kind,
          'name': name,
          'endpoint': endpoint,
          'auth_mode': authMode,
          'credential_ref': credentialRef,
          'scopes': ['read', 'write'],
          'enabled': true,
        },
      );

  Future<Map<String, dynamic>> checkConnector(String connectorId) =>
      _postMap('/v1/connectors/$connectorId/check', const {});

  Future<Map<String, dynamic>> decideImprovement(
    String proposalId,
    bool approved,
  ) =>
      _postMap(
        '/v1/improvements/$proposalId/decision',
        {'approved': approved},
      );

  Future<Map<String, dynamic>> _getMap(String path) async {
    final response = await http.get(Uri.parse('$baseUrl$path'));
    _ensureSuccess(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> _getList(String path) async {
    final response = await http.get(Uri.parse('$baseUrl$path'));
    _ensureSuccess(response);
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> _postMap(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );
    _ensureSuccess(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Map<String, String> get _jsonHeaders => const {'Content-Type': 'application/json'};

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'API ${response.statusCode}: ${response.body.isEmpty ? 'Unknown error' : response.body}',
      );
    }
  }
}
