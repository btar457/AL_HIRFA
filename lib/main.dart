import 'package:flutter/material.dart';

void main() {
  runApp(const AlHirfaApp());
}

class AlHirfaApp extends StatefulWidget {
  const AlHirfaApp({super.key});

  @override
  State<AlHirfaApp> createState() => _AlHirfaAppState();
}

class _AlHirfaAppState extends State<AlHirfaApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Al-Hirfa | الحرفة',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      
      // النمط الداكن السينمائي (Heritage Cinematic - Dark)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        primaryColor: const Color(0xFFD4AF37),
        cardColor: const Color(0xFF1A1A1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),      // الذهب التراثي
          secondary: Color(0xFF8B5A2B),    // البرونز البني
          surface: Color(0xFF161616),
          error: Color(0xFFCF6679),
        ),
        fontFamily: 'Cairo',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 14, color: Colors.white80),
          bodySmall: TextStyle(fontSize: 12, color: Colors.white54),
        ),
      ),

      // النمط الفاتح السينمائي (Heritage Cinematic - Light)
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
        primaryColor: const Color(0xFF8B5A2B),
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF8B5A2B),
          secondary: Color(0xFFD4AF37),
          surface: Color(0xFFF5F0E6),
          error: Colors.redAccent,
        ),
        fontFamily: 'Cairo',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C1A04)),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C1A04)),
          bodyLarge: TextStyle(fontSize: 14, color: Colors.black87),
          bodySmall: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ),
      home: MainNavigationHub(toggleTheme: toggleTheme),
    );
  }
}

// مركز التحكم والملاحة الموحد لكافة الأنظمة
class MainNavigationHub extends StatefulWidget {
  final VoidCallback toggleTheme;
  const MainNavigationHub({super.key, required this.toggleTheme});

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  int _selectedSystemIndex = 0;

