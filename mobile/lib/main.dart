import 'package:flutter/material.dart';

import 'services/api_client.dart';
import 'services/local_store.dart';

void main() {
  runApp(const AgenticControlCenterApp());
}

const _brand = Color(0xffe8493f);
const _brand2 = Color(0xffff6b48);
const _ink = Color(0xff27323e);
const _muted = Color(0xff7f8792);
const _page = Color(0xfff4f6f8);
const _line = Color(0xffe8ebef);

class AgenticControlCenterApp extends StatelessWidget {
  const AgenticControlCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Foundation Agentic',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _page,
        colorScheme: ColorScheme.fromSeed(seedColor: _brand),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xfff6f7f9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _brand, width: 1.4),
          ),
        ),
      ),
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  final _api = AgenticApiClient();
  final _store = LocalStore();
  int _index = 0;
  bool _loading = true;
  bool _online = false;
  bool _paused = false;
  List<Map<String, dynamic>> _companies = [];
  List<Map<String, dynamic>> _connectors = [];
  List<Map<String, dynamic>> _contacts = [];
  List<Map<String, dynamic>> _approvals = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final companies = await _store.loadCompanies();
    final connectors = await _store.loadConnectors();
    final contacts = await _store.loadContacts();
    final approvals = await _store.loadApprovals();
    final paused = await _store.loadPaused();
    bool online = false;
    try {
      await _api.getSystemState();
      online = true;
    } catch (_) {
      online = false;
    }
    if (!mounted) return;
    setState(() {
      _companies = companies;
      _connectors = connectors;
      _contacts = contacts;
      _approvals = approvals;
      _paused = paused;
      _online = online;
      _loading = false;
    });
  }

  Future<void> _saveCompanies() => _store.saveCompanies(_companies);
  Future<void> _saveConnectors() => _store.saveConnectors(_connectors);
  Future<void> _saveContacts() => _store.saveContacts(_contacts);
  Future<void> _saveApprovals() => _store.saveApprovals(_approvals);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = <Widget>[
      HomePage(
        online: _online,
        paused: _paused,
        companies: _companies,
        connectors: _connectors,
        contacts: _contacts,
        approvals: _approvals,
        onOpenTab: (index) => setState(() => _index = index),
        onOpenCompany: _openCompany,
        onGoal: _submitGoal,
      ),
      CompaniesPage(
        companies: _companies,
        online: _online,
        onAdd: _addCompany,
        onOpen: _openCompany,
      ),
      ApprovalsPage(
        approvals: _approvals,
        online: _online,
        onDecision: _decideApproval,
      ),
      ConnectorsPage(
        connectors: _connectors,
        companies: _companies,
        online: _online,
        onAdd: _addConnector,
        onEdit: _editConnector,
      ),
      SystemPage(
        online: _online,
        paused: _paused,
        companyCount: _companies.length,
        connectorCount: _connectors.length,
        onPauseChanged: _setPaused,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onTap: (value) => setState(() => _index = value),
      ),
    );
  }

  Future<void> _submitGoal(String text) async {
    if (text.trim().isEmpty) return;
    if (_online) {
      try {
        await _api.createGoal(text.trim());
        if (!mounted) return;
        _toast('Tujuan dikirim ke AI Pusat.');
        return;
      } catch (_) {}
    }
    if (!mounted) return;
    _toast('Tujuan disimpan di mode offline. Akan disinkronkan saat VPS aktif.');
  }

  Future<void> _setPaused(bool value) async {
    setState(() => _paused = value);
    await _store.savePaused(value);
    if (_online) {
      try {
        await _api.setPaused(value);
      } catch (_) {}
    }
  }

  Future<void> _addCompany() async {
    final name = TextEditingController();
    final objective = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Perusahaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(hintText: 'Nama perusahaan')),
            const SizedBox(height: 10),
            TextField(controller: objective, maxLines: 3, decoration: const InputDecoration(hintText: 'Tujuan utama bisnis')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (ok != true || name.text.trim().isEmpty) return;
    final id = _slug(name.text);
    final company = {
      'id': id,
      'name': name.text.trim(),
      'objective': objective.text.trim().isEmpty ? 'Workspace bisnis siap diatur' : objective.text.trim(),
      'divisions': _divisionTemplate(),
    };
    setState(() => _companies = [..._companies, company]);
    await _saveCompanies();
    if (_online) {
      try {
        await _api.createCompany(name: '${company['name']}', slug: id, objective: '${company['objective']}');
      } catch (_) {}
    }
  }

  void _openCompany(Map<String, dynamic> company) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CompanyWorkspacePage(
          company: company,
          connectors: _connectors,
          contacts: _contacts,
          online: _online,
          onAddConnector: (companyId, kind) => _addConnector(companyId: companyId, initialKind: kind),
          onEditConnector: _editConnector,
          onContactsChanged: (value) async {
            setState(() => _contacts = value);
            await _saveContacts();
          },
        ),
      ),
    );
  }

  Future<void> _addConnector({String? companyId, String? initialKind}) async {
    final result = await _connectorDialog(
      companyId: companyId ?? (_companies.isEmpty ? 'default-company' : '${_companies.first['id']}'),
      initialKind: initialKind ?? 'website',
    );
    if (result == null) return;
    setState(() => _connectors = [..._connectors, result]);
    await _saveConnectors();
  }

  Future<void> _editConnector(Map<String, dynamic> current) async {
    final result = await _connectorDialog(
      companyId: '${current['company_id']}',
      initialKind: '${current['kind']}',
      current: current,
    );
    if (result == null) return;
    setState(() {
      _connectors = _connectors.map((item) => item['id'] == current['id'] ? result : item).toList();
    });
    await _saveConnectors();
  }

  Future<Map<String, dynamic>?> _connectorDialog({
    required String companyId,
    required String initialKind,
    Map<String, dynamic>? current,
  }) async {
    String kind = initialKind;
    final name = TextEditingController(text: '${current?['name'] ?? ''}');
    final endpoint = TextEditingController(text: '${current?['endpoint'] ?? ''}');
    final key = TextEditingController(text: '${current?['api_key'] ?? ''}');
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(current == null ? 'Tambah Konektor / API' : 'Edit Konektor / API'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: kind,
                  items: _connectorKinds.map((item) => DropdownMenuItem(value: item.$1, child: Text(item.$2))).toList(),
                  onChanged: (value) => setDialogState(() => kind = value ?? kind),
                  decoration: const InputDecoration(labelText: 'Jenis'),
                ),
                const SizedBox(height: 10),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama akun / konektor')),
                const SizedBox(height: 10),
                TextField(controller: endpoint, decoration: const InputDecoration(labelText: 'Website / Endpoint / Username')),
                const SizedBox(height: 10),
                TextField(
                  controller: key,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'API Key / Token / Credential'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mode offline: data konfigurasi disimpan di HP. Saat VPS aktif, credential akan dipindah ke vault server.',
                  style: TextStyle(fontSize: 12, color: _muted, height: 1.35),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                final label = name.text.trim().isEmpty ? _connectorName(kind) : name.text.trim();
                Navigator.pop(context, {
                  'id': current?['id'] ?? '${kind}_${DateTime.now().millisecondsSinceEpoch}',
                  'company_id': companyId,
                  'kind': kind,
                  'name': label,
                  'endpoint': endpoint.text.trim(),
                  'api_key': key.text,
                  'status': key.text.trim().isNotEmpty || endpoint.text.trim().isNotEmpty ? 'configured' : 'needs_config',
                });
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    key.clear();
    return result;
  }

  Future<void> _decideApproval(Map<String, dynamic> approval, bool approved) async {
    setState(() {
      _approvals = _approvals.map((item) {
        if (item['id'] != approval['id']) return item;
        return {...item, 'status': approved ? 'approved' : 'rejected'};
      }).toList();
    });
    await _saveApprovals();
    if (_online) {
      try {
        await _api.decideApproval('${approval['id']}', approved);
      } catch (_) {}
    }
  }

  String _slug(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.online,
    required this.paused,
    required this.companies,
    required this.connectors,
    required this.contacts,
    required this.approvals,
    required this.onOpenTab,
    required this.onOpenCompany,
    required this.onGoal,
  });

  final bool online;
  final bool paused;
  final List<Map<String, dynamic>> companies;
  final List<Map<String, dynamic>> connectors;
  final List<Map<String, dynamic>> contacts;
  final List<Map<String, dynamic>> approvals;
  final ValueChanged<int> onOpenTab;
  final ValueChanged<Map<String, dynamic>> onOpenCompany;
  final ValueChanged<String> onGoal;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _goal = TextEditingController();

  @override
  void dispose() {
    _goal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = widget.approvals.where((item) => item['status'] == 'pending').length;
    return _PageBody(
      header: const _AgenticHeader(home: true, title: 'AI FOUNDATION', subtitle: 'Business Control Center'),
      children: [
        _StatusStrip(online: widget.online, paused: widget.paused),
        const SizedBox(height: 14),
        _HomeGrid(
          items: [
            _GridData(Icons.business_center_outlined, 'Perusahaan', '${widget.companies.length} workspace', () => widget.onOpenTab(1)),
            _GridData(Icons.verified_user_outlined, 'Approval', '$pending menunggu', () => widget.onOpenTab(2)),
            _GridData(Icons.cable_outlined, 'Konektor', '${widget.connectors.length} terpasang', () => widget.onOpenTab(3)),
            _GridData(Icons.contacts_outlined, 'Database', '${widget.contacts.length} kontak', () {
              if (widget.companies.isNotEmpty) widget.onOpenCompany(widget.companies.first);
            }),
          ],
        ),
        const SizedBox(height: 14),
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Perintahkan AI Pusat', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
              const SizedBox(height: 6),
              const Text('Tulis tujuan bisnis. Sistem akan membagi tugas ke company, divisi dan specialist yang tepat.', style: TextStyle(color: _muted, height: 1.35)),
              const SizedBox(height: 12),
              TextField(
                controller: _goal,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Contoh: buat usaha kitchen set dari nol sampai siap jual'),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    widget.onGoal(_goal.text);
                    _goal.clear();
                  },
                  icon: const Icon(Icons.arrow_upward_rounded),
                  label: const Text('Kirim Tujuan'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (widget.companies.isNotEmpty)
          _SectionCard(
            onTap: () => widget.onOpenCompany(widget.companies.first),
            child: Row(
              children: [
                const _IconBox(icon: Icons.apartment_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${widget.companies.first['name']}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
                      const SizedBox(height: 3),
                      Text('${widget.companies.first['objective']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: _muted),
              ],
            ),
          ),
      ],
    );
  }
}

class CompaniesPage extends StatelessWidget {
  const CompaniesPage({super.key, required this.companies, required this.online, required this.onAdd, required this.onOpen});
  final List<Map<String, dynamic>> companies;
  final bool online;
  final VoidCallback onAdd;
  final ValueChanged<Map<String, dynamic>> onOpen;

  @override
  Widget build(BuildContext context) {
    return _PageBody(
      header: _AgenticHeader(title: 'PERUSAHAAN', subtitle: 'Company Agent & digital office', action: onAdd, actionIcon: Icons.add_rounded),
      children: [
        _StatusStrip(online: online, compact: true),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: Text('${companies.length} company workspace', style: const TextStyle(fontWeight: FontWeight.w700, color: _ink))),
            TextButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Tambah')),
          ],
        ),
        const SizedBox(height: 6),
        ...companies.map((company) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SectionCard(
                onTap: () => onOpen(company),
                child: Row(
                  children: [
                    const _IconBox(icon: Icons.apartment_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${company['name']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _ink)),
                          const SizedBox(height: 4),
                          Text('${company['objective']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, height: 1.35)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: _muted),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class CompanyWorkspacePage extends StatefulWidget {
  const CompanyWorkspacePage({
    super.key,
    required this.company,
    required this.connectors,
    required this.contacts,
    required this.online,
    required this.onAddConnector,
    required this.onEditConnector,
    required this.onContactsChanged,
  });
  final Map<String, dynamic> company;
  final List<Map<String, dynamic>> connectors;
  final List<Map<String, dynamic>> contacts;
  final bool online;
  final Future<void> Function(String companyId, String kind) onAddConnector;
  final Future<void> Function(Map<String, dynamic>) onEditConnector;
  final ValueChanged<List<Map<String, dynamic>>> onContactsChanged;

  @override
  State<CompanyWorkspacePage> createState() => _CompanyWorkspacePageState();
}

class _CompanyWorkspacePageState extends State<CompanyWorkspacePage> {
  @override
  Widget build(BuildContext context) {
    final id = '${widget.company['id']}';
    final divisions = (widget.company['divisions'] as List<dynamic>? ?? []).map((item) => Map<String, dynamic>.from(item as Map)).toList();
    final connectors = widget.connectors.where((item) => item['company_id'] == id).toList();
    final contacts = widget.contacts.where((item) => item['company_id'] == id).toList();
    return Scaffold(
      body: _PageBody(
        header: _AgenticHeader(title: '${widget.company['name']}'.toUpperCase(), subtitle: 'Company Agent', back: true),
        children: [
          _StatusStrip(online: widget.online, compact: true),
          const SizedBox(height: 14),
          _HomeGrid(
            items: [
              _GridData(Icons.account_tree_outlined, 'Divisi', '${divisions.length} divisi', () => _openDivisions(divisions)),
              _GridData(Icons.key_rounded, 'Konektor & API', '${connectors.length} akun', () => _openConnectors(connectors)),
              _GridData(Icons.storage_rounded, 'Database & Scraping', '${contacts.length} kontak', () => _openDatabase(contacts)),
              _GridData(Icons.smart_toy_outlined, 'Task & Agent', 'Worker otomatis', _openTasks),
              _GridData(Icons.account_balance_wallet_outlined, 'Budget', 'Kontrol biaya', _placeholder),
              _GridData(Icons.insights_outlined, 'Analitik', 'KPI & hasil', _placeholder),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tujuan Perusahaan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: _ink)),
                const SizedBox(height: 6),
                Text('${widget.company['objective']}', style: const TextStyle(color: _muted, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDivisions(List<Map<String, dynamic>> divisions) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DivisionsPage(company: widget.company, divisions: divisions)));
  }

  void _openConnectors(List<Map<String, dynamic>> connectors) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompanyConnectorsPage(
          company: widget.company,
          connectors: connectors,
          onAdd: widget.onAddConnector,
          onEdit: widget.onEditConnector,
        ),
      ),
    );
  }

  void _openDatabase(List<Map<String, dynamic>> contacts) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DatabaseScrapingPage(
          company: widget.company,
          allContacts: widget.contacts,
          companyContacts: contacts,
          onChanged: widget.onContactsChanged,
        ),
      ),
    );
  }

  void _openTasks() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SimpleListPage(title: 'TASK & AGENT', items: const [
      ('Goal Planner', 'Memecah tujuan menjadi task'),
      ('Task Queue', 'Antrean kerja otomatis'),
      ('Worker / Automation', 'Pekerjaan rutin tanpa AI mahal'),
      ('Specialist Agent', 'Pekerjaan yang butuh reasoning'),
      ('Approval Gate', 'Menahan aksi berisiko'),
    ])));
  }

  void _placeholder() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu aktif. Data online akan muncul saat VPS tersambung.')));
}

class DivisionsPage extends StatelessWidget {
  const DivisionsPage({super.key, required this.company, required this.divisions});
  final Map<String, dynamic> company;
  final List<Map<String, dynamic>> divisions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _PageBody(
        header: const _AgenticHeader(title: 'DIVISI', subtitle: 'Manager & specialist', back: true),
        children: [
          ...divisions.map((division) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SectionCard(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DivisionDetailPage(company: company, division: division))),
                  child: Row(
                    children: [
                      _IconBox(icon: _iconForDivision('${division['id']}')),
                      const SizedBox(width: 12),
                      Expanded(child: Text('${division['name']}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink))),
                      const Icon(Icons.chevron_right_rounded, color: _muted),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class DivisionDetailPage extends StatelessWidget {
  const DivisionDetailPage({super.key, required this.company, required this.division});
  final Map<String, dynamic> company;
  final Map<String, dynamic> division;

  @override
  Widget build(BuildContext context) {
    final divisionId = '${division['id']}';
    final specialists = _specialistsFor(divisionId);
    return Scaffold(
      body: _PageBody(
        header: _AgenticHeader(title: '${division['name']}'.toUpperCase(), subtitle: '${company['name']} • Division Manager', back: true),
        children: [
          const Text('Specialist Agent', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
          const SizedBox(height: 10),
          ...specialists.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _SectionCard(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.$1} siap menerima task.'))),
                  child: Row(
                    children: [
                      const _IconBox(icon: Icons.smart_toy_outlined),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700, color: _ink)),
                        const SizedBox(height: 3),
                        Text(item.$2, style: const TextStyle(color: _muted)),
                      ])),
                      const Icon(Icons.chevron_right_rounded, color: _muted),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class CompanyConnectorsPage extends StatelessWidget {
  const CompanyConnectorsPage({super.key, required this.company, required this.connectors, required this.onAdd, required this.onEdit});
  final Map<String, dynamic> company;
  final List<Map<String, dynamic>> connectors;
  final Future<void> Function(String companyId, String kind) onAdd;
  final Future<void> Function(Map<String, dynamic>) onEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _PageBody(
        header: const _AgenticHeader(title: 'KONEKTOR & API', subtitle: 'Akun, website dan credential', back: true),
        children: [
          _ConnectorCatalogGrid(
            onTap: (kind) async {
              await onAdd('${company['id']}', kind);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
          const Text('Terpasang', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
          const SizedBox(height: 8),
          if (connectors.isEmpty)
            const _EmptyCard(text: 'Belum ada konektor. Pilih salah satu di atas.')
          else
            ...connectors.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _ConnectorRow(item: item, onTap: () => onEdit(item)),
                )),
        ],
      ),
    );
  }
}

class DatabaseScrapingPage extends StatefulWidget {
  const DatabaseScrapingPage({super.key, required this.company, required this.allContacts, required this.companyContacts, required this.onChanged});
  final Map<String, dynamic> company;
  final List<Map<String, dynamic>> allContacts;
  final List<Map<String, dynamic>> companyContacts;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  @override
  State<DatabaseScrapingPage> createState() => _DatabaseScrapingPageState();
}

class _DatabaseScrapingPageState extends State<DatabaseScrapingPage> {
  late List<Map<String, dynamic>> _contacts;
  final List<String> _sources = ['Google Maps', 'Website publik'];

  @override
  void initState() {
    super.initState();
    _contacts = [...widget.companyContacts];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _PageBody(
        header: const _AgenticHeader(title: 'DATABASE & SCRAPING', subtitle: 'Kontak, lead dan sumber data', back: true),
        children: [
          _HomeGrid(items: [
            _GridData(Icons.person_add_alt_1_rounded, 'Tambah Kontak', 'Manual', _addContact),
            _GridData(Icons.travel_explore_rounded, 'Target Scraping', '${_sources.length} sumber', _addSource),
            _GridData(Icons.file_upload_outlined, 'Import Data', 'CSV / Excel', _importInfo),
            _GridData(Icons.cleaning_services_outlined, 'Bersihkan Data', 'Duplikat & format', _cleanData),
          ]),
          const SizedBox(height: 16),
          const Text('Database Kontak', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
          const SizedBox(height: 8),
          ..._contacts.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SectionCard(
                  child: Row(children: [
                    const _IconBox(icon: Icons.person_outline_rounded),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${item['name']}', style: const TextStyle(fontWeight: FontWeight.w700, color: _ink)),
                      Text('${item['phone']} • ${item['source']}', style: const TextStyle(color: _muted, fontSize: 13)),
                    ])),
                    Text('${item['tag']}', style: const TextStyle(color: _brand, fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
              )),
          const SizedBox(height: 10),
          const Text('Sumber Scraping', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
          const SizedBox(height: 8),
          ..._sources.map((source) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SectionCard(child: Row(children: [const Icon(Icons.public_rounded, color: _brand), const SizedBox(width: 10), Expanded(child: Text(source, style: const TextStyle(fontWeight: FontWeight.w600))), const Text('Siap', style: TextStyle(color: _muted))])),
              )),
        ],
      ),
    );
  }

  Future<void> _addContact() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final source = TextEditingController(text: 'Manual');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kontak'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama')),
          const SizedBox(height: 10),
          TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'No. WhatsApp / HP')),
          const SizedBox(height: 10),
          TextField(controller: source, decoration: const InputDecoration(labelText: 'Sumber')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (ok != true || phone.text.trim().isEmpty) return;
    final contact = {
      'id': 'contact_${DateTime.now().millisecondsSinceEpoch}',
      'company_id': '${widget.company['id']}',
      'name': name.text.trim().isEmpty ? 'Tanpa Nama' : name.text.trim(),
      'phone': phone.text.trim(),
      'source': source.text.trim(),
      'tag': 'Prospek',
    };
    setState(() => _contacts = [..._contacts, contact]);
    final others = widget.allContacts.where((item) => item['company_id'] != widget.company['id']).toList();
    widget.onChanged([...others, ..._contacts]);
  }

  Future<void> _addSource() async {
    final source = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Target Scraping'),
        content: TextField(controller: source, decoration: const InputDecoration(hintText: 'Contoh: Google Maps jasa dekorasi Bekasi')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (ok == true && source.text.trim().isNotEmpty) setState(() => _sources.add(source.text.trim()));
  }

  void _importInfo() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import data aktif sebagai menu offline. File picker akan disambungkan pada build berikutnya.')));

  void _cleanData() {
    final seen = <String>{};
    setState(() {
      _contacts = _contacts.where((item) => seen.add('${item['phone']}')).toList();
    });
    final others = widget.allContacts.where((item) => item['company_id'] != widget.company['id']).toList();
    widget.onChanged([...others, ..._contacts]);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data duplikat berdasarkan nomor HP sudah dibersihkan.')));
  }
}

class ApprovalsPage extends StatelessWidget {
  const ApprovalsPage({super.key, required this.approvals, required this.online, required this.onDecision});
  final List<Map<String, dynamic>> approvals;
  final bool online;
  final void Function(Map<String, dynamic>, bool) onDecision;

  @override
  Widget build(BuildContext context) {
    final pending = approvals.where((item) => item['status'] == 'pending').toList();
    return _PageBody(
      header: const _AgenticHeader(title: 'APPROVAL', subtitle: 'Biaya & aksi berisiko'),
      children: [
        _StatusStrip(online: online, compact: true),
        const SizedBox(height: 14),
        Text('${pending.length} menunggu keputusan', style: const TextStyle(fontWeight: FontWeight.w700, color: _ink)),
        const SizedBox(height: 8),
        if (pending.isEmpty)
          const _EmptyCard(text: 'Tidak ada approval yang menunggu.')
        else
          ...pending.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.priority_high_rounded, color: _brand),
                        const SizedBox(width: 8),
                        Expanded(child: Text('${item['title']}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink))),
                      ]),
                      const SizedBox(height: 8),
                      Text('Risiko: ${item['risk']} • ${item['detail']}', style: const TextStyle(color: _muted)),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: OutlinedButton(onPressed: () => onDecision(item, false), child: const Text('Tolak'))),
                        const SizedBox(width: 10),
                        Expanded(child: FilledButton(onPressed: () => onDecision(item, true), child: const Text('Setujui'))),
                      ]),
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}

class ConnectorsPage extends StatelessWidget {
  const ConnectorsPage({super.key, required this.connectors, required this.companies, required this.online, required this.onAdd, required this.onEdit});
  final List<Map<String, dynamic>> connectors;
  final List<Map<String, dynamic>> companies;
  final bool online;
  final Future<void> Function({String? companyId, String? initialKind}) onAdd;
  final Future<void> Function(Map<String, dynamic>) onEdit;

  @override
  Widget build(BuildContext context) {
    return _PageBody(
      header: _AgenticHeader(title: 'KONEKTOR', subtitle: 'Website, API, social, domain & VPS', action: () => onAdd(), actionIcon: Icons.add_rounded),
      children: [
        _StatusStrip(online: online, compact: true),
        const SizedBox(height: 14),
        _ConnectorCatalogGrid(onTap: (kind) => onAdd(initialKind: kind)),
        const SizedBox(height: 16),
        const Text('Konektor Tersimpan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
        const SizedBox(height: 8),
        ...connectors.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _ConnectorRow(item: item, onTap: () => onEdit(item)),
            )),
      ],
    );
  }
}

class SystemPage extends StatelessWidget {
  const SystemPage({super.key, required this.online, required this.paused, required this.companyCount, required this.connectorCount, required this.onPauseChanged});
  final bool online;
  final bool paused;
  final int companyCount;
  final int connectorCount;
  final ValueChanged<bool> onPauseChanged;

  @override
  Widget build(BuildContext context) {
    return _PageBody(
      header: const _AgenticHeader(title: 'SISTEM AI', subtitle: 'Otak pusat, keamanan & otomatisasi'),
      children: [
        _StatusStrip(online: online, paused: paused),
        const SizedBox(height: 14),
        _HomeGrid(items: [
          _GridData(Icons.psychology_alt_outlined, 'AI Router', 'Model sesuai tugas', () => _info(context, 'AI Router memilih model sesuai biaya, risiko dan kompleksitas.')),
          _GridData(Icons.memory_outlined, 'Memory', 'Knowledge bisnis', () => _info(context, 'Memory menyimpan pengalaman, SOP, hasil eksperimen dan konteks perusahaan.')),
          _GridData(Icons.auto_fix_high_outlined, 'Self-Improve', 'Perbaikan sistem', () => _info(context, 'Perubahan sistem diuji dulu sebelum diterapkan.')),
          _GridData(Icons.history_rounded, 'Audit Log', 'Semua aksi tercatat', () => _info(context, 'Audit Log akan menampilkan siapa/agent apa yang melakukan setiap aksi.')),
        ]),
        const SizedBox(height: 14),
        _SectionCard(
          child: Row(children: [
            const _IconBox(icon: Icons.pause_circle_outline_rounded),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Emergency Pause', style: TextStyle(fontWeight: FontWeight.w700, color: _ink)),
              Text(paused ? 'AI dijeda. Menu tetap bisa dipakai.' : 'AI berjalan. Tekan jika perlu berhenti.', style: const TextStyle(color: _muted)),
            ])),
            Switch(value: paused, onChanged: onPauseChanged),
          ]),
        ),
        const SizedBox(height: 10),
        _SectionCard(child: Row(children: [const Icon(Icons.apartment_outlined, color: _brand), const SizedBox(width: 10), Expanded(child: Text('$companyCount perusahaan • $connectorCount konektor', style: const TextStyle(fontWeight: FontWeight.w600, color: _ink)))])),
      ],
    );
  }

  void _info(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

class SimpleListPage extends StatelessWidget {
  const SimpleListPage({super.key, required this.title, required this.items});
  final String title;
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _PageBody(
        header: _AgenticHeader(title: title, subtitle: 'Company workspace', back: true),
        children: items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: _SectionCard(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.$1} dibuka.'))),
            child: Row(children: [const _IconBox(icon: Icons.smart_toy_outlined), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700, color: _ink)), Text(item.$2, style: const TextStyle(color: _muted))])), const Icon(Icons.chevron_right_rounded, color: _muted)]),
          ),
        )).toList(),
      ),
    );
  }
}

