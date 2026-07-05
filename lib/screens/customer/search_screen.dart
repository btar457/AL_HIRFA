import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/categories.dart';
import '../../models/categories.dart';
import '../../models/marketplace_product.dart';
import '../../models/product_model.dart';
import '../../widgets/common/marketplace_product_card.dart';
import 'product_detail_screen.dart';

/// شاشة البحث والفلاتر (CUSTOMER-12).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final Set<String> _favoriteNames = {};

  String? _selectedCategoryId;
  RangeValues _priceRange = const RangeValues(0, 10000000);
  String? _selectedCity;
  double? _minRating;
  String _query = '';

  static const _products = [
    MarketplaceProduct(name: 'سجادة حرير نجفية مطرزة يدوياً', price: '450,000', city: 'النجف', cityTag: 'NAJAF SILK'),
    MarketplaceProduct(name: 'إبريق نحاسي بصري منقوش', price: '210,000', city: 'البصرة', cityTag: 'BASRA COPPER'),
    MarketplaceProduct(name: 'طقم نحاسيات بغدادية مذهبة', price: '380,000', city: 'بغداد', cityTag: 'BAGHDAD BRASS'),
    MarketplaceProduct(name: 'نسيج صوفي أربيلي تقليدي', price: '165,000', city: 'أربيل', cityTag: 'ERBIL WEAVE'),
    MarketplaceProduct(name: 'منحوتة حجرية موصلية', price: '295,000', city: 'الموصل', cityTag: 'MOSUL STONE'),
    MarketplaceProduct(name: 'إكسسوار ذهبي كربلائي', price: '520,000', city: 'كربلاء', cityTag: 'KARBALA GOLD'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<MarketplaceProduct> get _filtered {
    return _products.where((p) {
      if (_query.isNotEmpty && !p.name.contains(_query)) return false;
      if (_selectedCity != null && p.city != _selectedCity) return false;
      final price = int.parse(p.price.replaceAll(',', ''));
      if (price < _priceRange.start || price > _priceRange.end) return false;
      return true;
    }).toList();
  }

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الفئة', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...kAppCategories.map((cat) => CheckboxListTile(
                      value: _selectedCategoryId == cat.id,
                      activeColor: AppColors.gold,
                      title: Text(cat.nameAr, style: const TextStyle(color: AppColors.text)),
                      secondary: Text(cat.icon, style: const TextStyle(fontSize: 20)),
                      onChanged: (val) {
                        setSheetState(() {});
                        setState(() => _selectedCategoryId = (val ?? false) ? cat.id : null);
                      },
                    )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPriceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('السعر', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${_priceRange.start.toInt()} - ${_priceRange.end.toInt()} د.ع', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 10000000,
                      divisions: 20,
                      activeColor: AppColors.gold,
                      inactiveColor: AppColors.gold.withOpacity(0.2),
                      onChanged: (values) => setSheetState(() => setState(() => _priceRange = values)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCitySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('المدينة', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16)),
                    ...kCities.map((city) => RadioListTile<String>(
                      value: city,
                      groupValue: _selectedCity,
                      activeColor: AppColors.gold,
                      title: Text(city, style: const TextStyle(color: AppColors.text)),
                      onChanged: (val) {
                        setSheetState(() {});
                        setState(() => _selectedCity = val);
                      },
                    )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRatingSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('التقييم', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16)),
                    ...[4.5, 4.0, 3.5, 3.0].map((r) => RadioListTile<double>(
                      value: r,
                      groupValue: _minRating,
                      activeColor: AppColors.gold,
                      title: Text('$r فأعلى ⭐', style: const TextStyle(color: AppColors.text)),
                      onChanged: (val) {
                        setSheetState(() {});
                        setState(() => _minRating = val);
                      },
                    )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(String label, VoidCallback onTap, {bool active = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.gold.withOpacity(active ? 1 : 0.4)),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: onTap,
          child: Text(label, style: TextStyle(color: active ? AppColors.gold : AppColors.text, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.gold.withOpacity(0.5))),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: AppColors.gold, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                style: const TextStyle(color: AppColors.text, fontSize: 13),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'ابحث عن التحف والأعمال اليدوية...',
                                  hintStyle: TextStyle(color: AppColors.subText, fontSize: 13),
                                ),
                                onChanged: (value) => setState(() => _query = value),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _buildFilterButton('الفئة', _showCategorySheet, active: _selectedCategoryId != null),
                    _buildFilterButton('السعر', _showPriceSheet, active: _priceRange.start > 0 || _priceRange.end < 10000000),
                    _buildFilterButton('المدينة', _showCitySheet, active: _selectedCity != null),
                    _buildFilterButton('التقييم', _showRatingSheet, active: _minRating != null),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('${results.length} نتيجة', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                ),
              ),
              Expanded(
                child: results.isEmpty ? _buildEmptyState() : _buildResultsGrid(results),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, color: AppColors.subText.withOpacity(0.5), size: 64),
          const SizedBox(height: 16),
          Text("لا توجد نتائج لـ '$_query'", style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('جرّب كلمات مختلفة', style: TextStyle(color: AppColors.subText, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildResultsGrid(List<MarketplaceProduct> results) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.66),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final product = results[i];
        return MarketplaceProductCard(
          product: product,
          isFavorite: _favoriteNames.contains(product.name),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: ProductModel.fromMarketplaceProduct(product)))),
          onFavoriteToggle: () => setState(() {
            if (_favoriteNames.contains(product.name)) {
              _favoriteNames.remove(product.name);
            } else {
              _favoriteNames.add(product.name);
            }
          }),
        );
      },
    );
  }
}
