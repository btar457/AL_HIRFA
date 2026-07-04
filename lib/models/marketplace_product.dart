/// منتج ضمن شبكة المتجر التفصيلية (marketplace_screen وما يعيد استخدامها).
class MarketplaceProduct {
  final String name;
  final String price;
  final String city;
  final String cityTag;

  const MarketplaceProduct({
    required this.name,
    required this.price,
    required this.city,
    required this.cityTag,
  });
}
