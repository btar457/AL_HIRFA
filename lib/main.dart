import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kBg        = Color(0xFF0D0D0D);
const kCard      = Color(0xFF1A1A1A);
const kGold      = Color(0xFFD4AF37);
const kGoldLight = Color(0xFFF0D060);
const kText      = Colors.white;
const kSubText   = Color(0xFFAAAAAA);

void main() => runApp(const AlHirfaApp());

class AlHirfaApp extends StatelessWidget {
  const AlHirfaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AL-HIRFA | الحرفة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kGold, surface: kBg),
        fontFamily: GoogleFonts.cairo().fontFamily,
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('AL-HIRFA', style: TextStyle(color: kGold, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 6)),
            const SizedBox(height: 8),
            const Text('الـحـرفـة', style: TextStyle(color: kGold, fontSize: 22, letterSpacing: 4)),
            const SizedBox(height: 6),
            Text('تراث الرافدين بأيدٍ حرفية', style: TextStyle(color: kSubText, fontSize: 13)),
            const SizedBox(height: 48),
            const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: kGold, strokeWidth: 1.5)),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('AL-HIRFA', style: TextStyle(color: kGold, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 4)),
                const SizedBox(height: 8),
                Text('اختر نوع حسابك للبدء', style: TextStyle(color: kSubText, fontSize: 15)),
                const SizedBox(height: 48),
                _RoleCard(icon: Icons.shopping_bag_outlined, title: 'مشتري', subtitle: 'اقتنِ قطعاً فريدة', onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNav()))),
                const SizedBox(height: 16),
                _RoleCard(icon: Icons.gavel_outlined, title: 'حرفي', subtitle: 'اعرض إبداعاتك', onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNav(initialIndex: 3)))),
                const SizedBox(height: 16),
                _RoleCard(icon: Icons.local_shipping_outlined, title: 'شركة شحن', subtitle: 'انضم كشريك لوجستي', onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNav()))),
                const SizedBox(height: 16),
                _RoleCard(icon: Icons.admin_panel_settings_outlined, title: 'إدارة', subtitle: 'بوابة المؤسس', onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNav(initialIndex: 4)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kGold.withOpacity(0.3)),
        ),
        child: Row(children: [
          Icon(icon, color: kGold, size: 28),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(subtitle, style: TextStyle(color: kSubText, fontSize: 13)),
          ]),
          const Spacer(),
          const Icon(Icons.arrow_back_ios, color: kGold, size: 16),
        ]),
      ),
    );
  }
}

class MainNav extends StatefulWidget {
  final int initialIndex;
  const MainNav({super.key, this.initialIndex = 0});
  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  late int _index;
  @override
  void initState() { super.initState(); _index = widget.initialIndex; }

