import 'package:flutter/material.dart';

import 'services/api_client.dart';

void main() {
  runApp(const AgenticControlCenterApp());
}

const _coral = Color(0xFFF26D62);
const _ink = Color(0xFF22252B);
const _muted = Color(0xFF737780);
const _surface = Color(0xFFF7F7F8);

class AgenticControlCenterApp extends StatelessWidget {
  const AgenticControlCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Foundation Agentic',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _coral),
        scaffoldBackgroundColor: _surface,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F1F3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            side: BorderSide(color: Color(0xFFE9E9EC)),
          ),
        ),
      ),
      home: const ControlCenterShell(),
    );
  }
}

class ControlCenterShell extends StatefulWidget {
  const ControlCenterShell({super.key});

  @override
  State<ControlCenterShell> createState() => _ControlCenterShellState();
}

class _ControlCenterShellState extends State<ControlCenterShell> {
  final _api = AgenticApiClient();
  final _goalController = TextEditingController();

  int _page = 0;
  bool _loading = true;
  bool _submitting = false;
  bool _online = true;
  bool _paused = false;
  int _activeGoals = 0;
  int _activeTasks = 0;
  int _pendingApprovals = 0;
  int _companiesCount = 0;
  int _connectorsCount = 0;
  int _improvementsCount = 0;
  String? _error;

