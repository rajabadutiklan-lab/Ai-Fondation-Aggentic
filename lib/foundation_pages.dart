import 'package:flutter/material.dart';
const coral = Color(0xFFFF4B50);
const ink = Color(0xFF152442);
class FoundationPage extends StatefulWidget {
  final String title;
  const FoundationPage({super.key, required this.title});
  @override
  State<FoundationPage> createState() => _FoundationPageState();
}
class _FoundationPageState extends State<FoundationPage> {
  String filter = 'Semua';
  final search = TextEditingController();
  @override void dispose() { search.dispose(); super.dispose(); }
  void open(String name) => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => FoundationPage(title: name)));
  Widget card(Widget child) => Container(padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .94), borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white), boxShadow: const [BoxShadow(color: Color(0x120C2340), blurRadius: 16, offset: Offset(0,4))]), child: child);
  Widget heading(String name) => Padding(padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(name, style: const TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 17)));
  Widget tile(String name, String subtitle, IconData icon, Color color, {String? status}) => InkWell(onTap: () => open(name),
    child: card(Row(children: [
      CircleAvatar(backgroundColor: color.withValues(alpha: .12), child: Icon(icon, color: color)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(color: ink, fontWeight: FontWeight.w600, fontSize: 14)),
        Text(subtitle, style: const TextStyle(color: Colors.blueGrey, fontSize: 11))])),
      if (status != null) Text(status, style: TextStyle(color: color, fontSize: 11)),
      const Icon(Icons.chevron_right, size: 19, color: Colors.blueGrey),
    ])));
  Widget filters(List<String> names) => SingleChildScrollView(scrollDirection: Axis.horizontal,
    child: Row(children: names.map((name) => Padding(padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(name, style: TextStyle(color: filter == name ? Colors.white : ink, fontSize: 12)),
        selected: filter == name, selectedColor: coral, backgroundColor: Colors.white,
        side: BorderSide.none, showCheckmark: false, onSelected: (_) => setState(() => filter = name)))).toList()));
  Widget metric(String name, String value, IconData icon) => Expanded(child: card(SizedBox(height: 94,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: coral, size: 21), const Spacer(),
      FittedBox(child: Text(value, style: const TextStyle(color: ink, fontSize: 21, fontWeight: FontWeight.bold))),
      Text(name, style: const TextStyle(color: Colors.blueGrey, fontSize: 11)),
    ]))));
  Widget metrics(String a, String av, IconData ai, String b, String bv, IconData bi) =>
    Row(children: [metric(a,av,ai), const SizedBox(width: 10), metric(b,bv,bi)]);
  Widget grid(List<(String,String,IconData,Color)> entries) => GridView.count(
    crossAxisCount: 3, mainAxisSpacing: 9, crossAxisSpacing: 9, childAspectRatio: .92,
    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
    children: entries.map((e) => InkWell(onTap: () => open(e.$1),
      child: card(Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(e.$3, size: 29, color: e.$4), const SizedBox(height: 8),
        Text(e.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ink)),
        Text(e.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
      ])))).toList());
  Widget center() => Column(children: [
    const SizedBox(height: 12),
    Container(height: 116, width: 116, decoration: BoxDecoration(shape: BoxShape.circle,
      gradient: const RadialGradient(colors: [Color(0xFFFFE4E4),Color(0xFFFF8588),coral]),
      boxShadow: [BoxShadow(color: coral.withValues(alpha: .22), blurRadius: 25)]),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 60)),
    heading('AI Pusat'),
    const Text('Kendalikan kecerdasan agentic\nuntuk semua perusahaan',
      textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey)),
    const SizedBox(height: 12), const Chip(label: Text('Mode demo • Belum terhubung API')),
    const SizedBox(height: 14),
    grid([
      ('Model AI','Pilih model',Icons.psychology,Colors.deepPurple),
      ('API Key','Kelola kunci',Icons.key,Colors.blue),
      ('Agent','Buat agent',Icons.smart_toy,Colors.deepPurple),
      ('Knowledge','Pengetahuan',Icons.menu_book,coral),
      ('Workflow','Alur kerja',Icons.account_tree,Colors.deepPurple),
      ('Monitoring','Aktivitas',Icons.bar_chart,Colors.blue),
    ]),
    heading('Statistik AI'),
    metrics('Total Request','128',Icons.bolt,'Berhasil','98',Icons.check_circle),
    const SizedBox(height: 10),
    tile('Aktivitas Agent','Agent marketing membuat konten',Icons.smart_toy,Colors.deepPurple),
  ]);
  Widget companies() => Column(children: [
    TextField(controller: search, onChanged: (_) => setState(() {}),
      decoration: InputDecoration(hintText: 'Cari perusahaan...', prefixIcon: const Icon(Icons.search),
        filled: true, fillColor: Colors.white, border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
    const SizedBox(height: 12), filters(['Semua','Aktif','Nonaktif']),
    const SizedBox(height: 14),
    for (final c in [
      ('RajaBadut','12 Agent • Sehat',Colors.purple,true),
      ('Goyana','8 Agent • Warning',Colors.orange,true),
      ('Chatku','6 Agent • Sehat',Colors.blue,true),
      ('Ewasho','5 Agent • Sehat',coral,true),
      ('Kosana','0 Agent • Nonaktif',Colors.blueGrey,false),
    ]) if (c.$1.toLowerCase().contains(search.text.toLowerCase()) &&
      (filter == 'Semua' || (filter == 'Aktif') == c.$4))
      Padding(padding: const EdgeInsets.only(bottom: 9),
        child: tile(c.$1,c.$2,Icons.apartment,c.$3)),
    const SizedBox(height: 8),
    FilledButton.icon(onPressed: () => open('Tambah Perusahaan'),
      icon: const Icon(Icons.add), label: const Text('Tambah Perusahaan')),
  ]);
  Widget monitor() => Column(children: [
    filters(['Semua','Agent','Aktivitas','Sistem']),
    const SizedBox(height: 12),
    metrics('CPU Server','32%',Icons.memory,'Memori','68%',Icons.storage),
    const SizedBox(height: 10),
    metrics('Request/menit','120',Icons.speed,'Uptime','99.8%',Icons.cloud_done),
    heading('Aktivitas Real-time'),
    tile('Agent Marketing','Membuat konten Instagram',Icons.smart_toy,Colors.deepPurple),
    const SizedBox(height: 9),
    tile('Analisis Kompetitor','Laporan selesai dibuat',Icons.analytics,coral),
    const SizedBox(height: 9),
    tile('Goyana','Campaign menunggu persetujuan',Icons.apartment,Colors.blue),
  ]);
  Widget budget() => Column(children: [
    metrics('Total Budget','Rp 12.500.000',Icons.wallet,'Realisasi','Rp 8.420.000',Icons.pie_chart),
    const SizedBox(height: 14), filters(['Semua','Perusahaan','Kategori','Bulanan']),
    heading('Anggaran Perusahaan'),
    for (final e in [('RajaBadut',.7),('Goyana',.6),('Chatku',.8),('Ewasho',.5),('Kosana',.4)])
      Padding(padding: const EdgeInsets.only(bottom: 9), child: card(Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e.$1, style: const TextStyle(color: ink, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: e.$2, color: coral, backgroundColor: const Color(0xFFE8EDF2),
            minHeight: 7, borderRadius: BorderRadius.circular(5)),
          const SizedBox(height: 5),
          Text((e.$2 * 100).round().toString() + '% digunakan',
            style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
        ]))),
  ]);
  Widget approvals() => Column(children: [
    filters(['Semua','Menunggu','Disetujui','Ditolak']),
    const SizedBox(height: 14),
    for (final e in [
      ('Budget Marketing','Goyana • Rp 2.500.000','Menunggu'),
      ('Konten Instagram','RajaBadut • 5 konten','Menunggu'),
      ('Campaign Iklan','Chatku • Rp 1.200.000','Disetujui'),
      ('Kerjasama Influencer','Ewasho • Rp 3.000.000','Ditolak'),
      ('Pembelian Tools AI','RajaBadut • Rp 800.000','Disetujui'),
    ]) if (filter == 'Semua' || filter == e.$3)
      Padding(padding: const EdgeInsets.only(bottom: 9),
        child: tile(e.$1,e.$2,Icons.fact_check,
          e.$3 == 'Disetujui' ? Colors.green : e.$3 == 'Ditolak' ? coral : Colors.orange,status:e.$3)),
  ]);
  Widget integrations() => grid([
    ('WhatsApp','Pesan otomatis',Icons.chat,Colors.green),
    ('Instagram','Posting konten',Icons.camera_alt,Colors.pink),
    ('TikTok','Posting konten',Icons.music_note,ink),
    ('Google Maps','Data lokasi',Icons.place,Colors.blue),
    ('OpenAI','Integrasi AI',Icons.auto_awesome,ink),
    ('Anthropic','Integrasi AI',Icons.psychology,Colors.deepPurple),
    ('Google Drive','Penyimpanan',Icons.cloud,Colors.green),
    ('Email','Notifikasi',Icons.email,coral),
    ('API','Koneksi custom',Icons.link,Colors.blue),
  ]);
  Widget reports() => Column(children: [
    filters(['Semua','Harian','Mingguan','Bulanan','Kustom']),
    const SizedBox(height: 12),
    metrics('Aktivitas AI','248',Icons.bolt,'Biaya AI','Rp 1.250.000',Icons.payments),
    heading('Grafik Aktivitas'),
    card(SizedBox(height: 165, child: Row(crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [45.0,65,55,95,75,115,90].asMap().entries.map((e) =>
        Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(height: e.value, width: 25,
            decoration: BoxDecoration(color: coral.withValues(alpha: e.key == 5 ? 1 : .25 + e.key * .08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)))),
          const SizedBox(height: 8),
          Text((e.key + 3).toString(), style: const TextStyle(fontSize: 10)),
        ])).toList()))),
    heading('Aktivitas Perusahaan'),
    for (final e in [('RajaBadut','42%'),('Goyana','28%'),('Chatku','18%'),('Ewasho','12%')])
      Padding(padding: const EdgeInsets.only(bottom: 9),
        child: tile(e.$1,'Kontribusi aktivitas AI',Icons.bar_chart,coral,status:e.$2)),
  ]);
  Widget settings() => Column(children: [
    for (final e in [
      ('Profil','Akun pengguna',Icons.person),
      ('Keamanan','Akses dan otorisasi',Icons.security),
      ('Model AI','Provider dan model',Icons.psychology),
      ('API Key','Kredensial tersimpan di backend',Icons.key),
      ('Notifikasi','Pemberitahuan',Icons.notifications),
      ('Audit Aktivitas','Riwayat tindakan',Icons.history),
      ('Tentang Kami','AI Foundation',Icons.info),
    ]) Padding(padding: const EdgeInsets.only(bottom: 9),
      child: tile(e.$1,e.$2,e.$3,coral)),
  ]);
  Widget generic() => Column(children: [
    card(Column(children: [
      const Icon(Icons.construction_outlined, size: 48, color: coral),
      const SizedBox(height: 12),
      Text(widget.title, style: const TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: 20)),
      const SizedBox(height: 8),
      const Text('Rancangan modul. Fitur operasional belum tersambung ke backend.',
        textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey)),
    ])),
    if (widget.title == 'Tambah Perusahaan') ...[
      const SizedBox(height: 12),
      const TextField(decoration: InputDecoration(labelText: 'Nama perusahaan', filled: true, fillColor: Colors.white)),
      const SizedBox(height: 10),
      FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mode demo: data belum disimpan'))),
        child: const Text('Simpan (Demo)')),
    ],
  ]);
  @override Widget build(BuildContext context) {
    Widget body;
    switch(widget.title) {
      case 'AI Pusat': body=center(); break;
      case 'Perusahaan': case 'Status Perusahaan': body=companies(); break;
      case 'Monitor': case 'Monitoring': body=monitor(); break;
      case 'Budgeting': body=budget(); break;
      case 'Approval': body=approvals(); break;
      case 'Tools & Integrasi': body=integrations(); break;
      case 'Laporan': body=reports(); break;
      case 'Pengaturan': body=settings(); break;
      default: body=generic();
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), foregroundColor: Colors.white,
        flexibleSpace: const DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFF343E),Color(0xFFFF7168)])))),
      body: DecoratedBox(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFFE9EDF2),Color(0xFFF9FAFB),Color(0xFFF0F3F6)])),
        child: SafeArea(child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(padding: const EdgeInsets.all(14), children: [
            body, const SizedBox(height: 24),
            const Center(child: Text('DATA SIMULASI • BELUM TERHUBUNG BACKEND',
              style: TextStyle(fontSize: 10, color: Colors.blueGrey))),
          ]))))),
    );
  }
}