  final _screens = const [
    MarketScreen(),
    OrdersScreen(),
    StudioScreen(),
    ArtisanScreen(),
    FounderScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          border: Border(top: BorderSide(color: kGold.withOpacity(0.25), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: kGold,
          unselectedItemColor: Colors.white30,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'السوق'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'طلباتي'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), activeIcon: Icon(Icons.auto_awesome), label: 'الاستوديو'),
            BottomNavigationBarItem(icon: Icon(Icons.gavel_outlined), activeIcon: Icon(Icons.gavel), label: 'الحرفي'),
            BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), activeIcon: Icon(Icons.admin_panel_settings), label: 'الإدارة'),
          ],
        ),
      ),
    );
  }
}

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});
  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final _search = TextEditingController();
  int _selectedCat = -1;

  final _categories = [
    {'name': 'سجادات',       'icon': '🪆', 'color': 0xFF8B3A1A},
    {'name': 'منحوتات',      'icon': '🗿', 'color': 0xFF5A4A2A},
    {'name': 'محابس',        'icon': '💍', 'color': 0xFF2A4A5A},
    {'name': 'ملابس',        'icon': '👘', 'color': 0xFF1A4A3A},
    {'name': 'عطور',         'icon': '🫙', 'color': 0xFF3A2A5A},
    {'name': 'مسابح',        'icon': '📿', 'color': 0xFF4A3A1A},
    {'name': 'أعمال يدوية',  'icon': '🖐', 'color': 0xFF3A1A1A},
    {'name': 'مزهريات',      'icon': '🏺', 'color': 0xFF1A3A4A},
    {'name': 'نقوش النحاس',  'icon': '🔶', 'color': 0xFF4A2A1A},
  ];

  final _products = [
    {'name': 'إناء نحاسي منقوش',   'artisan': 'أبو مصطفى',       'price': '125,000', 'cat': 'نقوش النحاس'},
    {'name': 'سجادة بابلية صوفية', 'artisan': 'حرفيو ذي قار',    'price': '450,000', 'cat': 'سجادات'},
    {'name': 'لوحة خط عربي ذهبي',  'artisan': 'الخطاط الموصلي', 'price': '320,000', 'cat': 'أعمال يدوية'},
    {'name': 'محبس فضة عقيق',      'artisan': 'جواهري النجف',    'price': '85,000',  'cat': 'محابس'},
    {'name': 'مزهرية رافدينية',     'artisan': 'فخار بابل',       'price': '200,000', 'cat': 'مزهريات'},
    {'name': 'عطر الفرات',          'artisan': 'بيت العطور',      'price': '75,000',  'cat': 'عطور'},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCat == -1 ? _products : _products.where((p) => p['cat'] == _categories[_selectedCat]['name']).toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: kBg,
            pinned: true,
            title: const Text('AL-HIRFA', style: TextStyle(color: kGold, fontWeight: FontWeight.bold, letterSpacing: 3)),
            centerTitle: true,
            leading: const Icon(Icons.account_circle_outlined, color: kGold),
            actions: [IconButton(icon: const Icon(Icons.menu, color: kGold), onPressed: () {})],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: kGold.withOpacity(0.2))),
                  child: Row(children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: kGold, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(
                      controller: _search,
                      style: const TextStyle(color: kText, fontSize: 14),
                      decoration: InputDecoration(border: InputBorder.none, hintText: 'ابحث عن الحرفة أو الفنان...', hintStyle: TextStyle(color: kSubText, fontSize: 13)),
                    )),
                  ]),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.lock_outline, color: kGold, size: 12),
              const SizedBox(width: 4),
              Text('جلسة مشفرة بقوة 256 بت', style: TextStyle(color: kGold.withOpacity(0.7), fontSize: 11)),
            ]),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: const Text('التصنيفات', style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.bold)),
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
                    color: Color(cat['color'] as int),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? kGold : Colors.transparent, width: 2),
                  ),
                  child: Stack(children: [
                    Positioned(top: 8, right: 12, child: Text(cat['icon'] as String, style: const TextStyle(fontSize: 28))),
                    Positioned(bottom: 8, right: 12, child: Text(cat['name'] as String, style: const TextStyle(color: kGold, fontSize: 15, fontWeight: FontWeight.bold))),
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
                  return _ProductCard(name: p['name']!, artisan: p['artisan']!, price: p['price']!);
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

class _ProductCard extends StatelessWidget {
  final String name, artisan, price;
  const _ProductCard({required this.name, required this.artisan, required this.price});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: kGold.withOpacity(0.15))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            gradient: const LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: const Center(child: Icon(Icons.auto_awesome, color: kGold, size: 40)),
        )),
        Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(color: kText, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(artisan, style: TextStyle(color: kSubText, fontSize: 11)),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$price د.ع', style: const TextStyle(color: kGold, fontSize: 12, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إضافة $name للسلة'), backgroundColor: kGold.withOpacity(0.8))),
              child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.add, color: Colors.black, size: 16)),
            ),
          ]),
        ])),
      ]),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final orders = [
      {'id': 'ORD-001', 'name': 'إناء نحاسي منقوش',  'status': 'جاري التوصيل', 'price': '125,000', 'color': Colors.amber},
      {'id': 'ORD-002', 'name': 'سجادة بابلية',       'status': 'تم التسليم',   'price': '450,000', 'color': Colors.green},
      {'id': 'ORD-003', 'name': 'محبس فضة عقيق',      'status': 'قيد المراجعة', 'price': '85,000',  'color': Colors.blue},
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(backgroundColor: kBg, title: const Text('طلباتي', style: TextStyle(color: kGold, fontWeight: FontWeight.bold)), centerTitle: true),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final o = orders[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: kGold.withOpacity(0.15))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(o['id'] as String, style: const TextStyle(color: kGold, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: (o['color'] as Color).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(o['status'] as String, style: TextStyle(color: o['color'] as Color, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(o['name'] as String, style: const TextStyle(color: kText, fontSize: 15)),
                const SizedBox(height: 4),
                Text('${o['price']} د.ع', style: const TextStyle(color: kGold, fontSize: 13)),
              ]),
            );
          },
        ),
      ),
    );
  }
}

class StudioScreen extends StatelessWidget {
  const StudioScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(backgroundColor: kBg, title: const Text('الاستوديو', style: TextStyle(color: kGold, fontWeight: FontWeight.bold)), centerTitle: true),
        body: Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.auto_awesome, color: kGold, size: 64),
            const SizedBox(height: 24),
            const Text('مستشار الأصالة التراثية', style: TextStyle(color: kText, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('استشر الذكاء الاصطناعي لتدقيق جودة عملك الفني وصياغة الوصف قبل النشر', style: TextStyle(color: kSubText, fontSize: 14, height: 1.6), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kGold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
              onPressed: () {},
              child: const Text('ابدأ المحادثة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ]),
        )),
      ),
    );
  }
}

