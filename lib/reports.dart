import 'dart:math' as math;
import 'package:flutter/material.dart';

const _red = Color(0xFFF01730);
const _ink = Color(0xFF152033);
const _gray = Color(0xFF7D8493);
const _paper = Color(0xFFFFFAFB);
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
String _date(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
String _money(int value) => 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

/// Native Flutter reports UI. All figures are demo data, not live accounting.
/// No BackdropFilter, shaders, external chart libraries or continuous animation.
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key, required this.onOpen});
  final ValueChanged<String> onOpen;
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String period = 'Harian';
  String outlet = 'Outlet Utama';
  bool orders = false;
  DateTime selected = DateTime(2026, 10, 12);
  DateTimeRange? range;
  int selectedBar = 4;
  static const revenues = [450000, 730000, 890000, 980000, 1250000, 1080000, 740000];
  static const quantities = [19, 28, 34, 42, 48, 41, 29];
  int get factor => outlet == 'Outlet Utama' ? 1 : 2;
  int get amount => (period == 'Harian' ? revenues[selectedBar] : period == 'Mingguan' ? 6120000 : period == 'Bulanan' ? 28750000 : 3650000) ~/ factor;
  int get count => (period == 'Harian' ? quantities[selectedBar] : period == 'Mingguan' ? 241 : period == 'Bulanan' ? 1104 : 145) ~/ factor;
  String get periodLabel => period == 'Harian' ? 'Omzet Hari Ini' : 'Omzet ${period == 'Kustom' ? 'Periode' : period}';

  Future<void> chooseDate({bool custom = false}) async {
    if (custom) {
      final picked = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2035), initialDateRange: range ?? DateTimeRange(start: selected.subtract(const Duration(days: 6)), end: selected));
      if (picked != null && mounted) setState(() { range = picked; selected = picked.end; period = 'Kustom'; });
    } else {
      final picked = await showDatePicker(context: context, initialDate: selected, firstDate: DateTime(2020), lastDate: DateTime(2035));
      if (picked != null && mounted) setState(() => selected = picked);
    }
  }

  void details(String title, Widget content) => showModalBottomSheet<void>(
    context: context, isScrollControlled: true, backgroundColor: _paper,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (context) => SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))]),
      const SizedBox(height: 12), content, const SizedBox(height: 16),
      const Text('Data contoh untuk pratinjau tampilan.', style: TextStyle(color: _gray, fontSize: 12)),
    ]))));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFD9DC),
    body: DefaultTextStyle.merge(style: const TextStyle(height: 1.15), child: Stack(children: [
      const Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: _ReportBackground()))),
      SafeArea(bottom: false, child: Column(children: [
        Expanded(child: SingleChildScrollView(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600),
          child: LayoutBuilder(builder: (context, bounds) => SizedBox(width: bounds.maxWidth,
            child: FittedBox(fit: BoxFit.fitWidth, alignment: Alignment.topCenter, child: SizedBox(width: 432,
              child: Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _header(),
                const Padding(padding: EdgeInsets.fromLTRB(8, 12, 0, 8), child: Text('LAPORAN', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800, letterSpacing: .2))),
                _filters(), const SizedBox(height: 9),
                Row(children: [Expanded(child: _stat(periodLabel, _money(amount), '+12%', Icons.toll_rounded)), const SizedBox(width: 6), Expanded(child: _stat('Total Pesanan', '$count', '+18%', Icons.bar_chart_rounded))]),
                const SizedBox(height: 6), _chart(), const SizedBox(height: 6),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 58, child: _services()), const SizedBox(width: 6), Expanded(flex: 42, child: _payments())]),
                const SizedBox(height: 6), _recap(),
                const Padding(padding: EdgeInsets.only(top: 5), child: Center(child: Text('Pratinjau • Data contoh', style: TextStyle(color: Color(0xFFAC747C), fontSize: 8)))),
              ])))))))))),
        _navigation(),
      ])),
    ])));

  Widget _header() => Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Row(children: [
    const SizedBox(width: 43, height: 45, child: CustomPaint(painter: _EwashoMark())),
    const SizedBox(width: 7),
    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('EWASHO', style: TextStyle(color: Colors.white, fontSize: 19, height: 1.15, fontWeight: FontWeight.w800)),
      SizedBox(height: 3), Text('K A S I R  L A U N D R Y', style: TextStyle(color: Colors.white, fontSize: 5.7, fontWeight: FontWeight.w500)),
    ])),
    PopupMenuButton<String>(tooltip: 'Pilih outlet laporan', onSelected: (value) => setState(() => outlet = value),
      itemBuilder: (_) => ['Outlet Utama', 'Outlet Cabang'].map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10), decoration: BoxDecoration(color: const Color(0xFFF85D66), border: Border.all(color: const Color(0xFFFF9A9F)), borderRadius: BorderRadius.circular(15)),
        child: Row(children: [const Icon(Icons.storefront, color: Colors.white, size: 20), const SizedBox(width: 7), Text(outlet, style: const TextStyle(color: Colors.white, fontSize: 10)), const SizedBox(width: 8), const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 19)]))),
    const SizedBox(width: 8),
    SizedBox(width: 34, height: 34, child: IconButton(onPressed: chooseDate, tooltip: 'Pilih tanggal laporan', padding: EdgeInsets.zero,
      style: IconButton.styleFrom(backgroundColor: const Color(0xFFF85D66), side: const BorderSide(color: Color(0xFFFF9A9F))), icon: const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 19))),
  ]));

  Widget _filters() => Row(children: [
    Expanded(flex: 64, child: Container(height: 32, decoration: BoxDecoration(color: const Color(0xFFF96C75), borderRadius: BorderRadius.circular(14)),
      child: Row(children: ['Harian', 'Mingguan', 'Bulanan', 'Kustom'].map((p) => Expanded(child: Material(color: period == p ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(14),
        child: InkWell(key: ValueKey('period-$p'), borderRadius: BorderRadius.circular(14), onTap: () { if (p == 'Kustom') { chooseDate(custom: true); } else { setState(() => period = p); } },
          child: Center(child: Text(p, style: TextStyle(fontSize: 10, color: period == p ? _red : Colors.white, fontWeight: period == p ? FontWeight.w700 : FontWeight.w400))))))).toList()))),
    const SizedBox(width: 16),
    Expanded(flex: 34, child: Material(color: Colors.white, borderRadius: BorderRadius.circular(12), child: InkWell(onTap: () => chooseDate(custom: period == 'Kustom'), borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10), child: Row(children: [const Icon(Icons.calendar_month, color: _red, size: 14), const SizedBox(width: 6), Expanded(child: FittedBox(fit: BoxFit.scaleDown, child: Text(_date(selected), style: const TextStyle(fontSize: 9, color: _gray)))), const SizedBox(width: 5), const Icon(Icons.keyboard_arrow_down, color: _red, size: 14)]))))),
  ]);

  Widget _stat(String label, String value, String growth, IconData icon) => _card(
    padding: const EdgeInsets.all(10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFFFE7E9), borderRadius: BorderRadius.circular(13)), child: Icon(icon, size: 27, color: _red)),
      const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: _ink)),
        const SizedBox(height: 3), FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _ink))),
        const SizedBox(height: 5), Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.trending_up, size: 12, color: Color(0xFF22B478)), Text(growth, style: const TextStyle(fontSize: 10, color: Color(0xFF22B478), fontWeight: FontWeight.w700))]),
          Text(period == 'Harian' ? 'dari kemarin' : 'periode sebelumnya', style: const TextStyle(fontSize: 7, color: _gray)),
        ])), const SizedBox(width: 28, height: 25, child: CustomPaint(painter: _MiniBars()))]),
      ])),
    ]));

  Widget _chart() => _card(child: Column(children: [
    Row(children: [const Expanded(child: Text('Grafik Omzet', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _ink))),
      Container(decoration: BoxDecoration(color: const Color(0xFFF0EEF0), borderRadius: BorderRadius.circular(9)), child: Row(children: [
        _toggle('Omzet', !orders, () => setState(() => orders = false)), _toggle('Pesanan', orders, () => setState(() => orders = true)),
      ])),
    ]),
    const SizedBox(height: 8),
    SizedBox(height: 112, child: Row(children: [
      SizedBox(width: 32, child: Padding(padding: const EdgeInsets.only(bottom: 18), child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end,
        children: (orders ? ['80', '60', '40', '20', '0'] : ['2,0 jt', '1,5 jt', '1,0 jt', '500 rb', '0']).map((s) => Text(s, style: const TextStyle(fontSize: 7, color: _gray))).toList()))),
      const SizedBox(width: 7),
      Expanded(child: LayoutBuilder(builder: (context, bounds) => Stack(clipBehavior: Clip.none, children: [
        Positioned.fill(bottom: 18, child: CustomPaint(painter: _GridLines())),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(7, (i) {
          final date = selected.add(Duration(days: i - selectedBar));
          final value = orders ? quantities[i] / 80 : revenues[i] / 2000000;
          return Expanded(child: InkWell(key: ValueKey('report-bar-$i'), onTap: () => setState(() { selected = date; selectedBar = i; }), child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Container(width: 27, height: 87 * value, decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(3)), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: i == selectedBar ? [const Color(0xFFFF777E), _red] : [const Color(0xFFFAB5BC), const Color(0xFFF8ACB4)]))),
            const SizedBox(height: 7), Text('${date.day} ${_months[date.month - 1]}', style: TextStyle(fontSize: 7, color: i == selectedBar ? _ink : _gray, fontWeight: i == selectedBar ? FontWeight.w700 : FontWeight.w400)),
          ])));
        })),
        Positioned(left: ((selectedBar + .5) * bounds.maxWidth / 7 - 33).clamp(0, bounds.maxWidth - 66).toDouble(), top: 0, child: IgnorePointer(child: Container(width: 66, padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7), boxShadow: const [BoxShadow(color: Color(0x16DD3646), blurRadius: 10, offset: Offset(0, 4))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_date(selected), style: const TextStyle(color: _gray, fontSize: 7)), const SizedBox(height: 3), FittedBox(child: Text(orders ? '${quantities[selectedBar] ~/ factor} pesanan' : _money(revenues[selectedBar] ~/ factor), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _ink)))])))),
      ]))),
    ])),
  ]));

  Widget _toggle(String label, bool active, VoidCallback tap) => InkWell(key: ValueKey('chart-$label'), onTap: tap, borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6), decoration: BoxDecoration(color: active ? _red : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Text(label, style: TextStyle(color: active ? Colors.white : _gray, fontSize: 8))));

  static const services = [
    ('Cuci Setrika', 42, 120, Icons.layers_outlined, Color(0xFFFF7B20), Color(0xFFFFE8DC)),
    ('Cuci', 28, 80, Icons.checkroom_rounded, Color(0xFF218CFA), Color(0xFFE4EEFF)),
    ('Setrika', 18, 52, Icons.iron_outlined, Color(0xFFA63CEC), Color(0xFFF0E3FF)),
    ('Express', 12, 35, Icons.bolt_rounded, Color(0xFFFF4C58), Color(0xFFFFE5E8)),
  ];
  Widget _services() => _card(padding: const EdgeInsets.fromLTRB(14, 11, 12, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const Expanded(child: Text('Layanan Terlaris', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _ink))), InkWell(onTap: () => details('Layanan Terlaris', Column(children: services.map((s) => ListTile(contentPadding: EdgeInsets.zero, leading: Icon(s.$4, color: s.$5), title: Text(s.$1), trailing: Text('${s.$2}%'))).toList())), child: const Padding(padding: EdgeInsets.symmetric(vertical: 5), child: Text('Lihat semua', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: _red))))]),
    const SizedBox(height: 5),
    for (final s in services) Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
      Container(width: 33, height: 34, decoration: BoxDecoration(color: s.$6, borderRadius: BorderRadius.circular(9)), child: Icon(s.$4, size: 24, color: s.$5)),
      const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(s.$1, style: const TextStyle(fontSize: 9, color: _ink, fontWeight: FontWeight.w600))), Text('${s.$2}%', style: const TextStyle(fontSize: 9, color: _ink, fontWeight: FontWeight.w700))]),
        const SizedBox(height: 3), Align(alignment: Alignment.centerRight, child: Text('${s.$3 ~/ factor} pesanan', style: const TextStyle(color: _gray, fontSize: 7))),
        const SizedBox(height: 3), ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: s.$2 / 60, minHeight: 6, backgroundColor: const Color(0xFFF0ECEF), color: const Color(0xFFFF535E))),
      ])),
    ])),
  ]));

  Widget _payments() {
    const colors = [_red, Color(0xFFFF96A3), Color(0xFF78A4FA), Color(0xFFA0A4B1)];
    const names = ['QRIS', 'Tunai', 'Transfer', 'Lainnya'];
    const shares = [52, 28, 15, 5];
    return _card(padding: const EdgeInsets.fromLTRB(13, 11, 12, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Metode Pembayaran', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _ink)), const SizedBox(height: 7),
      Center(child: SizedBox(width: 104, height: 104, child: Stack(alignment: Alignment.center, children: [
        const Positioned.fill(child: RepaintBoundary(child: CustomPaint(painter: _PaymentRing()))),
        Padding(padding: const EdgeInsets.all(17), child: Column(mainAxisSize: MainAxisSize.min, children: [FittedBox(child: Text(_money(amount), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _ink))), const SizedBox(height: 3), const Text('Total Omzet', style: TextStyle(fontSize: 7, color: _gray))])),
      ]))), const SizedBox(height: 7),
      for (var i = 0; i < 4; i++) Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: colors[i])), const SizedBox(width: 5), Expanded(child: Text(names[i], style: const TextStyle(fontSize: 7, color: _ink))), Text('${shares[i]}%', style: const TextStyle(fontSize: 7, color: _ink, fontWeight: FontWeight.w600)), const SizedBox(width: 8), SizedBox(width: 50, child: FittedBox(alignment: Alignment.centerRight, fit: BoxFit.scaleDown, child: Text(_money(amount * shares[i] ~/ 100), style: const TextStyle(fontSize: 7, color: _gray))))])),
    ]));
  }

  Widget _recap() => _card(padding: const EdgeInsets.fromLTRB(13, 9, 9, 8), child: Column(children: [
    Row(children: [const Expanded(child: Text('Rekap Harian', style: TextStyle(fontSize: 12, color: _ink, fontWeight: FontWeight.w700))), InkWell(onTap: () => details('Rekap ${_date(selected)}', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Outlet: $outlet'), const SizedBox(height: 8), Text('Total pesanan: $count'), Text('Total omzet: ${_money(amount)}'), const SizedBox(height: 8), const Text('QRIS 52% • Tunai 28% • Transfer 15% • Lainnya 5%')])), child: const Padding(padding: EdgeInsets.all(5), child: Text('Lihat detail ›', style: TextStyle(fontSize: 8, color: _red, fontWeight: FontWeight.w600))))]),
    const SizedBox(height: 3),
    Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFF4F1F3), borderRadius: BorderRadius.circular(7)), child: const Row(children: [SizedBox(width: 76, child: Text('Tanggal', style: TextStyle(color: _gray, fontSize: 8))), SizedBox(width: 48, child: Text('Pesanan', style: TextStyle(color: _gray, fontSize: 8))), SizedBox(width: 70, child: Text('Omzet', style: TextStyle(color: _gray, fontSize: 8))), Expanded(child: Text('Pembayaran', style: TextStyle(color: _gray, fontSize: 8)))])),
    for (int i = 0; i < 2; i++) Container(color: i == 0 ? Colors.white : const Color(0xFFFFF9FA), padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7), child: Row(children: [
      SizedBox(width: 76, child: Text(_date(selected.subtract(Duration(days: i))), style: const TextStyle(fontSize: 8, color: _ink, fontWeight: FontWeight.w600))),
      SizedBox(width: 48, child: Text('${i == 0 ? count : count * .875 ~/ 1}', style: const TextStyle(fontSize: 8, color: _ink, fontWeight: FontWeight.w600))),
      SizedBox(width: 70, child: Text(_money(i == 0 ? amount : amount * .784 ~/ 1), style: const TextStyle(fontSize: 8, color: _ink, fontWeight: FontWeight.w600))),
      Expanded(child: Row(children: [for (final item in const [('QRIS', Color(0xFFFFE8EC)), ('Tunai', Color(0xFFE5F7EE)), ('Transfer', Color(0xFFE8F0FF)), ('Lainnya', Color(0xFFF0EFF3))]) Expanded(child: Container(margin: const EdgeInsets.only(right: 2), padding: const EdgeInsets.symmetric(vertical: 4), decoration: BoxDecoration(color: item.$2, borderRadius: BorderRadius.circular(4)), child: Text(item.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 6, color: _ink))))])),
    ])),
  ]));

  Widget _navigation() => Container(decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
    child: SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(5, 4, 5, 7), child: Row(children: [
      _nav('Beranda', Icons.home_outlined, () => Navigator.pop(context)),
      _nav('Pesanan', Icons.assignment_outlined, () => widget.onOpen('Pesanan')),
      Expanded(child: Transform.translate(offset: const Offset(0, -11), child: Center(child: SizedBox(width: 54, height: 54, child: IconButton.filled(tooltip: 'Scan Kamera', onPressed: () => widget.onOpen('Scan Kamera'), style: IconButton.styleFrom(backgroundColor: _red, side: const BorderSide(color: Color(0xFFFFB1B8), width: 2)), icon: const Icon(Icons.qr_code_scanner_rounded, size: 28)))))),
      _nav('Laporan', Icons.bar_chart_rounded, () {}, active: true),
      _nav('Pengaturan', Icons.settings_outlined, () => widget.onOpen('Pengaturan')),
      _nav('Profil', Icons.person_outline, () => widget.onOpen('Profil')),
    ]))));

  Widget _nav(String label, IconData icon, VoidCallback tap, {bool active = false}) => Expanded(child: InkWell(onTap: tap, child: Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 24, color: active ? _red : _gray), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 9, color: active ? _red : _gray))]))));
}

