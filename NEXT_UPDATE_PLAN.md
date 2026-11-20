# خطة التحديث القادم

بنود مُعتمَدة من صاحب التطبيق للتنفيذ في التحديث القادم (بعد الإصدار
1.0.0+27 المنشور على مرحلة الإنتاج). كل بند يُشطَب هنا عند تنفيذه.

## 1. إزالة مكتبة SafetyNet القديمة (مُعتمَد — أولوية)

**المصدر:** تنبيه Play Console ← مرحلة الإنتاج ← لوحة بيانات الإصدارات ←
«يستخدم تطبيقك إصداراً من حزمة SDK يتضمن ملاحظة بالغة الأهمية من
play-services-safetynet» (الجودة الفنية، الإصدار 27).

**السبب:** `firebase_app_check` 0.3.2+x يضمّن في Android
`com.google.firebase:firebase-appcheck-safetynet` (راجع
`android/build.gradle` داخل الحزمة). التطبيق لا يستخدمه فعلياً — `main.dart`
يفعّل `AndroidProvider.playIntegrity` — لكن وجوده في الحزمة يكفي للتنبيه،
وGoogle أوقفت SafetyNet Attestation.

**الخطوات:**
1. ترقية حزم FlutterFire معاً إلى إصدارات متوافقة (BoM واحد):
   `firebase_core`، `firebase_auth`، `cloud_firestore`، `firebase_messaging`،
   `firebase_crashlytics`، و`firebase_app_check` إلى إصدار لا يضمّن SafetyNet
   (سلسلة 0.4.x أو أحدث).
2. مراجعة تغييرات الواجهات البرمجية بعد الترقية: `FirebaseAppCheck.activate`
   (أسماء المزوّدين تغيّرت في 0.4: `providerAndroid`/`providerApple`)،
   وأي تحذيرات deprecation في `flutter analyze`.
3. التحقق بعد البناء من خلوّ الحزمة من SafetyNet:
   `./gradlew :app:dependencies --configuration releaseRuntimeClasspath | grep -i safetynet`
   يجب ألا يعيد شيئاً.
4. اختبار كامل قبل الرفع: `flutter analyze`، `flutter test`، اختبارات قواعد
   Firestore في المحاكي، ثم على جهاز حقيقي من Play: تسجيل الدخول، نشر منتج
   بصور، طلب، تقييم، رسالة دعم (App Check مفعّل على هذه المسارات).
5. رفع الإصدار على **مرحلة الإنتاج** (لم يعد على الاختبار المغلق)، والتأكد
   أن التنبيه اختفى من لوحة بيانات الإصدارات للإصدار الجديد.

**ملاحظة:** نسخة Flutter مثبَّتة في CI على 3.47.9
(`.github/workflows/build_apk.yml`). إن تطلّبت حزم FlutterFire الجديدة
Flutter أحدث، تُرقّى Flutter ونسخة Gradle (`gradle-wrapper.properties`،
9.3.1 أو أحدث لـ Flutter 3.50) معاً في نفس التحديث.

## 2. محادثة بين الإدارة والحرفي (مُعتمَد)

**الوضع الحالي:** «تواصل مع الدعم» (`support_service.dart`) اتجاه واحد: المستخدم
يرسل رسالة، والإدارة تردّ ردّاً واحداً (`adminReply`) وتغلقها. الإدارة لا
تستطيع بدء محادثة مع حرفي، ولا يوجد تبادل رسائل متعدد.

**المطلوب:**
- محادثة حقيقية متعددة الرسائل بين الإدارة وكل حرفي (خيط واحد لكل حرفي).
- الإدارة تبدأ المحادثة من «سجلّ الحرفيين» (زر «مراسلة» في صفحة الحرفي)،
  ومن «رسائل الدعم».
- الحرفي يرى المحادثة في تبويب/شاشة «رسائل الإدارة» مع عدّاد غير المقروء،
  ويردّ منها.
- إشعار داخل التطبيق عند كل رسالة جديدة للطرفين (نفس NotificationService).
- إمكانية إرفاق صورة (اختياري، بنفس رفع R2 المستخدم للمنتجات).

