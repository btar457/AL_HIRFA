import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';

/// طبقة إدارة المنتجات عبر Firestore وFirebase Storage.
class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const _productsCollection = 'products';
  static const _usersCollection = 'users';

  /// يرفع صور المنتج على Storage، ثم يحفظ المنتج في Firestore بحالة
  /// 'pending' بانتظار مراجعة الإدارة. يُعيد معرّف المنتج الجديد.
  Future<String> addProduct(ProductModel product, List<XFile> images) async {
    final docRef = _firestore.collection(_productsCollection).doc();
    final productId = docRef.id;

    final imageUrls = await uploadImages(product.artisanUid, productId, images);

    final newProduct = ProductModel(
      id: productId,
      name: product.name,
      description: product.description,
      price: product.price,
      category: product.category,
      city: product.city,
      images: imageUrls,
      artisanUid: product.artisanUid,
      artisanName: product.artisanName,
      narrative: product.narrative,
      material: product.material,
      originPlace: product.originPlace,
      technique: product.technique,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await docRef.set(newProduct.toMap());
    // TODO: إشعار Admin بمنتج جديد ينتظر المراجعة (بعد بناء notification_service.dart).
    return productId;
  }

  /// يرفع صور جديدة (إضافة أو تعديل) على Storage ويُعيد روابطها.
  Future<List<String>> uploadImages(String artisanUid, String productId, List<XFile> images) async {
    final imageUrls = <String>[];
    for (var i = 0; i < images.length; i++) {
      final ref = _storage.ref('products/$artisanUid/$productId/${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
      await ref.putFile(File(images[i].path));
      imageUrls.add(await ref.getDownloadURL());
    }
    return imageUrls;
  }

  /// منتجات المتجر النشطة، مع فلاتر اختيارية. فلترة السعر والبحث النصي
  /// تتم على العميل لأن Firestore لا يدعم استعلامات "يحتوي على" أو نطاقين
  /// مركّبين مباشرة دون فهرسة مخصّصة.
  Stream<List<ProductModel>> getActiveProducts({
    String? categoryId,
    String? city,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(_productsCollection).where('status', isEqualTo: 'active');
    if (categoryId != null && categoryId != 'all') {
      query = query.where('category', isEqualTo: categoryId);
    }
    if (city != null) {
      query = query.where('city', isEqualTo: city);
    }

    return query.snapshots().asyncMap((snapshot) async {
      var products = snapshot.docs.map((doc) => ProductModel.fromMap(doc.id, doc.data())).toList();
      if (products.isNotEmpty) {
        products = await _filterOutBannedArtisans(products);
      }
      if (minPrice != null) products = products.where((p) => p.price >= minPrice).toList();
      if (maxPrice != null) products = products.where((p) => p.price <= maxPrice).toList();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        products = products.where((p) => p.name.contains(searchQuery)).toList();
      }
      return products;
    });
  }

  /// يستثني منتجات الحرفيين المحظورين/الموقوفين من نتائج الواجهة العامة —
  /// حظر حرفي لا يجب أن يترك منتجاته السابقة معروضة للشراء.
  Future<List<ProductModel>> _filterOutBannedArtisans(List<ProductModel> products) async {
    final artisanUids = products.map((p) => p.artisanUid).toSet().toList();
    final activeArtisans = <String>{};
    for (var i = 0; i < artisanUids.length; i += 30) {
      final batch = artisanUids.sublist(i, i + 30 > artisanUids.length ? artisanUids.length : i + 30);
      final snap = await _firestore.collection(_usersCollection).where(FieldPath.documentId, whereIn: batch).get();
      for (final doc in snap.docs) {
        final isActive = doc.data()['isActive'] as bool? ?? true;
        final banned = doc.data()['banned'] as bool? ?? false;
        if (isActive && !banned) activeArtisans.add(doc.id);
      }
    }
    return products.where((p) => activeArtisans.contains(p.artisanUid)).toList();
  }

  /// منتجات حرفي معيّن (كل الحالات، لشاشة "منتجاتي").
  Stream<List<ProductModel>> getArtisanProducts(String artisanUid) {
    return _firestore.collection(_productsCollection).where('artisanUid', isEqualTo: artisanUid).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => ProductModel.fromMap(doc.id, doc.data())).toList(),
    );
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) {
    return _firestore.collection(_productsCollection).doc(productId).update(data);
  }

  Future<void> deleteProduct(String productId) {
    return _firestore.collection(_productsCollection).doc(productId).delete();
  }

  /// Admin: موافقة على منتج معلّق.
  Future<void> approveProduct(String productId) async {
    await _firestore.collection(_productsCollection).doc(productId).update({'status': 'active'});
    // TODO: إشعار الحرفي "تم قبول منتجك" (بعد بناء notification_service.dart).
  }

  /// Admin: رفض منتج معلّق مع ذكر السبب.
  Future<void> rejectProduct(String productId, String reason) async {
    await _firestore.collection(_productsCollection).doc(productId).update({'status': 'rejected', 'rejectionReason': reason});
    // TODO: إشعار الحرفي بسبب الرفض (بعد بناء notification_service.dart).
  }

  /// Admin: إيقاف منتج منشور (مخالفة، شكوى...) دون حذفه.
  Future<void> suspendProduct(String productId) {
    return _firestore.collection(_productsCollection).doc(productId).update({'status': 'suspended'});
  }

  /// Admin: إعادة تفعيل منتج موقوف.
  Future<void> reactivateProduct(String productId) {
    return _firestore.collection(_productsCollection).doc(productId).update({'status': 'active'});
  }

  /// عدد المنتجات النشطة الحقيقي ضمن فئة معيّنة — لشاشة admin_categories.
  Future<int> getActiveProductCountByCategory(String categoryId) async {
    final snapshot = await _firestore.collection(_productsCollection).where('category', isEqualTo: categoryId).where('status', isEqualTo: 'active').count().get();
    return snapshot.count ?? 0;
  }

  /// Admin: كل المنتجات بحالة معيّنة عبر كل الحرفيين — لشاشة admin_products.
  Stream<List<ProductModel>> getProductsByStatus(String status) {
    return _firestore.collection(_productsCollection).where('status', isEqualTo: status).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => ProductModel.fromMap(doc.id, doc.data())).toList(),
    );
  }

  /// إضافة/إزالة منتج من مفضلة المستخدم (users/{uid}/favorites/{productId}).
  Future<void> toggleFavorite(String productId, String userId) async {
    final favRef = _firestore.collection(_usersCollection).doc(userId).collection('favorites').doc(productId);
    final doc = await favRef.get();
    if (doc.exists) {
      await favRef.delete();
    } else {
      await favRef.set({'productId': productId, 'addedAt': Timestamp.now()});
    }
  }

  /// منتجات مفضلة المستخدم الكاملة.
  Stream<List<ProductModel>> getFavorites(String userId) {
    return _firestore.collection(_usersCollection).doc(userId).collection('favorites').snapshots().asyncMap((snapshot) async {
      final products = <ProductModel>[];
      for (final doc in snapshot.docs) {
        final productDoc = await _firestore.collection(_productsCollection).doc(doc.id).get();
        if (productDoc.exists) {
          products.add(ProductModel.fromMap(productDoc.id, productDoc.data()!));
        }
      }
      return products;
    });
  }

  /// معرّفات منتجات المفضلة فقط (بدون جلب المنتجات الكاملة) — أخف لعرض
  /// حالة "❤️" على بطاقات المتجر وتفاصيل المنتج.
  Stream<Set<String>> getFavoriteIds(String userId) {
    return _firestore.collection(_usersCollection).doc(userId).collection('favorites').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.id).toSet(),
    );
  }
}
