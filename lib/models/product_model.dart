import 'package:cloud_firestore/cloud_firestore.dart';

/// منتج موحّد للاستخدام عبر الأدوار (لوحات الإدارة والبحث)، إلى جانب
/// MarketplaceProduct وArtisanProductListing المستخدمين في شاشات محدّدة.
class ProductModel {
  final String id;
  final String name;
  final String description;
  final int price;
  final String category;
  final String city;
  final List<String> images;
  final String artisanUid;
  final String artisanName;
  final String narrative;
  final String material;
  final String originPlace;
  final String technique;
  final String status; // pending, active, rejected, suspended
  final double rating;
  final int salesCount;
  final DateTime createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.city,
    required this.images,
    required this.artisanUid,
    required this.artisanName,
    this.narrative = '',
    this.material = '',
    this.originPlace = '',
    this.technique = '',
    required this.status,
    this.rating = 0,
    this.salesCount = 0,
    required this.createdAt,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: map['price'] as int? ?? 0,
      category: map['category'] as String? ?? '',
      city: map['city'] as String? ?? '',
      images: (map['images'] as List?)?.map((e) => e as String).toList() ?? const [],
      artisanUid: map['artisanUid'] as String? ?? '',
      artisanName: map['artisanName'] as String? ?? '',
      narrative: map['narrative'] as String? ?? '',
      material: map['material'] as String? ?? '',
      originPlace: map['originPlace'] as String? ?? '',
      technique: map['technique'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      salesCount: map['salesCount'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'city': city,
      'images': images,
      'artisanUid': artisanUid,
      'artisanName': artisanName,
      'narrative': narrative,
      'material': material,
      'originPlace': originPlace,
      'technique': technique,
      'status': status,
      'rating': rating,
      'salesCount': salesCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
