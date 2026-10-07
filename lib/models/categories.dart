/// تصنيف حرفي/مادي معروض في المتجر (فخار، نحاسيات، منسوجات...).
class AppCategory {
  final String id;
  final String nameAr;
  final String nameEn;
  final String icon;
  final String imagePath;

  const AppCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.icon,
    required this.imagePath,
  });
}

const List<AppCategory> kAppCategories = [
  AppCategory(id: 'all', nameAr: 'الكل', nameEn: 'All', icon: '🗂️', imagePath: 'assets/images/cat_all.png'),
  AppCategory(id: 'clothing', nameAr: 'ملابس', nameEn: 'Clothing', icon: '👘', imagePath: 'assets/images/cat_clothing.png'),
  AppCategory(id: 'perfume', nameAr: 'عطور', nameEn: 'Perfume', icon: '🫙', imagePath: 'assets/images/cat_perfume.png'),
  AppCategory(id: 'pottery', nameAr: 'فخار وخزف', nameEn: 'Pottery', icon: '🏺', imagePath: 'assets/images/cat_pottery.png'),
  AppCategory(id: 'sculpture', nameAr: 'منحوتات', nameEn: 'Sculpture', icon: '🗿', imagePath: 'assets/images/cat_sculpture.png'),
  AppCategory(id: 'copper', nameAr: 'نحاسيات', nameEn: 'Copper', icon: '🔶', imagePath: 'assets/images/cat_copper.png'),
  AppCategory(id: 'textile', nameAr: 'منسوجات', nameEn: 'Textile', icon: '🧵', imagePath: 'assets/images/cat_textile.png'),
  AppCategory(id: 'jewelry', nameAr: 'مجوهرات', nameEn: 'Jewelry', icon: '💍', imagePath: 'assets/images/cat_jewelry.png'),
  AppCategory(id: 'weapons', nameAr: 'أسلحة تراثية', nameEn: 'Weapons', icon: '🗡️', imagePath: 'assets/images/cat_weapons.png'),
  AppCategory(id: 'wood', nameAr: 'أعمال خشبية', nameEn: 'Wood', icon: '🪵', imagePath: 'assets/images/cat_wood.png'),
  AppCategory(id: 'calligraphy', nameAr: 'خط عربي', nameEn: 'Calligraphy', icon: '🖋️', imagePath: 'assets/images/cat_calligraphy.png'),
];
