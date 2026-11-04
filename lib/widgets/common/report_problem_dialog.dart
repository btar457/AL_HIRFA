import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../services/dispute_service.dart';
import '../../services/storage_service.dart';
import '../../core/settings/app_prefs.dart';

const int _kMaxEvidenceImages = 3;

/// نافذة مشتركة للإبلاغ عن مشكلة بخصوص طلب — تُستخدم من شاشات المشتري
/// والحرفي (شركة الشحن لها نموذجها المدمج ضمن update_delivery_screen.dart
/// لأنه جزء من تدفق تحديث حالة التوصيل نفسه).
Future<void> showReportProblemDialog(
  BuildContext context, {
  required String orderId,
  required String reporterUid,
  required String reportedUid,
  required String disputeType,
}) {
  return showDialog(
    context: context,
    builder: (_) => _ReportProblemDialog(orderId: orderId, reporterUid: reporterUid, reportedUid: reportedUid, disputeType: disputeType),
  );
}

class _ReportProblemDialog extends StatefulWidget {
  final String orderId;
  final String reporterUid;
  final String reportedUid;
  final String disputeType;

  const _ReportProblemDialog({
    required this.orderId,
    required this.reporterUid,
    required this.reportedUid,
    required this.disputeType,
  });

  @override
  State<_ReportProblemDialog> createState() => _ReportProblemDialogState();
}

class _ReportProblemDialogState extends State<_ReportProblemDialog> {
  final _descriptionController = TextEditingController();
  final List<XFile> _evidenceImages = [];
  bool _isSubmitting = false;

  Future<void> _pickEvidence() async {
    if (_evidenceImages.length >= _kMaxEvidenceImages) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, maxHeight: 1600, imageQuality: 80);
    if (picked != null) setState(() => _evidenceImages.add(picked));
  }

  void _removeEvidence(int index) => setState(() => _evidenceImages.removeAt(index));

  Future<void> _submit() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      final evidenceUrls = <String>[];
      for (var i = 0; i < _evidenceImages.length; i++) {
        final key = 'disputes/${widget.orderId}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        evidenceUrls.add(await StorageService.instance.uploadFile(File(_evidenceImages[i].path), key));
      }
      await DisputeService.instance.createDispute(
        orderId: widget.orderId,
        reporterUid: widget.reporterUid,
        reportedUid: widget.reportedUid,
        type: widget.disputeType,
        description: description,
        evidenceUrls: evidenceUrls,
      );
      if (!mounted) return;
      Navigator.pop(context);
      AppError.showSnackbar(context, tr('تم إرسال البلاغ، ستراجعه الإدارة قريباً', 'Report sent — the admin will review it soon'), isError: false);
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackbar(context, AppError.getFirebaseError(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppPrefs.dir,
      child: AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(tr('الإبلاغ عن مشكلة', 'Report a problem'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                style: TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: tr('اشرح المشكلة بالتفصيل', 'Describe the problem in detail'),
                  hintStyle: TextStyle(color: AppColors.subText),
                  filled: true,
                  fillColor: AppColors.background,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
                ),
              ),
              const SizedBox(height: 14),
              Text(tr('صور كدليل (اختياري، حتى $_kMaxEvidenceImages)', 'Photos as evidence (optional, up to $_kMaxEvidenceImages)'), style: TextStyle(color: AppColors.subText, fontSize: 12)),
              const SizedBox(height: 8),
              SizedBox(
                height: 64,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._evidenceImages.asMap().entries.map((entry) => Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(entry.value.path), width: 56, height: 56, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 2,
                                left: 2,
                                child: GestureDetector(
                                  onTap: () => _removeEvidence(entry.key),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                                    child: const Icon(Icons.close, color: Colors.white, size: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (_evidenceImages.length < _kMaxEvidenceImages)
                      GestureDetector(
                        onTap: _pickEvidence,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                          ),
                          child: Icon(Icons.add_a_photo_outlined, color: AppColors.gold, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: _isSubmitting ? null : () => Navigator.pop(context), child: Text(tr('إلغاء', 'Cancel'), style: TextStyle(color: AppColors.subText))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : Text(tr('إرسال البلاغ', 'Send report'), style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
