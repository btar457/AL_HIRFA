import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/product.dart';
import '../../models/product_category.dart';
import '../../widgets/common/product_card.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});
  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final _search = TextEditingController();
  int _selectedCat = -1;

  final _categories = const [
    ProductCategory(name: 'سجادات', icon: '🪆', color: 0xFF8B3A1A),
    ProductCategory(name: 'منحوتات', icon: '🗿', color: 0xFF5A4A2A),
    ProductCategory(name: 'محابس', icon: '💍', color: 0xFF2A4A5A),
    ProductCategory(name: 'ملابس', icon: '👘', color: 0xFF1A4A3A),
    ProductCategory(name: 'عطور', icon: '🫙', color: 0xFF3A2A5A),
    ProductCategory(name: 'مسابح', icon: '📿', color: 0xFF4A3A1A),
    ProductCategory(name: 'أعمال يدوية', icon: '🖐', color: 0xFF3A1A1A),
    ProductCategory(name: 'مزهريات', icon: '🏺', color: 0xFF1A3A4A),
    ProductCategory(name: 'نقوش النحاس', icon: '🔶', color: 0xFF4A2A1A),
  ];

  final _products = const [
    Product(name: 'إناء نحاسي منقوش', artisan: 'أبو مصطفى', price: '125,000', category: 'نقوش النحاس'),
    Product(name: 'سجادة بابلية صوفية', artisan: 'حرفيو ذي قار', price: '450,000', category: 'سجادات'),
    Product(name: 'لوحة خط عربي ذهبي', artisan: 'الخطاط الموصلي', price: '320,000', category: 'أعمال يدوية'),
    Product(name: 'محبس فضة عقيق', artisan: 'جواهري النجف', price: '85,000', category: 'محابس'),
    Product(name: 'مزهرية رافدينية', artisan: 'فخار بابل', price: '200,000', category: 'مزهريات'),
    Product(name: 'عطر الفرات', artisan: 'بيت العطور', price: '75,000', category: 'عطور'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCat == -1 ? _products : _products.where((p) => p.category == _categories[_selectedCat].name).toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            pinned: true,
            title: const Text('AL-HIRFA', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, letterSpacing: 3)),
            centerTitle: true,
            leading: const Icon(Icons.account_circle_outlined, color: AppColors.gold),
            actions: [IconButton(icon: const Icon(Icons.menu, color: AppColors.gold), onPressed: () {})],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.gold.withOpacity(0.2))),
                  child: Row(children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: AppColors.gold, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(
                      controller: _search,
                      style: const TextStyle(color: AppColors.text, fontSize: 14),
                      decoration: InputDecoration(border: InputBorder.none, hintText: 'ابحث عن الحرفة أو الفنان...', hintStyle: TextStyle(color: AppColors.subText, fontSize: 13)),
                    )),
                  ]),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.lock_outline, color: AppColors.gold, size: 12),
              const SizedBox(width: 4),
              Text('جلسة مشفرة بقوة 256 بت', style: TextStyle(color: AppColors.gold.withOpacity(0.7), fontSize: 11)),
            ]),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: const Text('التصنيفات', style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold)),
          )),
          SliverToBoxAdapter(child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.6),
            itemCount: _categories.length,
            itemBuilder: (context, i) {
              final cat = _categories[i];
              final selected = _selectedCat == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedCat = selected ? -1 : i),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(cat.color),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? AppColors.gold : Colors.transparent, width: 2),
                  ),
                  child: Stack(children: [
                    Positioned(top: 8, right: 12, child: Text(cat.icon, style: const TextStyle(fontSize: 28))),
                    Positioned(bottom: 8, right: 12, child: Text(cat.name, style: const TextStyle(color: AppColors.gold, fontSize: 15, fontWeight: FontWeight.bold))),
                  ]),
                ),
              );
            },
          )),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.75),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  if (i >= filtered.length) return null;
                  final p = filtered[i];
                  return ProductCard(name: p.name, artisan: p.artisan, price: p.price);
                },
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
