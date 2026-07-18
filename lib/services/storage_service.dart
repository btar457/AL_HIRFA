import 'dart:io';
import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';

/// طبقة رفع الملفات إلى Cloudflare R2 (متوافق مع S3) — بديل Firebase Storage
/// الذي تعذّر تفعيله (يتطلب خطة Blaze المدفوعة، غير المتاحة كخيار فوترة في
/// العراق حالياً). لا يوجد خادم خلفي في هذا المشروع، لذا الرفع يتم مباشرة
/// من التطبيق موقّعاً بـ AWS Signature V4.
///
/// ملاحظة أمنية مهمة: مفتاح R2 هنا مُقيَّد (Object Read & Write) على bucket
/// واحد فقط عبر إعداد صريح في Cloudflare API Token — أي شخص يستخرج هذا
/// المفتاح من الـ APK يمكنه الكتابة/القراءة في هذا الـ bucket فقط، وليس أي
/// شيء آخر في الحساب. هذا تخفيف حقيقي للمخاطرة لكنه ليس بصلابة Firestore/
/// Storage rules الحقيقية التي تتحقق من هوية Firebase Auth لكل طلب.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  // القيم الثلاث الحسّاسة تُحقَن فقط في وقت البناء عبر --dart-define من
  // أسرار CI (build_apk.yml) — لا تُكتب هنا مباشرة أبداً، لأن هذا المستودع
  // عام (public) وأي قيمة هنا ستكون مقروءة لأي زائر فور الدفع (Push).
  static const _accountId = String.fromEnvironment('R2_ACCOUNT_ID');
  static const _accessKeyId = String.fromEnvironment('R2_ACCESS_KEY_ID');
  static const _secretAccessKey = String.fromEnvironment('R2_SECRET_ACCESS_KEY');
  static const _bucket = 'al-hirfa';
  // الرابط العام لقراءة الملفات بعد رفعها (Public Development URL — r2.dev)
  // ليس سرّاً — يُقرأ من الإعدادات العامة مباشرة، آمن تضمينه في الكود.
  static const _publicBaseUrl = 'https://pub-061b5d191b044be1a41d2403f5537476.r2.dev';

  static const _credentialScope = AWSCredentialScope(region: 'auto', service: AWSService.s3);

  final AWSSigV4Signer _signer = const AWSSigV4Signer(
    credentialsProvider: AWSCredentialsProvider(
      AWSCredentials(accessKeyId: _accessKeyId, secretAccessKey: _secretAccessKey),
    ),
  );

  /// يرفع ملفاً إلى المسار (key) المحدَّد داخل الـ bucket، ويُعيد الرابط
  /// العام الدائم للوصول إليه.
  Future<String> uploadFile(File file, String key, {String contentType = 'image/jpeg'}) async {
    final bytes = await file.readAsBytes();
    final request = AWSHttpRequest(
      method: AWSHttpMethod.put,
      uri: Uri.https('$_accountId.r2.cloudflarestorage.com', '/$_bucket/$key'),
      headers: {AWSHeaders.contentType: contentType},
      body: bytes,
    );
    final signedRequest = await _signer.sign(request, credentialScope: _credentialScope);
    final response = await signedRequest.send();
    if (response.statusCode != 200) {
      throw Exception('فشل رفع الملف إلى التخزين (${response.statusCode})');
    }
    return '$_publicBaseUrl/$key';
  }
}
