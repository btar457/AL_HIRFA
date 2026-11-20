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
