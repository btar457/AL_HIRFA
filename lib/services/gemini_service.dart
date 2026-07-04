import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gemini_audit_result.dart';

/// برومبت التدقيق المعتمد لمنصة AL-HIRFA (مطابق لـ gemini_authenticator_prompt.txt)
const String kGeminiAuditSystemPrompt = r'''
أنت خبير التدقيق التراثي والفني المعتمد لمنصة "الحرفة" (AL-HIRFA) المتخصصة في إحياء وصيانة تراث الرافدين العراقي بأيدٍ حرفية أصيلة. دورك هو العمل كبوابة ذكية لضبط الجودة ومكافحة الغش التجاري قبل نشر المنتجات في المعرض.

عندما يقوم الحرفي برفع تفاصيل منتجه الجديد (الاسم، الوصف، والمواد المستخدمة)، يجب عليك تحليل البيانات بدقة وإصدار قرار فوري بناءً على اللوائح التالية:
1. التحقق من الأصالة التراثية: التأكد من أن المنتج ينتمي إلى إحدى الفئات المعتمدة (نحاسيات، سجاد وتطريز الرافدين، النحت والخط العربي، فضيات وأعمال تراثية).
2. كشف المواد الدخيلة: رفض أي منتجات يثبت أنها مستوردة، أو مقلدة، أو مجمعة صناعياً بآلات تجارية كلياً.
3. تدقيق اكتمال البيانات: التأكد من أن الوصف الفني والمواد التكوينية دقيقة وشاملة وواضحة للمشتري.

يجب أن تكون إجابتك دائماً بصيغة JSON فقط وتتكون من الحقول التالية بالضبط:
{
  "status": "APPROVED أو REJECTED أو NEEDS_REVIEW",
  "confidence_score": رقم من 0 إلى 100 يمثل نسبة التأكد من الأصالة,
  "reason_arabic": "شرح تفصيلي ولبق واحترافي لسبب القبول أو الرفض",
  "suggested_category": "التصنيف التراثي الأنسب للمنتج"
}
''';

class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _model = 'gemini-1.5-flash';

  /// يرسل وصف المنتج إلى Gemini ويعيد قرار التدقيق المهيكل.
  static Future<GeminiAuditResult> auditProduct(String productDescription) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'لم يتم تمرير مفتاح GEMINI_API_KEY. شغّل التطبيق مع '
        '--dart-define=GEMINI_API_KEY="YOUR_GEMINI_API_KEY"',
      );
    }

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey',
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': kGeminiAuditSystemPrompt},
          ],
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': productDescription},
            ],
          },
        ],
        'generationConfig': {'response_mime_type': 'application/json'},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('فشل الاتصال بخدمة الذكاء الاصطناعي (رمز الخطأ ${response.statusCode})');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>?;
    final text = candidates != null && candidates.isNotEmpty
        ? (candidates[0]['content']?['parts']?[0]?['text'] as String?)
        : null;

    if (text == null || text.isEmpty) {
      throw Exception('لم يتم استلام رد صالح من الذكاء الاصطناعي');
    }

    return GeminiAuditResult.fromJson(jsonDecode(text) as Map<String, dynamic>);
  }
}
