// EWASHO — prototipe UI Flutter, tanpa paket tambahan.
// Buat proyek: flutter create ewasho
// Salin file ini ke lib/main.dart, lalu flutter run.
// Data contoh. Menu membuka placeholder, belum terhubung backend/kamera.
// Logo dan ilustrasi dibuat dengan widget; bukan aset asli referensi.
// Opsional ganti _BrandMark dan _LaundryArt dengan Image.asset milik EWASHO.
// Efek kaca hanya _PromoSlider: satu BackdropFilter, clipped, sigma 5.
// Untuk perangkat rendah, set enableGlass = false (tetap tampak translucent).
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'reports.dart';

const red = Color(0xFFE71932);
const ink = Color(0xFF172031);
const muted = Color(0xFF747D8C);
const cream = Color(0xFFFFEFF0);
const enableGlass = true;

import 'ai_foundation_home.dart' as foundation;

void main() => foundation.main();


class EwashoApp extends StatelessWidget {
  const EwashoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'EWASHO',
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: red),
      scaffoldBackgroundColor: const Color(0xFFFFF7F7),
      textTheme: const TextTheme(bodyMedium: TextStyle(color: ink)),
      appBarTheme: const AppBarTheme(backgroundColor: red, foregroundColor: Colors.white)),
    home: const EwashoHome(),
  );
}

class EwashoHome extends StatefulWidget {
  const EwashoHome({super.key});
  @override
  State<EwashoHome> createState() => _EwashoHomeState();
}

class _EwashoHomeState extends State<EwashoHome> {
  String outlet = 'Outlet Utama';
  void open(String title) => Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => title.toLowerCase() == 'laporan' ? ReportsPage(onOpen: open) : Scaffold(appBar: AppBar(title: Text(title)), body: Center(
      child: Padding(padding: const EdgeInsets.all(32), child: Column(
        mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.local_laundry_service_outlined, size: 64, color: red),
          const SizedBox(height: 20), Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12), const Text('Halaman contoh prototipe. Hubungkan menu ini ke fitur aplikasi.', textAlign: TextAlign.center),
          const SizedBox(height: 24), FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Kembali')),
        ]))))));
  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(decoration: const BoxDecoration(gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFFF3746), Color(0xFFDC1027), Color(0xFFFF4752)])),
      child: SafeArea(bottom: false, child: Column(children: [
        Expanded(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 18, 16, 26), children: [
            Row(children: [const _BrandMark(), const SizedBox(width: 8),
              const Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('EWASHO', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                  Text('K A S I R  L A U N D R Y', style: TextStyle(fontSize: 8, color: Colors.white)),
                ]))),
              PopupMenuButton<String>(tooltip: 'Pilih outlet', initialValue: outlet,
                onSelected: (value) => setState(() => outlet = value),
                itemBuilder: (_) => ['Outlet Utama', 'Outlet Cabang'].map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(color: const Color(0xFFC8142A), borderRadius: BorderRadius.circular(16)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.storefront_outlined, size: 19, color: Colors.white), const SizedBox(width: 6),
                    Text(outlet, style: const TextStyle(color: Colors.white, fontSize: 11)),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18)]))),
              IconButton(tooltip: 'Notifikasi', onPressed: () => open('Notifikasi'), icon: const Icon(Icons.notifications_none_rounded, color: Colors.white)),
            ]),
            const SizedBox(height: 24),
            const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _Revenue(title: 'Omzet Hari Ini', amount: 'Rp 1.250.000', change: '+12%', period: 'dari kemarin', icon: Icons.account_balance_wallet_outlined)),
              SizedBox(width: 10),
              Expanded(child: _Revenue(title: 'Omzet Bulanan', amount: 'Rp 28.750.000', change: '+8%', period: 'dari bulan lalu', icon: Icons.bar_chart_rounded)),
            ]),
            const SizedBox(height: 14),
            _PromoSlider(onTutorial: () => open('Tutorial')),
            const SizedBox(height: 14),
            LayoutBuilder(builder: (context, constraints) {
              final width = (constraints.maxWidth - 12) / 2;
              return Wrap(spacing: 12, runSpacing: 12, children: [
                for (final menu in const [
                  ('PESANAN', 'Kelola transaksi', Icons.assignment_rounded),
                  ('LAPORAN', 'Omzet & statistik', Icons.bar_chart_rounded),
                  ('SCAN PESANAN', 'Cek status & ambil', Icons.qr_code_scanner_rounded),
                  ('PENGATURAN', 'Outlet, layanan, dll', Icons.settings_rounded),
                ]) SizedBox(width: width, child: _MenuCard(title: menu.$1, subtitle: menu.$2,
                  icon: menu.$3, onTap: () => open(menu.$1))),
              ]);
            }),
          ])))),
        _BottomBar(onOpen: open),
      ]))),
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) => const SizedBox(width: 43, height: 50,
    child: Center(child: Text('e', style: TextStyle(fontSize: 57, height: .85,
      fontStyle: FontStyle.italic, fontWeight: FontWeight.w900, color: Colors.white))));
}