  final List<Widget> _systems = [
    const BuyerSystemRoot(),      // نظام المشتري (المعرض، الفئات، السلة)
    const ArtisanSystemRoot(),    // نظام الحرفي والمزود (المخزون، إضافة المنتجات)
    const LogisticsSystemRoot(),  // النظام اللوجستي (شركات الشحن، التتبع)
    const FounderSystemRoot(),    // بوابة المؤسس والأمن وضبط الجودة
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AL - HIRFA | الـحـرفـة', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.brightness_6_outlined),
          onPressed: widget.toggleTheme,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(
              child: Text(
                _getSystemName(_selectedSystemIndex),
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          )
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _systems[_selectedSystemIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedSystemIndex,
        onTap: (index) => setState(() => _selectedSystemIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey.withOpacity(0.6),
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'المشتري'),
          BottomNavigationBarItem(icon: Icon(Icons.gavel_outlined), activeIcon: Icon(Icons.gavel), label: 'الحرفي'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), activeIcon: Icon(Icons.local_shipping), label: 'الشحن'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), activeIcon: Icon(Icons.admin_panel_settings), label: 'المؤسس'),
        ],
      ),
    );
  }

  String _getSystemName(int index) {
    switch (index) {
      case 0: return 'معرض التحف';
      case 1: return 'لوحة الحرفي';
      case 2: return 'لوحة اللوجستيات';
      case 3: return 'التحكم والأمن';
      default: return '';
    }
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ٢. رحلة المستخدم والمشتري (Buyer Journey System)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class BuyerSystemRoot extends StatefulWidget {
  const BuyerSystemRoot({super.key});

  @override
  State<BuyerSystemRoot> createState() => _BuyerSystemRootState();
}

class _BuyerSystemRootState extends State<BuyerSystemRoot> {
  final List<Map<String, dynamic>> _products = [
    {'id': '1', 'title': 'إناء نحاسي منقوش يدوياً', 'artisan': 'الحرفي أبو مصطفى', 'price': 125000, 'category': 'نحاسيات', 'stock': 3, 'rating': 4.9},
    {'id': '2', 'title': 'سجادة صوفية بنمط بابلي', 'artisan': 'حرفيو ذي قار', 'price': 450000, 'category': 'سجاد وتطريز', 'stock': 1, 'rating': 5.0},
    {'id': '3', 'title': 'خنجر سومري مقبض عاج', 'artisan': 'محترف النحاسيات', 'price': 320000, 'category': 'تحف وفضيات', 'stock': 2, 'rating': 4.8},
  ];

  final List<Map<String, dynamic>> _cart = [];

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      _cart.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إضافة ${product['title']} إلى سلة التسوق'), backgroundColor: Theme.of(context).colorScheme.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: AppBar(
            bottom: TabBar(
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(text: 'المعرض الحالي'),
                Tab(text: 'التصنيفات التراثية'),
                Tab(text: 'سلة الشراء الموحدة'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildGalleryView(),
            _buildCategoriesView(),
            _buildCartView(),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryView() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.withOpacity(0.1),
                    child: Icon(Icons.image, size: 50, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(product['title'], style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(product['artisan'], style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    Text('${product['price']} د.ع', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                    Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), Text('${product['rating']}', style: Theme.of(context).textTheme.bodySmall)]),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: () => _addToCart(product),
                    child: const Text('حجز واقتناء', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesView() {
    final categories = ['نحاسيات وريازة', 'سجاد وتطريز الرافدين', 'فخاريات وتماثيل طينية', 'فضيات وتحف تراثية'];
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Card(
          color: Theme.of(context).cardColor,
          margin: const EdgeInsets.bottom(10),
          child: ListTile(
            leading: Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
            title: Text(categories[index], style: Theme.of(context).textTheme.titleMedium),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildCartView() {
    if (_cart.isEmpty) {
      return const Center(child: Text('سلة التسوق فارغة حالياً. تصفح المعرض لاقتناء التحف.'));
    }
    num total = _cart.fold(0, (sum, item) => sum + item['price']);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _cart.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Theme.of(context).cardColor,
                  child: ListTile(
                    title: Text(_cart[index]['title']),
                    subtitle: Text('${_cart[index]['price']} دينار عراقي'),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                      onPressed: () => setState(() => _cart.removeAt(index)),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(color: Theme.of(context).colorScheme.primary),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text('إجمالي القيمة التقديرية:', style: Theme.of(context).textTheme.titleMedium),
                Text('$total د.ع', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الانتقال لبوابة الدفع الأمنة (ZainCash / Qi Card)...')),
                );
              },
              child: const Text('إتمام الدفع الآمن المتوافق مع شروط حماية المستهلك', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ٣. نظام وإدارة الحرفيين والمزودين (Artisan System)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ArtisanSystemRoot extends StatefulWidget {
  const ArtisanSystemRoot({super.key});

  @override
  State<ArtisanSystemRoot> createState() => _ArtisanSystemRootState();
}

class _ArtisanSystemRootState extends State<ArtisanSystemRoot> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  final List<Map<String, dynamic>> _myInventory = [
    {'title': 'إناء نحاسي منقوش يدوياً', 'price': 125000, 'stock': 3, 'status': 'معتمد وموثق'},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: AppBar(
            bottom: TabBar(
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(text: 'لوحة التحكم والمخزون'),
                Tab(text: 'إدراج تحفة جديدة'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildInventoryDashboard(),
            _buildAddProductForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryDashboard() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Theme.of(context).colorScheme.surface,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [Text('المبيعات المستحقة'), SizedBox(height: 8), Text('١٢٥,٠٠٠ د.ع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green))],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  color: Theme.of(context).colorScheme.surface,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [Text('فترة تسوية المدفوعات'), SizedBox(height: 8), Text('٧ أيام عمل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber))],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('إدارة المخزون والمنتجات المنشورة:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _myInventory.length,
              itemBuilder: (context, index) {
                final item = _myInventory[index];
                return Card(
                  color: Theme.of(context).cardColor,
                  child: ListTile(
                    title: Text(item['title']),
                    subtitle: Text('السعر الحالي: ${item['price']} د.ع | الكمية المتوفرة: ${item['stock']}'),
                    trailing: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                      child: Text(item['status'], style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إدراج منتج يدوي جديد وتحت طائلة مسؤولية الأصالة الحرفية', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'اسم المنتج والتحفة التراثية', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'السعر النهائي بالدينار العراقي', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'الوصف الفني والمواد التكوينية يدوياً', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Row(
                children: [
                  Icon(Icons.gavel, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('بإدراج المنتج، أقر قانوناً بالتزامي ببنود المادة ٢.٤ الخاصة بالأصالة وعدم التقليد.', style: TextStyle(fontSize: 11))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _myInventory.add({
                        'title': _titleController.text,
                        'price': int.parse(_priceController.text),
                        'stock': 1,
                        'status': 'قيد المراجعة والتدقيق'
                      });
                    });
                    _titleController.clear(); _priceController.clear(); _descController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال المنتج لتدقيق الجودة والأصالة التراثية.')));
                  }
                },
                child: const Text('رفع وتوثيق المنتج في المنصة', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ٤. النظام اللوجستي وشركات الشحن (Logistics System)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class LogisticsSystemRoot extends StatelessWidget {
  const LogisticsSystemRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> activeShipments = [
      {'id': 'TRK-9082', 'from': 'الحرفي أبو مصطفى (بغداد)', 'to': 'المشتري (الناصرية - ذي قار)', 'status': 'جاري التوصيل التابع للمرحلة ٣.٣', 'deadline': 'خلال ٢٤ ساعة'},
    ];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('لوحة متابعة الشريك اللوجستي والتتبع الآني المَحلي', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: activeShipments.length,
              itemBuilder: (context, index) {
                final shipment = activeShipments[index];
                return Card(
                  color: Theme.of(context).cardColor,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            Text('رقم الشحنة الموحد: ${shipment['id']}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                            const Icon(Icons.local_shipping, size: 20),
                          ],
                        ),
                        const Divider(height: 20),
                        Text('نقطة الاستلام: ${shipment['from']}', style: Theme.of(context).textTheme.bodyLarge),
                        Text('وجهة التسليم النهائية: ${shipment['to']}', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            Text('الحالة التشغيلية: ${shipment['status']}', style: const TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold)),
                            Text('الالتزام الزمني المتبقي: ${shipment['deadline']}', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(side: BorderSide(color: Theme.of(context).colorScheme.primary)),
                            icon: const Icon(Icons.camera_alt_outlined, size: 18),
                            label: const Text('توثيق حالة الشحنة بالصور عند التسليم', style: TextStyle(fontSize: 12)),
                            onPressed: () {},
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ٥. بوابة المؤسس، الأمن، وضبط الجودة (Founder Dashboard)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class FounderSystemRoot extends StatelessWidget {
  const FounderSystemRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('بوابة التحكم العليا للمؤسس ونظام ضبط معايير الأصالة التراثية', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).cardColor,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.between, children: [Text('العمولة الإجمالية المحققة (١٠%)'), Text('١٢,٥٠٠ د.ع', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))]),
                  Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.between, children: [Text('إجمالي حسابات الحرفيين النشطة'), Text('٢٤ حرفي معتمد')]),
                  Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.between, children: [Text('مستوى الامتثال القانوني وحماية السرية'), Text('١٠٠% مؤمن ومُشفر')]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('إجراءات جودة المنصة المستعجلة الحالية:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            tileColor: Theme.of(context).cardColor,
            leading: const Icon(Icons.gavel, color: Colors.amber),
            title: const Text('مراجعة طلب التوثيق للمنتج المرفوع حديثاً'),
            subtitle: const Text('التحقق الميداني أو المرئي من أصالة الخنجر السومري المرفوع.'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () {}),
                IconButton(icon: const Icon(Icons.cancel, color: Colors.redAccent), onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: Colors.redAccent.withOpacity(0.5)), borderRadius: BorderRadius.circular(6)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('نظام العقوبات الفوري للانتهاكات الجسيمة البند ٥.٣:', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('في حال ثبوت محاولات التهرب أو بيع مواد مستوردة ومقلدة، يتم تطبيق الحظر الكلي وتجميد الحساب فوراً بصلاحيات الإدارة المطلقة.', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