class _PageBody extends StatelessWidget {
  const _PageBody({required this.header, required this.children});
  final Widget header;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xfffbfcfd), Color(0xfff4f6f8)]),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: header),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(15, 16, 15, 28),
            sliver: SliverList(delegate: SliverChildListDelegate(children)),
          ),
        ],
      ),
    );
  }
}

class _AgenticHeader extends StatelessWidget {
  const _AgenticHeader({required this.title, required this.subtitle, this.action, this.actionIcon, this.back = false, this.home = false});
  final String title;
  final String subtitle;
  final VoidCallback? action;
  final IconData? actionIcon;
  final bool back;
  final bool home;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: top + 84,
      child: Stack(children: [
        const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_brand2, _brand])))),
        const Positioned.fill(child: CustomPaint(painter: _HeaderPatternPainter())),
        Positioned(
          left: 15,
          right: 15,
          top: top + 10,
          height: 64,
          child: Row(children: [
            _HeaderSquare(
              onTap: back ? () => Navigator.pop(context) : null,
              child: Icon(back ? Icons.arrow_back_rounded : home ? Icons.hub_rounded : _headerIcon(title), color: _brand, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w700, height: 1.05)),
              const SizedBox(height: 4),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xfffee9e6), fontSize: 13)),
            ])),
            if (action != null) _HeaderSquare(onTap: action, child: Icon(actionIcon ?? Icons.refresh_rounded, color: _brand, size: 24)),
          ]),
        ),
      ]),
    );
  }
}

