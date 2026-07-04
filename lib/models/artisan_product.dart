/// منتج ضمن مخزون الحرفي في لوحة تحكمه.
class ArtisanProduct {
  final String name;
  final String price;
  final int stock;
  final String status;

  const ArtisanProduct({
    required this.name,
    required this.price,
    required this.stock,
    required this.status,
  });
}
