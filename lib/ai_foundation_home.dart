import 'package:flutter/material.dart';

void main() => runApp(const AiFoundationApp());

const navy = Color(0xFF101E46);
const blue = Color(0xFF258DFF);

class AiFoundationApp extends StatelessWidget {
  const AiFoundationApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'AI Foundation',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: blue), scaffoldBackgroundColor: const Color(0xFFF2F7FF)),
    home: const FoundationHome(),
  );
}

class FoundationHome extends StatefulWidget {
  const FoundationHome({super.key});
  @override
  State<FoundationHome> createState() => _FoundationHomeState();
}

class _FoundationHomeState extends State<FoundationHome> {
  String selected = 'Semua Perusahaan';
  void open(String name) => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => Scaffold(
    appBar: AppBar(title: Text(name)),
    body: Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(name == 'AI Pusat' ? Icons.auto_awesome : Icons.dashboard_customize_outlined, size: 62, color: blue),
      const SizedBox(height: 16), Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Text(name == 'AI Pusat' ? 'Pusat kendali agentic: model AI, API key, agent, tugas, dan pemantauan. Konfigurasi backend belum tersambung.' : 'Modul $name sedang disiapkan. Belum tersambung ke data operasional.', textAlign: TextAlign.center),
    ]))),
  )));
  Widget glass({required Widget child, EdgeInsets padding = const EdgeInsets.all(16)}) => Container(
    padding: padding,
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .80), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white, width: 1.5), boxShadow: const [BoxShadow(color: Color(0x132B67AA), blurRadius: 22, offset: Offset(0, 7))]),
    child: child,
  );
  Widget core(String name, String subtitle, IconData icon, Color color, {bool big = false}) => Expanded(
    flex: big ? 12 : 10,
    child: InkWell(onTap: () => open(name), borderRadius: BorderRadius.circular(20), child: Column(children: [
      Container(height: big ? 100 : 82, width: big ? 100 : 82, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Colors.white, color.withValues(alpha: .26), color.withValues(alpha: .62)]), boxShadow: [BoxShadow(color: color.withValues(alpha: .18), blurRadius: 22)]), child: Icon(icon, size: big ? 49 : 42, color: color)),
      const SizedBox(height: 9), Text(name, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: big ? 17 : 15, color: navy)),
      Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
    ])),
  );
  Widget menu(String name, IconData icon, Color color) => InkWell(
    onTap: () => open(name), borderRadius: BorderRadius.circular(22),
    child: glass(child: SizedBox(height: 91, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 33, color: color), const SizedBox(height: 8),
      Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: navy)),
    ]))),
  );
  Widget nav(String name, IconData icon, {bool central = false}) => Expanded(child: InkWell(
    onTap: () => name == 'Beranda' ? null : open(name),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: central ? 66 : 38, height: central ? 66 : 38,
        decoration: central ? const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFFF5258), Color(0xFFE90024)])) : null,
        child: Icon(icon, color: central ? Colors.white : name == 'Beranda' ? Colors.red : const Color(0xFF45566F), size: central ? 31 : 26)),
      Text(name, style: TextStyle(fontSize: 11, color: name == 'Beranda' ? Colors.red : navy)),
    ]),
  ));
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650), child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: [
      Row(children: [
        const Icon(Icons.auto_awesome, color: blue, size: 33), const SizedBox(width: 7),
        const Expanded(child: Text('AI Foundation', style: TextStyle(color: navy, fontSize: 23, fontWeight: FontWeight.bold))),
        PopupMenuButton<String>(tooltip: 'Pilih perusahaan', onSelected: (value) => setState(() => selected = value), itemBuilder: (_) => ['Semua Perusahaan', 'RajaBadut', 'Goyana', 'Chatku'].map((e) => PopupMenuItem(value: e, child: Text(e))).toList(), child: Row(children: [Text(selected, style: const TextStyle(fontSize: 11)), const Icon(Icons.keyboard_arrow_down)])),
        IconButton(onPressed: () => open('Notifikasi'), icon: const Icon(Icons.notifications_outlined)),
      ]),
      const SizedBox(height: 30),
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        core('AI Builder', 'Buat & Kembangkan', Icons.view_in_ar_rounded, blue),
        core('AI Pusat', 'Kelola & Pantau', Icons.auto_awesome, const Color(0xFF6755E9), big: true),
        core('AI Guardian', 'Lindungi & Optimalkan', Icons.verified_user_rounded, const Color(0xFF00BA9B)),
      ]),
      const SizedBox(height: 24),
      glass(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.bar_chart, color: blue), SizedBox(width: 8), Expanded(child: Text('Ringkasan Hari Ini', style: TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.bold)))]),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          for (final item in [('12','Perusahaan','Aktif'),('48','Agent','Aktif'),('7','Approval',''),('2','Alert','')])
            Expanded(child: Column(children: [Text(item.$1, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: navy)), Text(item.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)), Text(item.$3, style: const TextStyle(fontSize: 10))])),
        ]),
      ])),
      const SizedBox(height: 16),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 10, childAspectRatio: 1.05, children: [
        menu('Perusahaan', Icons.apartment, blue),
        menu('Tambah Perusahaan', Icons.add_business, const Color(0xFF00B9B0)),
        menu('Monitor', Icons.monitor_heart_outlined, blue),
        menu('Budgeting', Icons.paid_outlined, Colors.orange),
        menu('Approval', Icons.fact_check_outlined, const Color(0xFF00BDA8)),
        menu('Tools & Integrasi', Icons.extension_outlined, const Color(0xFF7555E9)),
      ]),
      const SizedBox(height: 16),
      glass(child: Column(children: [
        Row(children: [const Icon(Icons.monitor_heart_outlined, color: blue), const SizedBox(width: 8), const Expanded(child: Text('Status Perusahaan', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 17))), TextButton(onPressed: () => open('Status Perusahaan'), child: const Text('Lihat Semua'))]),
        for (final item in [('RajaBadut','Sehat','+12%',Colors.green),('Goyana','Warning','-6%',Colors.orange),('Chatku','Sehat','+4%',Colors.green)])
          ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: CircleAvatar(backgroundColor: item.$4.withValues(alpha: .17), child: Text(item.$1[0], style: TextStyle(color: item.$4))), title: Text(item.$1, style: const TextStyle(fontSize: 14)), subtitle: Text(item.$2, style: const TextStyle(fontSize: 11)), trailing: Text(item.$3, style: TextStyle(color: item.$4, fontWeight: FontWeight.bold)), onTap: () => open(item.$1)),
      ])),
      const SizedBox(height: 12),
      const Center(child: Text('Data simulasi • Belum terhubung backend', style: TextStyle(color: Colors.blueGrey, fontSize: 11))),
    ])))),
    bottomNavigationBar: SafeArea(top: false, child: Container(padding: const EdgeInsets.fromLTRB(8, 7, 8, 8), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))), child: Row(children: [
      nav('Beranda', Icons.home_outlined), nav('Perusahaan', Icons.apartment_outlined), nav('AI Pusat', Icons.auto_awesome, central: true), nav('Laporan', Icons.bar_chart_outlined), nav('Pengaturan', Icons.settings_outlined),
    ]))),
  );
}
