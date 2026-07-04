enum ArtisanProductStatus { active, pending, rejected }

/// منتج ضمن قائمة منتجات الحرفي (لوحة إدارة المنتجات).
class ArtisanProductListing {
  final String name;
  final String category;
  final String price;
  final ArtisanProductStatus status;

  const ArtisanProductListing({
    required this.name,
    required this.category,
    required this.price,
    required this.status,
  });
}