**التصميم المقترح:**
- `conversations/{artisanUid}`: `artisanUid`، `artisanName`، `lastMessage`،
  `lastAt`، `unreadForAdmin`، `unreadForArtisan`.
- `conversations/{artisanUid}/messages/{id}`: `senderUid`، `senderRole`
  (admin/artisan)، `text`، `imageUrl?`، `createdAt`.
- قواعد Firestore: القراءة والكتابة للحرفي صاحب المحادثة وللإدارة فقط؛
  `senderUid == request.auth.uid` إجباري؛ لا تعديل ولا حذف للرسائل؛ الحرفي
  يصفّر `unreadForArtisan` فقط، والإدارة `unreadForAdmin` فقط. اختبارات
  محاكي لكل ذلك (طرف ثالث لا يقرأ، لا انتحال للمرسل، لا تعديل).
- فهرس: `messages` حسب `createdAt`، و`conversations` حسب `lastAt` للإدارة.

**حدود معروفة:** الإشعار داخل التطبيق فقط (لا push حين يكون التطبيق مغلقاً)
— نفس حدود بقية الإشعارات بلا Cloud Functions.

## 3. «العرض حتى حافة الشاشة» لكل المستخدمين (مُعتمَد)

**المصدر:** اقتراح Play Console (تجربة المستخدم، الإصدار 27): «ميزة العرض
حتى حافة الشاشة قد لا تكون مفعّلة لدى جميع المستخدمين».

**السبب:** Android 15 يفرضها تلقائياً (targetSdk من Flutter)، لكن الأجهزة
الأقدم لا تفعّلها إلا إن طلبها التطبيق صراحة. `MainActivity.kt` حالياً
`FlutterActivity` فارغة.

**الخطوات:**
1. في `MainActivity.onCreate` استدعاء
   `WindowCompat.setDecorFitsSystemWindows(window, false)` (FlutterActivity ليست
   ComponentActivity، فلا تُستخدم `enableEdgeToEdge()` من androidx.activity)،
   مع شريطَي حالة وتنقّل شفافين، وأيقونات تتبع المظهر الفاتح/الداكن عبر
   `SystemUiOverlayStyle` في `main.dart`.
2. مراجعة كل شاشة لها محتوى عند الحواف السفلية (شريط التنقل السفلي، أزرار
   «إتمام الشراء»، «نشر المنتج»، شاشات بلا AppBar مثل اختيار اللغة) والتأكد
   من `SafeArea` أو الحشوة السفلية — على جهاز Android 15 وجهاز أقدم.

## 4. اقتراح R8 (للتحقق فقط)

**المصدر:** اقتراح Play Console (استخدام الذاكرة، الإصدار 27): «تحسين الذاكرة
والأداء في تطبيقك من خلال تحسين الأداة R8».

**الوضع:** R8 مفعّل فعلاً (`isMinifyEnabled = true` و`isShrinkResources = true`
في `android/app/build.gradle.kts`). قبل أي تغيير: فتح تفاصيل الاقتراح في Play
Console لمعرفة ما يطلبه تحديداً (مثلاً رفع ملف mapping لفكّ تشويش تقارير
الأعطال، أو قواعد keep واسعة في `proguard-rules.pro`)، ثم تطبيق ما يلزم فقط.

**سبب مرجَّح وُجد بالفحص:** `android/app/proguard-rules.pro` فيه قواعد keep
واسعة جداً: `-keep class io.flutter.** { *; }` و`com.google.firebase.**`
و`com.google.android.gms.**` و`com.google.android.play.core.**` — تمنع R8 من
ضغط وتحسين أغلب كود Firebase وGoogle Play Services. هذه المكتبات تأتي بقواعد
R8 الخاصة بها (consumer rules)، فالقواعد الواسعة غالباً غير ضرورية. الحل:
حذفها تدريجياً مع اختبار تشغيل كامل لنسخة release على جهاز حقيقي بعد كل حذف
(تسجيل دخول، Firestore، App Check، Crashlytics، الإشعارات)، والإبقاء فقط على
ما يثبت الاختبار أنه لازم.