class _HeaderSquare extends StatelessWidget {
  const _HeaderSquare({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x22781823), blurRadius: 8, offset: Offset(0, 3))]),
          child: child,
        ),
      );
}

class _HeaderPatternPainter extends CustomPainter {
  const _HeaderPatternPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.08)..style = PaintingStyle.stroke..strokeWidth = 1.2;
    const step = 26.0;
    for (double y = 2; y < size.height; y += step) {
      for (double x = 4; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 5, paint);
        canvas.drawCircle(Offset(x + 7, y + 7), 5, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.online, this.paused = false, this.compact = false});
  final bool online;
  final bool paused;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 9 : 11),
      decoration: BoxDecoration(color: online ? const Color(0xffeef8f1) : const Color(0xfffff7e8), borderRadius: BorderRadius.circular(12), border: Border.all(color: online ? const Color(0xffcee8d6) : const Color(0xffffe1a5))),
      child: Row(children: [
        Icon(online ? Icons.cloud_done_outlined : Icons.phone_android_rounded, size: 19, color: online ? const Color(0xff3f9a5e) : const Color(0xffa27610)),
        const SizedBox(width: 9),
        Expanded(child: Text(online ? 'VPS tersambung • data online aktif' : 'Mode Offline • semua menu tetap bisa dipakai', style: TextStyle(fontSize: compact ? 12 : 13, fontWeight: FontWeight.w600, color: online ? const Color(0xff34744a) : const Color(0xff7c6117)))),
        if (paused) const Text('DIJEDA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _brand)),
      ]),
    );
  }
}