class _Revenue extends StatelessWidget {
  const _Revenue({required this.title, required this.amount, required this.change, required this.period, required this.icon});
  final String title, amount, change, period;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(22)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: red, size: 24), const SizedBox(width: 7),
        Expanded(child: Text(title, style: const TextStyle(color: muted, fontSize: 11)))]),
      const SizedBox(height: 12),
      FittedBox(fit: BoxFit.scaleDown, child: Text(amount, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink))),
      const SizedBox(height: 8),
      Text('↗ $change', style: const TextStyle(color: Color(0xFF16A56C), fontWeight: FontWeight.bold, fontSize: 13)),
      Text(period, style: const TextStyle(color: muted, fontSize: 10)),
    ]));
}

class _PromoSlider extends StatefulWidget {
  const _PromoSlider({required this.onTutorial});
  final VoidCallback onTutorial;
  @override
  State<_PromoSlider> createState() => _PromoSliderState();
}
class _PromoSliderState extends State<_PromoSlider> {
  final controller = PageController();
  int page = 0;
  static const slides = [
    ('Laundry Rapi\nPelanggan Happy', 'Kelola usaha laundry\nlebih mudah bersama EWASHO'),
    ('Semua Pesanan\nLebih Teratur', 'Pantau proses cucian\ndalam satu aplikasi.'),
    ('Usaha Berkembang\nMakin Tenang', 'Lihat ringkasan omzet\ndan laporan usaha Anda.'),
  ];
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final content = Container(decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0x40FFFFFF), Color(0x0DFFFFFF)]),
      borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0x80FFFFFF))),
      child: Column(children: [Expanded(child: PageView.builder(controller: controller,
        itemCount: slides.length, onPageChanged: (value) => setState(() => page = value),
        itemBuilder: (context, index) => Padding(padding: const EdgeInsets.fromLTRB(20, 20, 8, 0),
          child: Row(children: [Expanded(flex: 6, child: LayoutBuilder(builder: (context, bounds) => FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: SizedBox(width: bounds.maxWidth, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(slides[index].$1, style: const TextStyle(color: Colors.white, fontSize: 21, height: 1.15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10), Text(slides[index].$2, style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4)),
              const SizedBox(height: 10), TextButton(onPressed: widget.onTutorial,
                style: TextButton.styleFrom(foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12),
                  side: const BorderSide(color: Color(0x99FFFFFF)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                child: const Text('Lihat Tutorial  ›', style: TextStyle(fontSize: 12))),
            ]))))), const Expanded(flex: 4, child: RepaintBoundary(child: _LaundryArt()))])))),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(slides.length, (index) =>
          Semantics(label: 'Slide ${index + 1}', selected: page == index, button: true,
            child: GestureDetector(onTap: () => controller.animateToPage(index, duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
              child: SizedBox(width: 28, height: 30, child: Center(child: Container(width: 7, height: 7,
                decoration: BoxDecoration(shape: BoxShape.circle, color: page == index ? Colors.white : const Color(0x55FFFFFF))))))))),
      ]));
    return SizedBox(height: 250 + ((MediaQuery.textScalerOf(context).scale(14) - 14).clamp(0, 24).toDouble() * 5),
      child: RepaintBoundary(child: ClipRRect(borderRadius: BorderRadius.circular(24),
        child: enableGlass ? BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5), child: content) : content)));
  }
}

