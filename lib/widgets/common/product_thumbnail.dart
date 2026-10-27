import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

const _kThumbnailGradient = LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)]);

/// صورة مصغّرة موحّدة لمنتج/طلب — تعرض الصورة الحقيقية عند توفرها، وتسقط
/// لأيقونة افتراضية (نفس التصميم المستخدم سابقاً في كل شاشة) أثناء التحميل
/// أو عند غياب/فشل الصورة.
class ProductThumbnail extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double borderRadius;
  final double iconSize;

  const ProductThumbnail({
    super.key,
    required this.imageUrl,
    required this.size,
    this.borderRadius = 8,
    this.iconSize = 24,
  });

  Widget _fallback() {
    return Container(
      decoration: const BoxDecoration(gradient: _kThumbnailGradient),
      alignment: Alignment.center,
      child: Icon(Icons.auto_awesome, color: AppColors.gold, size: iconSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl.isEmpty
            ? _fallback()
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _fallback(),
                errorWidget: (context, url, error) => _fallback(),
              ),
      ),
    );
  }
}
