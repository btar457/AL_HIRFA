import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/categories.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../models/categories.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';

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

/// نموذج مشترك لإضافة/تعديل منتج الحرفي (يُستخدم من AddProductScreen وEditProductScreen).
class ProductForm extends StatefulWidget {
  final ProductModel? initialProduct;
  final String title;
  final String submitLabel;
  final String successTitle;
  final String successMessage;

  const ProductForm({
    super.key,
    this.initialProduct,
    required this.title,
    required this.submitLabel,
    required this.successTitle,
    required this.successMessage,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.initialProduct?.name ?? '');
  late final _priceController = TextEditingController(text: widget.initialProduct != null ? widget.initialProduct!.price.toString() : '');
  late final _descriptionController = TextEditingController(text: widget.initialProduct?.description ?? '');
  late final _narrativeController = TextEditingController(text: widget.initialProduct?.narrative ?? '');
  late final _materialController = TextEditingController(text: widget.initialProduct?.material ?? '');
  late final _originController = TextEditingController(text: widget.initialProduct?.originPlace ?? '');
  final _experienceController = TextEditingController();
  late final _techniqueController = TextEditingController(text: widget.initialProduct?.technique ?? '');

  static final List<AppCategory> _selectableCategories = kAppCategories.where((c) => c.id != 'all').toList();

  late AppCategory _selectedCategory = _selectableCategories.firstWhere(
    (c) => c.id == widget.initialProduct?.category,
    orElse: () => _selectableCategories.first,
  );
  late String _selectedCity = widget.initialProduct?.city ?? kCities.first;
  final List<XFile> _images = [];
  late final List<String> _existingImageUrls = List.of(widget.initialProduct?.images ?? const []);
  bool _isSubmitting = false;

  int get _totalImageCount => _images.length + _existingImageUrls.length;

  Future<void> _pickImage() async {
    if (_totalImageCount >= _kMaxImages) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _images.add(picked));
  }

  void _removeImage(int index) => setState(() => _images.removeAt(index));

  void _removeExistingImage(int index) => setState(() => _existingImageUrls.removeAt(index));

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final isAdd = widget.initialProduct == null;
    if (_totalImageCount == 0) {
      AppError.showSnackbar(context, 'أضف صورة واحدة على الأقل للمنتج');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (isAdd) {
        final artisan = context.read<AuthProvider>().currentUser;
        if (artisan == null) {
          AppError.showSnackbar(context, 'يجب تسجيل الدخول لنشر منتج');
          return;
        }
        final product = ProductModel(
          id: '',
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: int.tryParse(_priceController.text.replaceAll(',', '').trim()) ?? 0,
          category: _selectedCategory.id,
          city: _selectedCity,
          images: const [],
          artisanUid: artisan.uid,
          artisanName: artisan.name,
          artisanPhotoUrl: artisan.photoUrl,
          narrative: _narrativeController.text.trim(),
          material: _materialController.text.trim(),
          originPlace: _originController.text.trim(),
          technique: _techniqueController.text.trim(),
          status: 'pending',
          createdAt: DateTime.now(),
        );
        await ProductService.instance.addProduct(product, _images);
      } else {
        final product = widget.initialProduct!;
        final newImageUrls = _images.isEmpty ? const <String>[] : await ProductService.instance.uploadImages(product.artisanUid, product.id, _images);
        await ProductService.instance.updateProduct(product.id, {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': int.tryParse(_priceController.text.replaceAll(',', '').trim()) ?? 0,
          'category': _selectedCategory.id,
          'city': _selectedCity,
          'narrative': _narrativeController.text.trim(),
          'material': _materialController.text.trim(),
          'originPlace': _originController.text.trim(),
          'technique': _techniqueController.text.trim(),
          'images': [..._existingImageUrls, ...newImageUrls],
        });
      }
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackbar(context, AppError.getFirebaseError(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(widget.successTitle, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text(widget.successMessage, style: TextStyle(color: AppColors.subText)),
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
          title: Text(widget.title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
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
                  field: DropdownButtonFormField<AppCategory>(
                    initialValue: _selectedCategory,
                    dropdownColor: AppColors.card,
                    style: const TextStyle(color: AppColors.text),
                    decoration: _fieldDecoration(),
                    items: _selectableCategories.map((c) => DropdownMenuItem(value: c, child: Text(c.nameAr))).toList(),
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
                    validator: (v) {
                      final trimmed = v?.trim() ?? '';
                      if (trimmed.isEmpty) return 'السعر مطلوب';
                      final parsed = int.tryParse(trimmed.replaceAll(',', ''));
                      if (parsed == null || parsed <= 0) return 'أدخل سعراً صحيحاً أكبر من صفر';
                      return null;
                    },
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
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, disabledBackgroundColor: AppColors.gold.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : Text(widget.submitLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
        if (_totalImageCount > 0) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _totalImageCount,
              separatorBuilder: (context, i) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final isExisting = i < _existingImageUrls.length;
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: isExisting
                          ? CachedNetworkImage(imageUrl: _existingImageUrls[i], width: 80, height: 80, fit: BoxFit.cover)
                          : Image.file(File(_images[i - _existingImageUrls.length].path), width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 2,
                      left: 2,
                      child: GestureDetector(
                        onTap: () => isExisting ? _removeExistingImage(i) : _removeImage(i - _existingImageUrls.length),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              },
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
