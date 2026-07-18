/// منتج ضمن شبكة المتجر التفصيلية (marketplace_screen وما يعيد استخدامها).
class MarketplaceProduct {
  final String name;
  final String price;
  final String city;
  final String cityTag;
  final String imageUrl;

  const MarketplaceProduct({
    required this.name,
    required this.price,
    required this.city,
    required this.cityTag,
    this.imageUrl = '',
  });
}
