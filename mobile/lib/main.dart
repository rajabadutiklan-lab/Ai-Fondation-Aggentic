import 'package:flutter/material.dart';

import 'services/api_client.dart';

void main() {
  runApp(const AgenticControlCenterApp());
}

class AgenticControlCenterApp extends StatelessWidget {
  const AgenticControlCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFF26D62);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Foundation Agentic',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: coral),
        scaffoldBackgroundColor: const Color(0xFFF7F7F8),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            side: BorderSide(color: Color(0xFFE7E7EA)),
          ),
        ),
      ),
      home: const ControlCenterPage(),
    );
  }
}

class ControlCenterPage extends StatefulWidget {
  const ControlCenterPage({super.key});

  @override
  State<ControlCenterPage> createState() => _ControlCenterPageState();
}

class _ControlCenterPageState extends State<ControlCenterPage> {
  final _api = AgenticApiClient();
  final _goalController = TextEditingController();

  bool _loading = true;
  bool _submitting = false;
  bool _paused = false;
  int _activeGoals = 0;
  int _activeTasks = 0;
  int _pendingApprovals = 0;
  int _companies = 0;
  String? _error;
  List<dynamic> _goals = const [];

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
    _companies = (system['companies'] as num?)?.toInt() ?? 0;
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final system = await _api.getSystemState();
      final goals = await _api.getGoals();
      if (!mounted) return;
      setState(() {
        _applySystemState(system);
        _goals = goals;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitGoal() async {
    final objective = _goalController.text.trim();
    if (objective.length < 3 || _submitting || _paused) return;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStatusGrid(),
                  const SizedBox(height: 16),
                  _buildCommandCard(),
                  const SizedBox(height: 16),
                  _buildQuickControls(),
                  const SizedBox(height: 16),
                  _buildRecentGoals(),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    _buildErrorCard(),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 18,
        20,
        22,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF26D62),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.hub_outlined, color: Colors.white),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI FOUNDATION',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Control Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: _loading ? null : _refresh,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'AI Pusat',
                value: _paused ? 'Dijeda' : 'Aktif',
                icon: _paused ? Icons.pause_circle_outline : Icons.bolt_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Company',
                value: _loading ? '...' : '$_companies',
                icon: Icons.business_center_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Task Aktif',
                value: _loading ? '...' : '$_activeTasks',
                icon: Icons.account_tree_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Approval',
                value: _loading ? '...' : '$_pendingApprovals',
                icon: Icons.verified_user_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommandCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perintahkan AI',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Cukup tulis tujuan bisnis. Detail teknis ditangani sistem dan keputusan penting masuk Approval Center.',
              style: TextStyle(color: Color(0xFF707078), height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _goalController,
              minLines: 3,
              maxLines: 5,
              enabled: !_paused && !_submitting,
              decoration: InputDecoration(
                hintText: 'Contoh: buat website baru untuk bisnis dekorasi dan siapkan sampai siap tayang',
                filled: true,
                fillColor: const Color(0xFFF3F3F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _paused || _submitting ? null : _submitGoal,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_upward_rounded),
                label: Text(_paused ? 'AI sedang dijeda' : 'Kirim Tujuan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emergency Pause',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _paused
                        ? 'Goal dan task baru dihentikan sementara.'
                        : 'Tekan jika seluruh AI dan task baru perlu berhenti.',
                    style: const TextStyle(color: Color(0xFF707078)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.tonalIcon(
              onPressed: _submitting ? null : _togglePause,
              icon: Icon(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
              label: Text(_paused ? 'Lanjutkan' : 'Jeda'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentGoals() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Aktivitas Terbaru',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${_goals.length} goal • $_activeGoals aktif',
                  style: const TextStyle(color: Color(0xFF77777F)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const LinearProgressIndicator()
            else if (_goals.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Belum ada pekerjaan. Kirim tujuan pertama dari Control Center.',
                  style: TextStyle(color: Color(0xFF77777F)),
                ),
              )
            else
              ..._goals.take(5).map((goal) {
                final data = goal as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF26D62),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data['objective'] ?? '-'}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _statusLabel('${data['status'] ?? 'queued'}'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF77777F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFFF26D62)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _error!,
                style: const TextStyle(color: Color(0xFF6E3632)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'waiting_approval':
        return 'Menunggu persetujuan';
      case 'planning':
        return 'Sedang menyusun rencana';
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
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFF26D62)),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Color(0xFF77777F))),
          ],
        ),
      ),
    );
  }
}
