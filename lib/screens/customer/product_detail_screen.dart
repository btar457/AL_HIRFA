import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/marketplace_product.dart';
import 'artisan_public_profile_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final MarketplaceProduct product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroImage(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfo(),
                    const SizedBox(height: 16),
                    _buildArtisanCard(),
                    const SizedBox(height: 20),
                    _buildQuantitySelector(),
                    const SizedBox(height: 16),
                    _buildAddToCartButton(),
                    const SizedBox(height: 28),
                    _buildNarrative(),
                    const SizedBox(height: 24),
                    _buildAuthenticityCertificate(),
                    const SizedBox(height: 24),
                    _buildMaterialsAndOrigin(),
                    const SizedBox(height: 24),
                    _buildTechnicalDetails(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF3A2A10), Color(0xFF1A1208)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: const Center(child: Icon(Icons.auto_awesome, color: AppColors.gold, size: 72)),
          ),
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
                _circleIconButton(icon: Icons.share_outlined, onTap: () {}),
                const SizedBox(width: 8),
                _circleIconButton(
                  icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                  iconColor: _isFavorite ? AppColors.gold : Colors.white,
                  onTap: () => setState(() => _isFavorite = !_isFavorite),
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(20)),
          child: Text(widget.product.cityTag, style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        const SizedBox(height: 12),
        Text(widget.product.name, style: const TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: AppColors.gold, size: 16),
            const Icon(Icons.star, color: AppColors.gold, size: 16),
            const Icon(Icons.star, color: AppColors.gold, size: 16),
            const Icon(Icons.star, color: AppColors.gold, size: 16),
            const Icon(Icons.star_border, color: AppColors.gold, size: 16),
            const SizedBox(width: 8),
            Text('(١٢ تقييم)', style: TextStyle(color: AppColors.subText, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 12),
        Text('د.ع ${widget.product.price}', style: const TextStyle(color: AppColors.gold, fontSize: 28, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildArtisanCard() {
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
                const Text('أبو مصطفى', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                Text('صنع بيدي في بغداد', style: TextStyle(color: AppColors.subText, fontSize: 12)),
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

  Widget _buildAddToCartButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        onPressed: () {}, // TODO: إضافة فعلية للسلة عند بناء cart_screen
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

  Widget _buildNarrative() {
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
          'وُلدت هذه القطعة بين يدي حرفي عراقي أصيل توارث الصنعة عن أجداده، يشكّل المادة بصبر وأناة ليحوّلها إلى عمل فني يحمل عبق الرافدين وتفاصيل الحضارة العراقية العريقة.',
          style: TextStyle(color: AppColors.subText, fontSize: 14, height: 24 / 14),
        ),
      ],
    );
  }

  Widget _buildAuthenticityCertificate() {
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
            onPressed: () {},
            child: const Text('عرض الوثيقة', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsAndOrigin() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              const Icon(Icons.category_outlined, color: AppColors.gold),
              const SizedBox(height: 6),
              Text('الطين', style: TextStyle(color: AppColors.text, fontSize: 13)),
            ],
          ),
        ),
        Container(width: 1, height: 40, color: AppColors.gold.withOpacity(0.3)),
        Expanded(
          child: Column(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.gold),
              const SizedBox(height: 6),
              Text('حي الرشيد، بغداد', style: TextStyle(color: AppColors.text, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('تفاصيل فنية', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (context, i) => const SizedBox(width: 10),
            itemBuilder: (context, i) => Container(
              width: 70,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                gradient: LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)]),
              ),
              child: const Icon(Icons.image_outlined, color: AppColors.gold, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}