class _HomeGrid extends StatelessWidget {
  const _HomeGrid({required this.items});
  final List<_GridData> items;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.55, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0x12505e6c)), boxShadow: const [BoxShadow(color: Color(0x0a3c4c5a), blurRadius: 18, offset: Offset(0, 8))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(item.icon, color: _brand, size: 25),
              const Spacer(),
              Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, color: _ink, fontSize: 14)),
              const SizedBox(height: 2),
              Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 11.5)),
            ]),
          ),
        );
      },
    );
  }
}

class _GridData {
  const _GridData(this.icon, this.title, this.subtitle, this.onTap);
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: _line)),
            child: child,
          ),
        ),
      );
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xffffefed), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: _brand, size: 23));
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => _SectionCard(child: Text(text, style: const TextStyle(color: _muted)));
}

class _ConnectorCatalogGrid extends StatelessWidget {
  const _ConnectorCatalogGrid({required this.onTap});
  final ValueChanged<String> onTap;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _connectorKinds.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.05, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemBuilder: (context, index) {
        final item = _connectorKinds[index];
        return InkWell(
          onTap: () => onTap(item.$1),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _line)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(_connectorIcon(item.$1), color: _brand, size: 24), const SizedBox(height: 7), Text(item.$2, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _ink))]),
          ),
        );
      },
    );
  }
}

