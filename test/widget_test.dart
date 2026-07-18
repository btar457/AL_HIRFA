import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:al_hirfa/widgets/common/founder_access_gate.dart';

void main() {
  testWidgets('FounderAccessCredit opens founder dialog only after a full 5s hold', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FounderAccessCredit())));

    final finder = find.text('المؤسس Mustafa Alshlany');
    expect(finder, findsOneWidget);
    expect(find.text('دخول المؤسس'), findsNothing);

    final gesture = await tester.startGesture(tester.getCenter(finder));
    await tester.pump(const Duration(seconds: 1)); // يسمح لمُتعرِّف onLongPressStart نفسه بالفوز أولاً (~500ms)
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('دخول المؤسس'), findsNothing, reason: 'لا يجب أن يظهر النموذج قبل اكتمال 5 ثوانٍ كاملة');

    await tester.pump(const Duration(seconds: 3));
    await gesture.up();
    await tester.pump();
    expect(find.text('دخول المؤسس'), findsOneWidget, reason: 'يجب أن يظهر النموذج فور اكتمال 5 ثوانٍ من الضغط المستمر');
  });

  testWidgets('releasing before 5s cancels the timer and no dialog appears', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FounderAccessCredit())));

    final finder = find.text('المؤسس Mustafa Alshlany');
    final gesture = await tester.startGesture(tester.getCenter(finder));
    await tester.pump(const Duration(seconds: 1));
    await gesture.up();
    await tester.pump(const Duration(seconds: 10));

    expect(find.text('دخول المؤسس'), findsNothing);
  });
}