Widget _card({required Widget child, EdgeInsets padding = const EdgeInsets.all(14)}) => Container(padding: padding, decoration: BoxDecoration(color: _paper, borderRadius: BorderRadius.circular(15)), child: child);

class _ReportBackground extends CustomPainter {
  const _ReportBackground();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFF493F), Color(0xFFF12337), Color(0xFFFFDEE0), Color(0xFFFFE8EA), Color(0xFFFFB8BF)], stops: [0, .20, .38, .7, 1]).createShader(rect));
    final wave = Path()..moveTo(0, 0)..cubicTo(size.width * .28, -20, size.width * .64, size.height * .17, size.width * .37, size.height * .11)..cubicTo(size.width * .18, size.height * .07, size.width * .14, size.height * .14, 0, size.height * .06)..close();
    canvas.drawPath(wave, Paint()..color = const Color(0x15FFFFFF));
    final wave2 = Path()..moveTo(size.width, size.height * .06)..cubicTo(size.width * .55, size.height * .15, size.width * .60, size.height * .20, size.width, size.height * .22)..close();
    canvas.drawPath(wave2, Paint()..color = const Color(0x0CFFFFFF));
  }
  @override
  bool shouldRepaint(covariant _ReportBackground oldDelegate) => false;
}

class _MiniBars extends CustomPainter {
  const _MiniBars();
  @override
  void paint(Canvas c, Size s) {
    for (var i = 0; i < 4; i++) {
      final r = Rect.fromLTWH(i * s.width / 4, s.height * (3 - i) * .18, s.width / 4 - 1.5, s.height * (1 - (3 - i) * .18));
      c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(2)), Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFBDC3), Color(0xFFF44859)]).createShader(r));
    }
  }
  @override
  bool shouldRepaint(covariant _MiniBars oldDelegate) => false;
}