class _ConnectorRow extends StatelessWidget {
  const _ConnectorRow({required this.item, required this.onTap});
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final configured = item['status'] == 'configured';
    return _SectionCard(
      onTap: onTap,
      child: Row(children: [
        _IconBox(icon: _connectorIcon('${item['kind']}')),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${item['name']}', style: const TextStyle(fontWeight: FontWeight.w700, color: _ink)),
          const SizedBox(height: 3),
          Text(configured ? 'Tersimpan • ketuk untuk edit' : 'Butuh konfigurasi • ketuk untuk isi', style: const TextStyle(color: _muted, fontSize: 12.5)),
        ])),
        Icon(configured ? Icons.check_circle_rounded : Icons.info_outline_rounded, color: configured ? const Color(0xff45b463) : const Color(0xfff0a20d)),
      ]),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, Icons.home_rounded, 'Beranda'),
      (Icons.apartment_outlined, Icons.apartment_rounded, 'Perusahaan'),
      (Icons.verified_user_outlined, Icons.verified_user_rounded, 'Approval'),
      (Icons.cable_outlined, Icons.cable_rounded, 'Konektor'),
      (Icons.settings_outlined, Icons.settings_rounded, 'Sistem'),
    ];
    return Container(
      height: 76 + MediaQuery.paddingOf(context).bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: _line))),
      child: Row(children: [
        for (var i = 0; i < items.length; i++)
          Expanded(
            child: InkWell(
              onTap: () => onTap(i),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(i == index ? items[i].$2 : items[i].$1, color: i == index ? _brand : const Color(0xff9aa0ac), size: 27),
                const SizedBox(height: 5),
                Text(items[i].$3, style: TextStyle(fontSize: 11.5, fontWeight: i == index ? FontWeight.w600 : FontWeight.w400, color: i == index ? _brand : const Color(0xff9aa0ac))),
              ]),
            ),
          ),
      ]),
    );
  }
}

