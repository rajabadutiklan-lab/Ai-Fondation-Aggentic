import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ewasho/main.dart';

void main() {
  testWidgets('Home renders, slider swipes and menu opens', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const EwashoApp());
    expect(find.text('EWASHO'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(PageView), const Offset(-350, 0));
    await tester.pumpAndSettle();
    expect(find.text('Semua Pesanan\nLebih Teratur'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('PESANAN'));
    await tester.pumpAndSettle();
    expect(find.text('Kembali'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
