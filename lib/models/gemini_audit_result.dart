/// نتيجة تدقيق الأصالة الصادرة عن محرك Gemini، مطابقة لصيغة JSON
/// الموصوفة في gemini_authenticator_prompt.txt.
class GeminiAuditResult {
  final String status;
  final int confidenceScore;
  final String reasonArabic;
  final String suggestedCategory;

  GeminiAuditResult({
    required this.status,
    required this.confidenceScore,
    required this.reasonArabic,
    required this.suggestedCategory,
  });

  factory GeminiAuditResult.fromJson(Map<String, dynamic> json) {
    return GeminiAuditResult(
      status: json['status'] as String? ?? 'NEEDS_REVIEW',
      confidenceScore: (json['confidence_score'] as num?)?.toInt() ?? 0,
      reasonArabic: json['reason_arabic'] as String? ?? '',
      suggestedCategory: json['suggested_category'] as String? ?? 'غير محدد',
    );
  }
}
