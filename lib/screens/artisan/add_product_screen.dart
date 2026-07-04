import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/categories.dart';
import '../../core/constants/colors.dart';

const int _kMaxImages = 5;

/// إطار متقطّع (Dashed Border) لمنطقة رفع الصور.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12));
    final path = Path()..addRRect(rrect);
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => oldDelegate.color != color;
}

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _narrativeController = TextEditingController();
  final _materialController = TextEditingController();
  final _originController = TextEditingController();
  final _experienceController = TextEditingController();
  final _techniqueController = TextEditingController();

  String _selectedCategory = kCategories.first;
  String _selectedCity = kCities.first;
  final List<XFile> _images = [];

  Future<void> _pickImage() async {
    if (_images.length >= _kMaxImages) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _images.add(picked));
  }

  void _removeImage(int index) => setState(() => _images.removeAt(index));

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.subText, fontSize: 13),
      filled: true,
      fillColor: AppColors.card,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildLabeledField({required String label, required Widget field}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  void _publish() {
    if (!_formKey.currentState!.validate()) return;
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('تم إرسال المنتج للمراجعة', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text('سيظهر المنتج في قائمتك بحالة "معلق" حتى تتم مراجعته.', style: TextStyle(color: AppColors.subText)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('حسناً', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.gold),
          title: const Text('إضافة منتج جديد', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagesSection(),
                const SizedBox(height: 24),
                _buildLabeledField(
                  label: 'اسم المنتج',
                  field: TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.text),
                    decoration: _fieldDecoration(),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'اسم المنتج مطلوب' : null,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabeledField(
                  label: 'الفئة',
                  field: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    dropdownColor: AppColors.card,
                    style: const TextStyle(color: AppColors.text),
                    decoration: _fieldDecoration(),
                    items: kCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value!),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabeledField(
                  label: 'السعر بالدينار العراقي',
                  field: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.text),
                    decoration: _fieldDecoration(),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'السعر مطلوب' : null,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabeledField(
                  label: 'المدينة',
                  field: DropdownButtonFormField<String>(
                    initialValue: _selectedCity,
                    dropdownColor: AppColors.card,
                    style: const TextStyle(color: AppColors.text),
                    decoration: _fieldDecoration(),
                    items: kCities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (value) => setState(() => _selectedCity = value!),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabeledField(
                  label: 'وصف المنتج',
                  field: TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: const TextStyle(color: AppColors.text),
                    decoration: _fieldDecoration(),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'وصف المنتج مطلوب' : null,
                  ),
                ),
                const SizedBox(height: 24),
                _buildNarrativeSection(),
                const SizedBox(height: 24),
                _buildAuthenticitySection(),
                const SizedBox(height: 28),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: _publish,
                    child: const Text('نشر المنتج', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CustomPaint(
            painter: _DashedBorderPainter(color: AppColors.gold),
            child: Container(
              height: 200,
              width: double.infinity,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_outlined, color: AppColors.gold, size: 48),
                  const SizedBox(height: 12),
                  Text('أضف حتى 5 صور للمنتج', style: TextStyle(color: AppColors.subText, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
        if (_images.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              separatorBuilder: (context, i) => const SizedBox(width: 8),
              itemBuilder: (context, i) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(_images[i].path), width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 2,
                    left: 2,
                    child: GestureDetector(
                      onTap: () => _removeImage(i),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNarrativeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('THE NARRATIVE — حكاية القطعة', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _narrativeController,
            maxLines: 6,
            style: const TextStyle(color: AppColors.text),
            decoration: _fieldDecoration(hint: 'اروِ قصة هذه القطعة، من أين جاءت المادة، كم استغرق صنعها...'),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticitySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('شهادة الأصالة', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 14),
          _buildLabeledField(label: 'المادة الخام', field: TextFormField(controller: _materialController, style: const TextStyle(color: AppColors.text), decoration: _fieldDecoration())),
          const SizedBox(height: 14),
          _buildLabeledField(label: 'مكان المنشأ', field: TextFormField(controller: _originController, style: const TextStyle(color: AppColors.text), decoration: _fieldDecoration())),
          const SizedBox(height: 14),
          _buildLabeledField(label: 'سنوات الخبرة', field: TextFormField(controller: _experienceController, keyboardType: TextInputType.number, style: const TextStyle(color: AppColors.text), decoration: _fieldDecoration())),
          const SizedBox(height: 14),
          _buildLabeledField(label: 'تقنية الصنع', field: TextFormField(controller: _techniqueController, style: const TextStyle(color: AppColors.text), decoration: _fieldDecoration())),
        ],
      ),
    );
  }
}