  List<dynamic> _goals = const [];
  List<dynamic> _companies = const [];
  List<dynamic> _approvals = const [];
  List<dynamic> _connectors = const [];
  List<dynamic> _catalog = const [];
  List<dynamic> _improvements = const [];
  List<dynamic> _audit = const [];
  List<dynamic> _providers = const [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _applySystemState(Map<String, dynamic> system) {
    _paused = system['paused'] == true;
    _activeGoals = (system['active_goals'] as num?)?.toInt() ?? 0;
    _activeTasks = (system['active_tasks'] as num?)?.toInt() ?? 0;
    _pendingApprovals = (system['pending_approvals'] as num?)?.toInt() ?? 0;
    _companiesCount = (system['companies'] as num?)?.toInt() ?? 0;
    _connectorsCount = (system['connectors'] as num?)?.toInt() ?? 0;
    _improvementsCount = (system['improvements'] as num?)?.toInt() ?? 0;
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final dashboard = await _api.getDashboard();
      final goals = await _api.getGoals();
      final companies = await _api.getCompanies();
      final approvals = await _api.getApprovals();
      final connectors = await _api.getConnectors();
      final catalog = await _api.getConnectorCatalog();
      final improvements = await _api.getImprovements();
      final audit = await _api.getAudit();
      final providers = await _api.getProviders();
      if (!mounted) return;
      setState(() {
        _online = true;
        _applySystemState(Map<String, dynamic>.from(dashboard['system'] as Map));
        _goals = goals;
        _companies = companies;
        _approvals = approvals;
        _connectors = connectors;
        _catalog = catalog;
        _improvements = improvements;
        _audit = audit;
        _providers = providers;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _online = false;
        _error = 'Backend belum terhubung ke HP. Tampilan preview offline sedang digunakan.';
        _loadPreviewData();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _loadPreviewData() {
    _paused = false;
    _activeGoals = 2;
    _activeTasks = 14;
    _pendingApprovals = 3;
    _companiesCount = 2;
    _connectorsCount = 5;
    _improvementsCount = 1;
    _goals = [
      {
        'objective': 'Naikkan lead organik RajaBadut dan optimalkan website',
        'status': 'running',
      },
      {
        'objective': 'Siapkan usaha baru dan validasi peluang pasar',
        'status': 'waiting_approval',
      },
    ];
    _companies = [
      {
        'id': 'rajabadut',
        'name': 'RajaBadut',
        'objective': 'Pertumbuhan lead, SEO dan penjualan otomatis',
      },
      {
        'id': 'default-company',
        'name': 'Company Baru',
        'objective': 'Workspace siap diaktifkan',
      },
    ];
    _approvals = [
      {
        'id': 'preview-1',
        'reason': 'Pembelian domain/hosting memerlukan persetujuan owner',
        'estimated_cost': 350000,
        'risk_level': 'high',
        'status': 'pending',
      },
      {
        'id': 'preview-2',
        'reason': 'Publikasi campaign ke channel eksternal',
        'estimated_cost': 0,
        'risk_level': 'medium',
        'status': 'pending',
      },
    ];
    _catalog = [
      {'kind': 'website', 'name': 'Website / CMS'},
      {'kind': 'github', 'name': 'GitHub'},
      {'kind': 'whatsapp', 'name': 'WhatsApp Business'},
      {'kind': 'meta', 'name': 'Instagram & Facebook'},
      {'kind': 'tiktok', 'name': 'TikTok'},
      {'kind': 'domain_dns', 'name': 'Domain & DNS'},
      {'kind': 'hosting', 'name': 'Hosting / VPS'},
    ];
    _connectors = [
      {'name': 'Website RajaBadut', 'kind': 'website', 'status': 'configured'},
      {'name': 'GitHub', 'kind': 'github', 'status': 'configured'},
      {'name': 'WhatsApp', 'kind': 'whatsapp', 'status': 'needs_attention'},
    ];
    _providers = [
      {'name': 'Fast Model', 'purpose': 'Task rutin dan klasifikasi', 'cost_tier': 'low'},
      {'name': 'Reasoning Model', 'purpose': 'Strategi dan coding', 'cost_tier': 'medium'},
      {'name': 'Premium Model', 'purpose': 'Keputusan sulit/berdampak tinggi', 'cost_tier': 'high'},
    ];
    _improvements = [
      {
        'id': 'preview-improvement',
        'title': 'Kurangi token untuk pekerjaan repetitif',
        'description': 'Pindahkan dedupe, polling dan status checks ke workflow deterministic.',
        'status': 'proposed',
      },
    ];
    _audit = [
      {'event_type': 'goal.planned', 'message': 'AI Pusat memecah goal menjadi task spesialis'},
      {'event_type': 'approval.created', 'message': 'Approval dibuat untuk pembelian domain/hosting'},
      {'event_type': 'company.bootstrapped', 'message': 'Struktur divisi RajaBadut dibuat otomatis'},
    ];
  }

  Future<void> _submitGoal() async {
    final objective = _goalController.text.trim();
    if (objective.length < 3 || _submitting || _paused || !_online) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await _api.createGoal(objective);
      _goalController.clear();
      await _refresh();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _togglePause() async {
    if (!_online) return;
    setState(() => _submitting = true);
    try {
      final system = await _api.setPaused(!_paused);
      if (!mounted) return;
      setState(() => _applySystemState(system));
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _decideApproval(String id, bool approved) async {
    if (!_online) return;
    setState(() => _submitting = true);
    try {
      await _api.decideApproval(id, approved);
      await _refresh();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _bootstrap(String companyId) async {
    if (!_online) return;
    setState(() => _submitting = true);
    try {
      await _api.bootstrapCompany(companyId);
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Struktur divisi dan specialist sudah dibuat.')),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homePage(),
      _companiesPage(),
      _approvalPage(),
      _connectorsPage(),
      _systemPage(),
    ];
    return Scaffold(
      body: IndexedStack(index: _page, children: pages),
      bottomNavigationBar: _bottomNavigation(),
    );
  }

  Widget _pageScaffold({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _header(title, subtitle, icon)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (!_online) _offlineBanner(),
                if (!_online) const SizedBox(height: 12),
                ...children,
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  _errorCard(),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String title, String subtitle, IconData icon) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.paddingOf(context).top + 14,
        18,
        19,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF735F), Color(0xFFF04C42)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: Colors.white, size: 23),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loading ? null : _refresh,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }

  Widget _homePage() {
    return _pageScaffold(
      title: 'AI Foundation',
      subtitle: 'Central Business Control Center',
      icon: Icons.hub_outlined,
      children: [
        _statusGrid(),
        const SizedBox(height: 14),
        _commandCard(),
        const SizedBox(height: 14),
        _ownerControlCard(),
        const SizedBox(height: 14),
        _recentGoalsCard(),
      ],
    );
  }

  Widget _statusGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(label: 'AI Pusat', value: _paused ? 'Dijeda' : 'Aktif', icon: Icons.bolt_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(label: 'Perusahaan', value: '$_companiesCount', icon: Icons.business_center_outlined)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _StatCard(label: 'Task Aktif', value: '$_activeTasks', icon: Icons.account_tree_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(label: 'Approval', value: '$_pendingApprovals', icon: Icons.verified_user_outlined)),
          ],
        ),
      ],
    );
  }

  Widget _commandCard() {
    return _sectionCard(
      title: 'Perintahkan AI Pusat',
      subtitle: 'Paduka cukup tulis tujuan. AI memecah pekerjaan ke company, divisi, specialist dan worker.',
      child: Column(
        children: [
          TextField(
            controller: _goalController,
            minLines: 3,
            maxLines: 5,
            enabled: _online && !_paused && !_submitting,
            decoration: const InputDecoration(
              hintText: 'Contoh: buat bisnis kitchen set, riset pasar, siapkan website, social media dan strategi penjualan',
            ),
          ),
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (!_online || _paused || _submitting) ? null : _submitGoal,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: Text(!_online ? 'Hubungkan VPS untuk menjalankan' : 'Jalankan Tujuan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ownerControlCard() {
    return _sectionCard(
      title: 'Owner Control',
      subtitle: 'AI bekerja mandiri, keputusan berisiko tetap melewati Paduka.',
      child: Row(
        children: [
          Expanded(
            child: _miniMetric('Goal', '$_activeGoals', Icons.track_changes_rounded),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _miniMetric('Konektor', '$_connectorsCount', Icons.cable_rounded),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _miniMetric('Perbaikan', '$_improvementsCount', Icons.construction_rounded),
          ),
        ],
      ),
    );
  }

  Widget _recentGoalsCard() {
    return _sectionCard(
      title: 'Aktivitas AI Terbaru',
      subtitle: '${_goals.length} goal tercatat',
      child: _goals.isEmpty
          ? const _EmptyState(text: 'Belum ada goal. Kirim tujuan pertama ke AI Pusat.')
          : Column(
              children: _goals.take(5).map((item) {
                final goal = Map<String, dynamic>.from(item as Map);
                return _listRow(
                  icon: Icons.track_changes_rounded,
                  title: '${goal['objective'] ?? '-'}',
                  subtitle: _statusLabel('${goal['status'] ?? 'queued'}'),
                );
              }).toList(),
            ),
    );
  }

  Widget _companiesPage() {
    return _pageScaffold(
      title: 'Perusahaan',
      subtitle: 'Company Agent dan struktur digital office',
      icon: Icons.business_center_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$_companiesCount company workspace',
                style: const TextStyle(fontWeight: FontWeight.w700, color: _muted),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: _online ? _showCreateCompany : null,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_companies.isEmpty)
          const _EmptyState(text: 'Belum ada perusahaan.')
        else
          ..._companies.map((item) {
            final company = Map<String, dynamic>.from(item as Map);
            final id = '${company['id'] ?? ''}';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFFFEFED),
                            foregroundColor: _coral,
                            child: Icon(Icons.business_outlined),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${company['name'] ?? id}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 3),
                                Text('${company['objective'] ?? 'Company Agent siap bekerja'}', style: const TextStyle(color: _muted, fontSize: 12, height: 1.35)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: (!_online || _submitting) ? null : () => _bootstrap(id),
                          icon: const Icon(Icons.account_tree_outlined),
                          label: const Text('Siapkan Divisi & Specialist Otomatis'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _approvalPage() {
    return _pageScaffold(
      title: 'Approval Center',
      subtitle: 'Biaya, publikasi dan aksi berisiko berhenti di sini',
      icon: Icons.verified_user_outlined,
      children: [
        _sectionCard(
          title: 'Menunggu Keputusan',
          subtitle: '$_pendingApprovals approval aktif',
          child: _approvals.isEmpty
              ? const _EmptyState(text: 'Tidak ada keputusan yang menunggu.')
              : Column(
                  children: _approvals.map((item) {
                    final approval = Map<String, dynamic>.from(item as Map);
                    final id = '${approval['id'] ?? ''}';
                    final cost = (approval['estimated_cost'] as num?)?.toDouble() ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8F7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFE3DF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.priority_high_rounded, color: _coral, size: 20),
                              const SizedBox(width: 7),
                              Expanded(child: Text('${approval['reason'] ?? 'Keputusan owner diperlukan'}', style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35))),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Text('Risiko: ${approval['risk_level'] ?? '-'}${cost > 0 ? ' • Estimasi Rp${cost.toStringAsFixed(0)}' : ''}', style: const TextStyle(color: _muted, fontSize: 12)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: (!_online || _submitting || id.startsWith('preview-')) ? null : () => _decideApproval(id, false),
                                  child: const Text('Tolak'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  onPressed: (!_online || _submitting || id.startsWith('preview-')) ? null : () => _decideApproval(id, true),
                                  child: const Text('Setujui'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _connectorsPage() {
    return _pageScaffold(
      title: 'Konektor',
      subtitle: 'API, website, social media, domain dan VPS',
      icon: Icons.cable_rounded,
      children: [
        _sectionCard(
          title: 'Automatic First',
          subtitle: 'AI memakai konektor otomatis. Pengaturan manual tetap tersedia sebagai jalur cadangan.',
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _online ? _showAddConnector : null,
              icon: const Icon(Icons.add_link_rounded),
              label: const Text('Tambah Konektor Manual'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Konektor Aktif',
          subtitle: '${_connectors.length} konfigurasi',
          child: _connectors.isEmpty
              ? const _EmptyState(text: 'Belum ada konektor.')
              : Column(
                  children: _connectors.map((item) {
                    final connector = Map<String, dynamic>.from(item as Map);
                    final status = '${connector['status'] ?? 'not_configured'}';
                    return _listRow(
                      icon: _connectorIcon('${connector['kind'] ?? ''}'),
                      title: '${connector['name'] ?? connector['kind'] ?? 'Connector'}',
                      subtitle: _connectorStatus(status),
                      trailing: Icon(
                        status == 'configured' ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                        color: status == 'configured' ? Colors.green : Colors.orange,
                        size: 21,
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Katalog',
          subtitle: 'Konektor yang disiapkan untuk sistem',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _catalog.map((item) {
              final data = Map<String, dynamic>.from(item as Map);
              return Chip(
                avatar: Icon(_connectorIcon('${data['kind'] ?? ''}'), size: 17),
                label: Text('${data['name'] ?? data['kind']}'),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _systemPage() {
    return _pageScaffold(
      title: 'Sistem AI',
      subtitle: 'Router model, self-improvement, audit dan emergency control',
      icon: Icons.memory_rounded,
      children: [
        _sectionCard(
          title: 'Emergency Pause',
          subtitle: _paused ? 'AI dan task baru sedang dijeda.' : 'Sistem aktif. Gunakan hanya bila perlu menghentikan seluruh pekerjaan baru.',
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: (!_online || _submitting) ? null : _togglePause,
              icon: Icon(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
              label: Text(_paused ? 'Aktifkan Kembali Sistem' : 'Jeda Seluruh Sistem'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'AI Model Router',
          subtitle: 'Task ringan memakai model hemat. Reasoning kuat hanya dipakai bila memang dibutuhkan.',
          child: Column(
            children: _providers.map((item) {
              final provider = Map<String, dynamic>.from(item as Map);
              return _listRow(
                icon: Icons.psychology_alt_outlined,
                title: '${provider['name'] ?? '-'}',
                subtitle: '${provider['purpose'] ?? ''} • biaya ${provider['cost_tier'] ?? '-'}',
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Self-Improvement',
          subtitle: 'AI boleh mencari cara memperbaiki sistem, tetapi perubahan berisiko tetap melalui kontrol owner.',
          child: _improvements.isEmpty
              ? const _EmptyState(text: 'Belum ada proposal perbaikan.')
              : Column(
                  children: _improvements.map((item) {
                    final proposal = Map<String, dynamic>.from(item as Map);
                    return _listRow(
                      icon: Icons.construction_rounded,
                      title: '${proposal['title'] ?? '-'}',
                      subtitle: '${proposal['description'] ?? ''}',
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: 'Audit Log',
          subtitle: 'Semua aktivitas penting terlihat dan dapat ditelusuri.',
          child: _audit.isEmpty
              ? const _EmptyState(text: 'Belum ada aktivitas tercatat.')
              : Column(
                  children: _audit.take(8).map((item) {
                    final event = Map<String, dynamic>.from(item as Map);
                    return _listRow(
                      icon: Icons.history_rounded,
                      title: '${event['message'] ?? '-'}',
                      subtitle: '${event['event_type'] ?? 'event'}',
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12.5, height: 1.4)),
            const SizedBox(height: 13),
            child,
          ],
        ),
      ),
    );
  }

  Widget _miniMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Icon(icon, color: _coral, size: 20),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          Text(label, style: const TextStyle(fontSize: 10.5, color: _muted)),
        ],
      ),
    );
  }

  Widget _listRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _coral, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, height: 1.3)),
                const SizedBox(height: 3),
                Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 11.5, height: 1.35)),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }

  Widget _offlineBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5DE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE09A)),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: Color(0xFF9A6B00), size: 20),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Preview Offline • tampilan bisa dicek sekarang. Sambungkan backend VPS untuk menjalankan Agentic sungguhan.',
              style: TextStyle(color: Color(0xFF795700), fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: _coral),
            const SizedBox(width: 9),
            Expanded(child: Text(_error!, style: const TextStyle(color: _muted, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigation() {
    const items = [
      (Icons.home_outlined, Icons.home_rounded, 'Beranda'),
      (Icons.business_outlined, Icons.business_rounded, 'Perusahaan'),
      (Icons.verified_user_outlined, Icons.verified_user_rounded, 'Approval'),
      (Icons.cable_outlined, Icons.cable_rounded, 'Konektor'),
      (Icons.settings_outlined, Icons.settings_rounded, 'Sistem'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEDEDF0))),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: SizedBox(
        height: 68,
        child: Row(
          children: List.generate(items.length, (index) {
            final active = _page == index;
            final item = items[index];
            return Expanded(
              child: InkWell(
                onTap: () => setState(() => _page = index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(active ? item.$2 : item.$1, color: active ? _coral : const Color(0xFF9A9DA4), size: 24),
                    const SizedBox(height: 4),
                    Text(item.$3, style: TextStyle(fontSize: 10.5, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? _coral : const Color(0xFF8C9098))),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _showCreateCompany() async {
    final name = TextEditingController();
    final slug = TextEditingController();
    final objective = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Perusahaan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(hintText: 'Nama perusahaan')),
              const SizedBox(height: 10),
              TextField(controller: slug, decoration: const InputDecoration(hintText: 'ID singkat, contoh: rajabadut')),
              const SizedBox(height: 10),
              TextField(controller: objective, minLines: 2, maxLines: 4, decoration: const InputDecoration(hintText: 'Tujuan utama perusahaan')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Buat')),
        ],
      ),
    );
    if (result != true || name.text.trim().length < 2 || slug.text.trim().length < 2) return;
    setState(() => _submitting = true);
    try {
      final company = await _api.createCompany(name: name.text.trim(), slug: slug.text.trim(), objective: objective.text.trim());
      await _api.bootstrapCompany('${company['id']}');
      await _refresh();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      name.dispose();
      slug.dispose();
      objective.dispose();
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _showAddConnector() async {
    if (_catalog.isEmpty) return;
    String kind = '${(Map<String, dynamic>.from(_catalog.first as Map))['kind']}';
    final name = TextEditingController();
    final endpoint = TextEditingController();
    final credential = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Konektor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: kind,
                  items: _catalog.map((item) {
                    final data = Map<String, dynamic>.from(item as Map);
                    return DropdownMenuItem(value: '${data['kind']}', child: Text('${data['name']}'));
                  }).toList(),
                  onChanged: (value) => setDialogState(() => kind = value ?? kind),
                ),
                const SizedBox(height: 10),
                TextField(controller: name, decoration: const InputDecoration(hintText: 'Nama konektor')),
                const SizedBox(height: 10),
                TextField(controller: endpoint, decoration: const InputDecoration(hintText: 'Endpoint / URL (opsional)')),
                const SizedBox(height: 10),
                TextField(controller: credential, decoration: const InputDecoration(hintText: 'Credential reference, contoh vault://...')),
                const SizedBox(height: 8),
                const Text('Kredensial sebaiknya disimpan di secret manager/Vault. Aplikasi hanya menyimpan referensinya.', style: TextStyle(fontSize: 11, color: _muted, height: 1.35)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
          ],
        ),
      ),
    );
    if (result != true || name.text.trim().length < 2) return;
    setState(() => _submitting = true);
    try {
      await _api.createConnector(
        companyId: 'default-company',
        kind: kind,
        name: name.text.trim(),
        endpoint: endpoint.text.trim(),
        credentialRef: credential.text.trim(),
      );
      await _refresh();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      name.dispose();
      endpoint.dispose();
      credential.dispose();
      if (mounted) setState(() => _submitting = false);
    }
  }

  IconData _connectorIcon(String kind) {
    switch (kind) {
      case 'website':
        return Icons.language_rounded;
      case 'github':
        return Icons.code_rounded;
      case 'whatsapp':
        return Icons.chat_bubble_outline_rounded;
      case 'meta':
        return Icons.photo_camera_outlined;
      case 'tiktok':
        return Icons.music_note_rounded;
      case 'domain_dns':
        return Icons.dns_outlined;
      case 'hosting':
        return Icons.cloud_outlined;
      default:
        return Icons.cable_rounded;
    }
  }

  String _connectorStatus(String status) {
    switch (status) {
      case 'configured':
        return 'Siap dipakai';
      case 'needs_attention':
        return 'Butuh konfigurasi';
      case 'disabled':
        return 'Dinonaktifkan';
      default:
        return 'Belum dikonfigurasi';
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'waiting_approval':
        return 'Menunggu persetujuan';
      case 'planning':
        return 'AI sedang menyusun rencana';
      case 'running':
        return 'Sedang dikerjakan';
      case 'completed':
        return 'Selesai';
      case 'failed':
        return 'Perlu perhatian';
      default:
        return 'Dalam antrean';
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _coral, size: 22),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _ink)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11.5, color: _muted)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(text, style: const TextStyle(color: _muted, fontSize: 12.5)),
    );
  }
}
