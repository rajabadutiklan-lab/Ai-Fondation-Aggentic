import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  static const _companiesKey = 'agentic_companies_v1';
  static const _connectorsKey = 'agentic_connectors_v1';
  static const _contactsKey = 'agentic_contacts_v1';
  static const _approvalsKey = 'agentic_approvals_v1';
  static const _pausedKey = 'agentic_paused_v1';

  Future<List<Map<String, dynamic>>> loadCompanies() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_companiesKey);
    if (raw == null || raw.isEmpty) return _defaultCompanies();
    return _decodeList(raw);
  }

  Future<void> saveCompanies(List<Map<String, dynamic>> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_companiesKey, jsonEncode(value));
  }

  Future<List<Map<String, dynamic>>> loadConnectors() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_connectorsKey);
    if (raw == null || raw.isEmpty) return _defaultConnectors();
    return _decodeList(raw);
  }

  Future<void> saveConnectors(List<Map<String, dynamic>> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_connectorsKey, jsonEncode(value));
  }

  Future<List<Map<String, dynamic>>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_contactsKey);
    if (raw == null || raw.isEmpty) return _defaultContacts();
    return _decodeList(raw);
  }

  Future<void> saveContacts(List<Map<String, dynamic>> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_contactsKey, jsonEncode(value));
  }

  Future<List<Map<String, dynamic>>> loadApprovals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_approvalsKey);
    if (raw == null || raw.isEmpty) return _defaultApprovals();
    return _decodeList(raw);
  }

  Future<void> saveApprovals(List<Map<String, dynamic>> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_approvalsKey, jsonEncode(value));
  }

  Future<bool> loadPaused() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pausedKey) ?? false;
  }

  Future<void> savePaused(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pausedKey, value);
  }

  List<Map<String, dynamic>> _decodeList(String raw) {
    final value = jsonDecode(raw) as List<dynamic>;
    return value.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  List<Map<String, dynamic>> _defaultCompanies() => [
        {
          'id': 'rajabadut',
          'name': 'RajaBadut',
          'objective': 'Lead, SEO, penjualan dan operasional otomatis',
          'divisions': _defaultDivisions(),
        },
      ];

  List<Map<String, dynamic>> _defaultConnectors() => [
        {
          'id': 'website-rajabadut',
          'company_id': 'rajabadut',
          'kind': 'website',
          'name': 'Website RajaBadut',
          'endpoint': 'https://rajabadut.com',
          'api_key': '',
          'status': 'configured',
        },
        {
          'id': 'github',
          'company_id': 'rajabadut',
          'kind': 'github',
          'name': 'GitHub',
          'endpoint': '',
          'api_key': '',
          'status': 'configured',
        },
        {
          'id': 'whatsapp',
          'company_id': 'rajabadut',
          'kind': 'whatsapp',
          'name': 'WhatsApp',
          'endpoint': '',
          'api_key': '',
          'status': 'needs_config',
        },
      ];

  List<Map<String, dynamic>> _defaultContacts() => [
        {
          'id': 'lead-1',
          'company_id': 'rajabadut',
          'name': 'Contoh Lead',
          'phone': '08xxxxxxxxxx',
          'source': 'Website',
          'tag': 'Prospek',
        },
      ];

  List<Map<String, dynamic>> _defaultApprovals() => [
        {
          'id': 'approval-domain',
          'company_id': 'rajabadut',
          'title': 'Pembelian domain / hosting',
          'detail': 'Estimasi Rp350.000',
          'risk': 'high',
          'status': 'pending',
        },
        {
          'id': 'approval-campaign',
          'company_id': 'rajabadut',
          'title': 'Publikasi campaign ke channel eksternal',
          'detail': 'Perlu persetujuan sebelum dipublikasikan',
          'risk': 'medium',
          'status': 'pending',
        },
      ];

  List<Map<String, dynamic>> _defaultDivisions() => [
        {'id': 'website', 'name': 'Website', 'icon': 'language'},
        {'id': 'seo', 'name': 'SEO', 'icon': 'search'},
        {'id': 'social', 'name': 'Social Media', 'icon': 'campaign'},
        {'id': 'marketing', 'name': 'Marketing', 'icon': 'ads_click'},
        {'id': 'crm', 'name': 'CRM & Sales', 'icon': 'contacts'},
        {'id': 'whatsapp', 'name': 'WhatsApp', 'icon': 'chat'},
        {'id': 'finance', 'name': 'Finance', 'icon': 'account_balance_wallet'},
        {'id': 'analytics', 'name': 'Analytics', 'icon': 'insights'},
        {'id': 'creative', 'name': 'Creative', 'icon': 'palette'},
        {'id': 'automation', 'name': 'Automation', 'icon': 'hub'},
      ];
}
