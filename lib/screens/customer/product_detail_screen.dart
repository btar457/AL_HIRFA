import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/colors.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_service.dart';
import '../../services/qr_service.dart';
import 'artisan_public_profile_screen.dart';

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final userId = context.watch<AuthProvider>().currentUser?.uid;
    final canPersistFavorite = product.id.isNotEmpty && userId != null;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              canPersistFavorite
                  ? StreamBuilder<Set<String>>(
                      stream: ProductService.instance.getFavoriteIds(userId),
                      builder: (context, snapshot) => _buildHeroImage(product, isFavorite: snapshot.data?.contains(product.id) ?? false, onFavoriteToggle: () => ProductService.instance.toggleFavorite(product.id, userId)),
                    )
                  : _buildHeroImage(product, isFavorite: _isFavorite, onFavoriteToggle: () => setState(() => _isFavorite = !_isFavorite)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfo(product),
                    const SizedBox(height: 16),
                    _buildArtisanCard(product),
                    const SizedBox(height: 20),
                    _buildQuantitySelector(),
                    const SizedBox(height: 16),
                    _buildAddToCartButton(product),
                    const SizedBox(height: 28),
                    _buildNarrative(product),
                    const SizedBox(height: 24),
                    _buildAuthenticityCertificate(product),
                    const SizedBox(height: 24),
                    _buildMaterialsAndOrigin(product),
                    if (product.images.length > 1) ...[
                      const SizedBox(height: 24),
                      _buildImageGallery(product),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage(ProductModel product, {required bool isFavorite, required VoidCallback onFavoriteToggle}) {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (product.images.isNotEmpty)
            CachedNetworkImage(
              imageUrl: product.images.first,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF3A2A10), Color(0xFF1A1208)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              ),
              errorWidget: (context, url, error) => _heroPlaceholder(),
            )
          else
            _heroPlaceholder(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.8)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: _circleIconButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                _circleIconButton(icon: Icons.share_outlined, onTap: () => Share.share('${product.name} — د.ع ${_formatPrice(product.price)}\nمن صنع ${product.artisanName} على AL-HIRFA')),
                const SizedBox(width: 8),
                _circleIconButton(
                  icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                  iconColor: isFavorite ? AppColors.gold : Colors.white,
                  onTap: onFavoriteToggle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF3A2A10), Color(0xFF1A1208)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: const Center(child: Icon(Icons.auto_awesome, color: AppColors.gold, size: 72)),
    );
  }

  Widget _circleIconButton({required IconData icon, required VoidCallback onTap, Color iconColor = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildInfo(ProductModel product) {
    final filledStars = product.rating.round().clamp(0, 5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(20)),
          child: Text(product.city.toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        const SizedBox(height: 12),
        Text(product.name, style: const TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            ...List.generate(5, (i) => Icon(i < filledStars ? Icons.star : Icons.star_border, color: AppColors.gold, size: 16)),
            const SizedBox(width: 8),
            Text(product.reviewCount > 0 ? '(${product.reviewCount} تقييم)' : 'لا توجد تقييمات بعد', style: TextStyle(color: AppColors.subText, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 12),
        Text('د.ع ${_formatPrice(product.price)}', style: const TextStyle(color: AppColors.gold, fontSize: 28, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildArtisanCard(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.background, border: Border.all(color: AppColors.gold.withOpacity(0.4))),
            child: const Icon(Icons.person, color: AppColors.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.artisanName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                Text('صنع بيدي في ${product.city}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtisanPublicProfileScreen())),
            child: const Text('زيارة الملف', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _quantityButton(icon: Icons.remove, onTap: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1)),
        SizedBox(width: 48, child: Text('$_quantity', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18))),
        _quantityButton(icon: Icons.add, onTap: () => setState(() => _quantity++)),
      ],
    );
  }

  Widget _quantityButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.gold)),
        child: Icon(icon, color: AppColors.gold, size: 18),
      ),
    );
  }

  Widget _buildAddToCartButton(ProductModel product) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        onPressed: () {
          final cart = context.read<CartProvider>();
          for (var i = 0; i < _quantity; i++) {
            cart.addItem(product);
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('أُضيف "${product.name}" إلى السلة')));
          setState(() => _quantity = 1);
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, color: Colors.black),
            SizedBox(width: 8),
            Text('أضف إلى السلة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrative(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('THE NARRATIVE', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 3)),
        const SizedBox(height: 6),
        const Text('حكاية القطعة', style: TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Divider(color: AppColors.gold.withOpacity(0.3)),
        const SizedBox(height: 12),
        Text(
          product.narrative.isNotEmpty
              ? product.narrative
              : 'وُلدت هذه القطعة بين يدي حرفي عراقي أصيل توارث الصنعة عن أجداده، يشكّل المادة بصبر وأناة ليحوّلها إلى عمل فني يحمل عبق الرافدين وتفاصيل الحضارة العراقية العريقة.',
          style: TextStyle(color: AppColors.subText, fontSize: 14, height: 24 / 14),
        ),
      ],
    );
  }

  void _showAuthenticityDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('شهادة موثوقية', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: QrImageView(data: QrService.instance.buildCertificatePayload(product), version: QrVersions.auto, size: 200),
              ),
              const SizedBox(height: 14),
              Text(product.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
              Text('صنع يد الحرفي: ${product.artisanName}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إغلاق', style: TextStyle(color: AppColors.gold))),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticityCertificate(ProductModel product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Column(
        children: [
          const Icon(Icons.qr_code_2, color: AppColors.gold, size: 64),
          const SizedBox(height: 12),
          const Text('شهادة موثوقية', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text('امسح رمز QR للتحقق من الأصالة', textAlign: TextAlign.center, style: TextStyle(color: AppColors.subText, fontSize: 12)),
          const SizedBox(height: 14),
          OutlinedButton(
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () => _showAuthenticityDialog(product),
            child: const Text('عرض الوثيقة', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsAndOrigin(ProductModel product) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              const Icon(Icons.category_outlined, color: AppColors.gold),
              const SizedBox(height: 6),
              Text(product.material.isNotEmpty ? product.material : 'غير محدد', style: TextStyle(color: AppColors.text, fontSize: 13), textAlign: TextAlign.center),
            ],
          ),
        ),
        Container(width: 1, height: 40, color: AppColors.gold.withOpacity(0.3)),
        Expanded(
          child: Column(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.gold),
              const SizedBox(height: 6),
              Text(product.originPlace.isNotEmpty ? product.originPlace : product.city, style: TextStyle(color: AppColors.text, fontSize: 13), textAlign: TextAlign.center),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery(ProductModel product) {
    final extraImages = product.images.skip(1).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('صور إضافية', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: extraImages.length,
            separatorBuilder: (context, i) => const SizedBox(width: 10),
            itemBuilder: (context, i) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: extraImages[i],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(width: 70, height: 70, color: AppColors.card),
                errorWidget: (context, url, error) => Container(width: 70, height: 70, color: AppColors.card, child: const Icon(Icons.broken_image_outlined, color: AppColors.subText)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