const _connectorKinds = <(String, String)>[
  ('website', 'Website / CMS'),
  ('github', 'GitHub'),
  ('whatsapp', 'WhatsApp'),
  ('meta', 'Instagram / Meta'),
  ('tiktok', 'TikTok'),
  ('google_search_console', 'Search Console'),
  ('google_analytics', 'Analytics'),
  ('domain_dns', 'Domain / DNS'),
  ('hosting_vps', 'Hosting / VPS'),
  ('email', 'Email'),
  ('payment', 'Payment'),
  ('webhook', 'Webhook / API'),
];

String _connectorName(String kind) => _connectorKinds.firstWhere((item) => item.$1 == kind, orElse: () => (kind, kind)).$2;

IconData _connectorIcon(String kind) {
  switch (kind) {
    case 'website': return Icons.language_rounded;
    case 'github': return Icons.code_rounded;
    case 'whatsapp': return Icons.chat_outlined;
    case 'meta': return Icons.camera_alt_outlined;
    case 'tiktok': return Icons.music_note_rounded;
    case 'google_search_console': return Icons.manage_search_rounded;
    case 'google_analytics': return Icons.query_stats_rounded;
    case 'domain_dns': return Icons.dns_outlined;
    case 'hosting_vps': return Icons.cloud_outlined;
    case 'email': return Icons.alternate_email_rounded;
    case 'payment': return Icons.payments_outlined;
    default: return Icons.cable_rounded;
  }
}