// Ilustrasi vektor ringan, tanpa unduhan atau animasi terus menerus.
class _LaundryArt extends StatelessWidget {
  const _LaundryArt();
  @override
  Widget build(BuildContext context) => FittedBox(child: SizedBox(width: 125, height: 150,
    child: Stack(alignment: Alignment.bottomCenter, children: [
      Positioned(top: 10, right: 6, child: Icon(Icons.auto_awesome, color: Colors.white.withAlpha(220), size: 24)),
      Positioned(bottom: 55, left: 8, child: Column(children: [
        for (final color in [const Color(0xFFFFBDC3), Colors.white, const Color(0xFFFFB1B8)])
          Container(width: 78, height: 18, margin: const EdgeInsets.only(bottom: 3),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(7))),
      ])),
      Positioned(bottom: 4, left: 0, child: Container(width: 92, height: 65,
        decoration: BoxDecoration(color: const Color(0xFFFFE6E8), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.local_laundry_service_outlined, color: red, size: 48))),
      Positioned(bottom: 4, right: 0, child: Container(width: 38, height: 81,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.water_drop, color: red, size: 23))),
      Positioned(bottom: 82, right: 9, child: Container(width: 22, height: 18,
        decoration: BoxDecoration(color: const Color(0xFFFF7C87), borderRadius: BorderRadius.circular(4)))),
    ])));
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.title, required this.subtitle, required this.icon, required this.onTap});
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(color: cream, borderRadius: BorderRadius.circular(23),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(23), child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 17), child: Column(children: [
        Container(width: 67, height: 65, decoration: BoxDecoration(color: const Color(0xFFFFDDE1), borderRadius: BorderRadius.circular(24)),
          child: Icon(icon, color: red, size: 42)),
        const SizedBox(height: 10), Text(title, textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: ink)),
        const SizedBox(height: 5), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: muted, fontSize: 11)),
      ]))));
}
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onOpen});
  final ValueChanged<String> onOpen;
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    child: SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      child: Row(children: [
        item('Beranda', Icons.home_rounded, true, () {}),
        item('Pesanan', Icons.assignment_outlined, false, () => onOpen('Pesanan')),
        Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 56, height: 56, child: IconButton.filled(
            tooltip: 'Buka kamera scan', onPressed: () => onOpen('Scan Kamera'),
            style: IconButton.styleFrom(backgroundColor: red), icon: const Icon(Icons.qr_code_scanner, size: 29))),
          const SizedBox(height: 3), const Text('Scan', style: TextStyle(fontSize: 10, color: muted)),
        ])),
        item('Laporan', Icons.bar_chart, false, () => onOpen('Laporan')),
        item('Profil', Icons.person_outline_rounded, false, () => onOpen('Profil')),
      ]))));
  Widget item(String label, IconData icon, bool selected, VoidCallback tap) => Expanded(
    child: Material(color: selected ? cream : Colors.white, borderRadius: BorderRadius.circular(19),
      child: InkWell(onTap: tap, borderRadius: BorderRadius.circular(19), child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: selected ? red : muted, size: 27), const SizedBox(height: 5),
          Text(label, style: TextStyle(color: selected ? red : muted, fontSize: 10)),
        ])))));
}