class _GridLines extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final paint = Paint()..color = const Color(0xFFEFE9ED)..strokeWidth = .5;
    for (var i = 0; i < 5; i++) c.drawLine(Offset(0, s.height * i / 4), Offset(s.width, s.height * i / 4), paint);
    for (var i = 0; i < 8; i++) c.drawLine(Offset(s.width * i / 7, 0), Offset(s.width * i / 7, s.height), paint);
  }
  @override
  bool shouldRepaint(covariant _GridLines oldDelegate) => false;
}

class _PaymentRing extends CustomPainter {
  const _PaymentRing();
  @override
  void paint(Canvas c, Size s) {
    final rect = Rect.fromLTWH(8, 8, s.width - 16, s.height - 16);
    var angle = -math.pi / 2;
    const fractions = [.52, .28, .15, .05];
    const colors = [_red, Color(0xFFFF9BAB), Color(0xFF87AEFF), Color(0xFFA6A6B3)];
    for (var i = 0; i < fractions.length; i++) {
      final sweep = fractions[i] * math.pi * 2;
      c.drawArc(rect, angle + .008, sweep - .016, false, Paint()..color = colors[i]..style = PaintingStyle.stroke..strokeWidth = 15..strokeCap = StrokeCap.butt);
      angle += sweep;
    }
  }
  @override
  bool shouldRepaint(covariant _PaymentRing oldDelegate) => false;
}

