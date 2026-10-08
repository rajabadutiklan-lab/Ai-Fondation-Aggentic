import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ewasho/main.dart';
import 'package:ewasho/reports.dart';

void main() {
  setUpAll(() async {
    final icons = FontLoader('MaterialIcons');
    icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    final root = Platform.environment['FLUTTER_ROOT'];
    if (root != null) {
      final file = File('$root/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf');
      if (file.existsSync()) {
        final loader = FontLoader('Roboto');
        loader.addFont(Future.value(ByteData.sublistView(await file.readAsBytes())));
        await loader.load();
      }
    }
  });
  testWidgets('Report menu opens and filters work without overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const EwashoApp());
    await tester.tap(find.text('Laporan'));
    await tester.pumpAndSettle();
    expect(find.byType(ReportsPage), findsOneWidget);
    expect(find.text('Grafik Omzet'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('period-Mingguan')));
    await tester.pumpAndSettle();
    expect(find.text('Omzet Mingguan'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('chart-Pesanan')));
    await tester.pumpAndSettle();
    expect(find.text('48 pesanan'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('report-bar-2')));
    await tester.pumpAndSettle();
    expect(find.text('34 pesanan'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Beranda').last);
    await tester.pumpAndSettle();
    expect(find.byType(ReportsPage), findsNothing);
  });
  testWidgets('Report reference layout and capture', (tester) async {
    tester.view.physicalSize = const Size(432, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      home: RepaintBoundary(key: key, child: ReportsPage(onOpen: (_) {}))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      Directory('screenshots').createSync(recursive: true);
      File('screenshots/ewasho-laporan.png').writeAsBytesSync(data!.buffer.asUint8List());
      image.dispose();
    });
  });
}