class ArtisanScreen extends StatefulWidget {
  const ArtisanScreen({super.key});
  @override
  State<ArtisanScreen> createState() => _ArtisanScreenState();
}

class _ArtisanScreenState extends State<ArtisanScreen> {
  final _products = [
    {'name': 'إناء نحاسي منقوش',   'price': '125,000', 'stock': 3, 'status': 'معتمد'},
    {'name': 'طبق نحاسي مزخرف',    'price': '90,000',  'stock': 5, 'status': 'قيد المراجعة'},
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          backgroundColor: kBg,
          title: const Text('لوحة الحرفي', style: TextStyle(color: kGold, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [IconButton(icon: const Icon(Icons.add_circle_outline, color: kGold), onPressed: () => _showAddProduct(context))],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              Expanded(child: _StatCard('المبيعات', '١٢٥,٠٠٠ د.ع', Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard('التسوية', '٧ أيام', Colors.amber)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard('المنتجات', '${_products.length}', kGold)),
            ]),
            const SizedBox(height: 20),
            const Text('منتجاتي', style: TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._products.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: kGold.withOpacity(0.15))),
              child: Row(children: [
                const Icon(Icons.inventory_2_outlined, color: kGold, size: 32),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p['name'] as String, style: const TextStyle(color: kText, fontWeight: FontWeight.bold)),
                  Text('${p['price']} د.ع  |  الكمية: ${p['stock']}', style: TextStyle(color: kSubText, fontSize: 12)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (p['status'] == 'معتمد' ? Colors.green : Colors.orange).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(p['status'] as String, style: TextStyle(color: p['status'] == 'معتمد' ? Colors.green : Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ]),
            )),
          ],
        ),
      ),
    );
  }

  void _showAddProduct(BuildContext context) {
    final nameCtrl  = TextEditingController();
    final priceCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('إضافة منتج جديد', style: TextStyle(color: kGold, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: nameCtrl, style: const TextStyle(color: kText),
              decoration: InputDecoration(labelText: 'اسم المنتج', labelStyle: TextStyle(color: kSubText),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: kGold.withOpacity(0.3))),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: kGold)))),
            const SizedBox(height: 12),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: kText),
              decoration: InputDecoration(labelText: 'السعر (دينار)', labelStyle: TextStyle(color: kSubText),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: kGold.withOpacity(0.3))),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: kGold)))),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kGold, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 48)),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                  setState(() => _products.add({'name': nameCtrl.text, 'price': priceCtrl.text, 'stock': 1, 'status': 'قيد المراجعة'}));
                  Navigator.pop(context);
                }
              },
              child: const Text('رفع المنتج', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}

Widget _StatCard(String label, String value, Color color) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: kGold.withOpacity(0.15))),
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(color: kSubText, fontSize: 11)),
    ]),
  );
}

class FounderScreen extends StatelessWidget {
  const FounderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          backgroundColor: kBg,
          title: const Text('بوابة المؤسس', style: TextStyle(color: kGold, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [Container(
            margin: const EdgeInsets.only(left: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: const Text('مؤمن ٢٥٦ بت', style: TextStyle(color: Colors.green, fontSize: 10)),
          )],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              Expanded(child: _StatCard('العمولات', '١٢,٥٠٠ د.ع', Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard('الحرفيون', '٢٤ نشط', kGold)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard('الامتثال', '١٠٠٪', Colors.green)),
            ]),
            const SizedBox(height: 20),
            const Text('إجراءات الجودة', style: TextStyle(color: kText, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _ActionCard('مراجعة منتج جديد', 'التحقق من أصالة العمل المرفوع', Icons.fact_check_outlined),
            const SizedBox(height: 10),
            _ActionCard('تقارير مالية', 'العمولات والمستحقات الأسبوعية', Icons.bar_chart_outlined),
            const SizedBox(height: 10),
            _ActionCard('إدارة الحسابات', 'مراجعة وتعليق الحسابات المخالفة', Icons.manage_accounts_outlined),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(border: Border.all(color: Colors.redAccent.withOpacity(0.4)), borderRadius: BorderRadius.circular(10)),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('نظام العقوبات الفوري — البند ٥.٣', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('في حال ثبوت التهرب أو بيع مواد مقلدة، يتم تطبيق الحظر الكلي فوراً.', style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _ActionCard(String title, String subtitle, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: kGold.withOpacity(0.15))),
    child: Row(children: [
      Icon(icon, color: kGold, size: 28),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: kText, fontWeight: FontWeight.bold)),
        Text(subtitle, style: TextStyle(color: kSubText, fontSize: 12)),
      ])),
      const Icon(Icons.arrow_back_ios, color: kGold, size: 14),
    ]),
  );
}