IconData _headerIcon(String title) {
  if (title.contains('PERUSAHAAN')) return Icons.business_center_outlined;
  if (title.contains('APPROVAL')) return Icons.verified_user_outlined;
  if (title.contains('KONEKTOR')) return Icons.cable_outlined;
  if (title.contains('DATABASE')) return Icons.storage_outlined;
  if (title.contains('DIVISI')) return Icons.account_tree_outlined;
  if (title.contains('SISTEM')) return Icons.settings_outlined;
  return Icons.hub_outlined;
}

IconData _iconForDivision(String id) {
  switch (id) {
    case 'website': return Icons.language_rounded;
    case 'seo': return Icons.search_rounded;
    case 'social': return Icons.campaign_outlined;
    case 'marketing': return Icons.ads_click_rounded;
    case 'crm': return Icons.contacts_outlined;
    case 'whatsapp': return Icons.chat_outlined;
    case 'finance': return Icons.account_balance_wallet_outlined;
    case 'analytics': return Icons.insights_outlined;
    case 'creative': return Icons.palette_outlined;
    case 'automation': return Icons.hub_outlined;
    default: return Icons.account_tree_outlined;
  }
}

List<Map<String, dynamic>> _divisionTemplate() => [
  {'id': 'website', 'name': 'Website'},
  {'id': 'seo', 'name': 'SEO'},
  {'id': 'social', 'name': 'Social Media'},
  {'id': 'marketing', 'name': 'Marketing'},
  {'id': 'crm', 'name': 'CRM & Sales'},
  {'id': 'whatsapp', 'name': 'WhatsApp'},
  {'id': 'finance', 'name': 'Finance'},
  {'id': 'analytics', 'name': 'Analytics'},
  {'id': 'creative', 'name': 'Creative'},
  {'id': 'automation', 'name': 'Automation'},
];

