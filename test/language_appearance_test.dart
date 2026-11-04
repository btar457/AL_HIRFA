import 'package:al_hirfa/core/constants/colors.dart';
import 'package:al_hirfa/core/settings/app_prefs.dart';
import 'package:al_hirfa/screens/shared/language_appearance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: LanguageAppearanceScreen(firstRun: true)));
  }

  testWidgets('first run defaults to Arabic + dark and previews English live', (tester) async {
    await AppPrefs.load();
    await pump(tester);
    expect(find.text('اختر لغتك ومظهر التطبيق'), findsOneWidget);
    expect(find.text('متابعة'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pump();
    expect(find.text('Choose your language and theme'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(tester.widget<Directionality>(find.byType(Directionality).first).textDirection, TextDirection.ltr);
  });

  testWidgets('saving persists language and theme, and colors follow the theme', (tester) async {
    await AppPrefs.load();
    expect(AppPrefs.hasChosen, isFalse);
    final darkBackground = AppColors.background;
    await pump(tester);

    await tester.tap(find.text('English'));
    await tester.pump();
    await tester.tap(find.text('Light'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(AppPrefs.isEnglish, isTrue);
    expect(AppPrefs.isDark, isFalse);
    expect(AppPrefs.hasChosen, isTrue);
    expect(tr('عربي', 'English'), 'English');
    expect(AppColors.background, isNot(darkBackground));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_language'), 'en');
    expect(prefs.getBool('app_dark_mode'), isFalse);

    // يعود للافتراضي كي لا يؤثر على بقية الاختبارات
    await AppPrefs.instance.update(language: 'ar', isDark: true);
  });
}