class _EwashoMark extends CustomPainter {
  const _EwashoMark();
  @override
  void paint(Canvas c, Size size) {
    c.save(); c.scale(size.width / 50, size.height / 52);
    final white = Paint()..color = Colors.white;
    final loop = Path()..moveTo(4, 30)..cubicTo(1, 12, 14, 2, 29, 6)..cubicTo(48, 12, 36, 27, 16, 26)..cubicTo(28, 23, 36, 17, 29, 13)..cubicTo(20, 6, 8, 19, 4, 30)..close();
    c.drawPath(loop, white);
    final wave = Path()..moveTo(4, 30)..cubicTo(15, 16, 29, 43, 43, 26)..cubicTo(39, 43, 26, 46, 17, 39)..cubicTo(12, 34, 9, 29, 4, 30)..close();
    c.drawPath(wave, white);
    final bottom = Path()..moveTo(4, 33)..cubicTo(13, 27, 15, 48, 34, 44)..cubicTo(18, 53, 5, 45, 4, 33)..close();
    c.drawPath(bottom, white);
    c.drawCircle(const Offset(43, 16), 2.8, white); c.drawCircle(const Offset(39, 23), 1.8, white);
    final star = Path()..moveTo(39, 0)..quadraticBezierTo(39, 6, 44, 7)..quadraticBezierTo(39, 8, 39, 13)..quadraticBezierTo(38, 8, 34, 7)..quadraticBezierTo(38, 6, 39, 0);
    c.drawPath(star, white); c.restore();
  }
  @override
  bool shouldRepaint(covariant _EwashoMark oldDelegate) => false;
}