List<(String, String)> _specialistsFor(String division) {
  switch (division) {
    case 'website':
      return const [('Web Builder', 'Membangun dan deploy website'), ('Technical SEO', 'Performance, schema, indexing'), ('Maintenance', 'Update, backup dan perbaikan')];
    case 'seo':
      return const [('Keyword Research', 'Riset kata kunci & peluang'), ('Content Publisher', 'Artikel terjadwal'), ('Search Console', 'Indexing & coverage'), ('CRO', 'Optimasi conversion')];
    case 'social':
      return const [('Content Planner', 'Kalender konten'), ('Trend Research', 'Hashtag, keyword dan tren'), ('Publishing', 'Posting & scheduling'), ('Community', 'Komentar dan DM'), ('Growth', 'Insight dan eksperimen')];
    case 'marketing':
      return const [('Campaign Planner', 'Strategi campaign'), ('Ads Analyst', 'Biaya dan performa iklan'), ('Funnel', 'Landing dan conversion funnel')];
    case 'crm':
      return const [('Lead Manager', 'Pipeline dan scoring lead'), ('Follow-up', 'Reminder dan tindak lanjut'), ('Sales Analyst', 'Conversion dan nilai prospek')];
    case 'whatsapp':
      return const [('Chatbot', 'Percakapan pelanggan'), ('Broadcast', 'Outreach terkontrol'), ('Quick Reply', 'Balasan cepat & trigger')];
    case 'finance':
      return const [('Budget Manager', 'Batas biaya & alokasi modal'), ('Cashflow', 'Arus kas dan proyeksi'), ('Capital Allocator', 'Usulan reinvestasi')];
    case 'analytics':
      return const [('KPI Monitor', 'Pantau target dan hasil'), ('Experiment Analyst', 'Belajar dari eksperimen'), ('Report', 'Ringkasan untuk owner')];
    case 'creative':
      return const [('Image Creative', 'Visual dan desain'), ('Copywriter', 'Copy iklan dan konten'), ('Brand', 'Identitas dan konsistensi')];
    case 'automation':
      return const [('Workflow Engineer', 'Workflow deterministik'), ('Scheduler', 'Pekerjaan berulang'), ('Reliability', 'Retry, fallback dan monitoring')];
    default:
      return const [('Specialist Agent', 'Pekerjaan khusus divisi')];
  }
}
