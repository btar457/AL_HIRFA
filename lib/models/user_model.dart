import 'package:cloud_firestore/cloud_firestore.dart';

/// بيانات المستخدم المخزّنة في مجموعة "users" على Firestore.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // customer/artisan/shipping/admin
  final String city;
  final String photoUrl;
  final String? fcmToken;
  final bool isActive;
  final int warningCount;

  // حقول الموافقة القانونية (PART 11.6 من AL-HIRFA-Legal-Rules.md)
  final bool termsAccepted;
  final DateTime? termsAcceptedAt;
  final String termsVersion;
  final bool? artisanTermsAccepted; // للحرفي فقط
  final bool? shippingTermsAccepted; // لشركة الشحن فقط

  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.city,
    required this.createdAt,
    this.photoUrl = '',
    this.fcmToken,
    this.isActive = true,
    this.warningCount = 0,
    this.termsAccepted = false,
    this.termsAcceptedAt,
    this.termsVersion = '',
    this.artisanTermsAccepted,
    this.shippingTermsAccepted,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: map['role'] as String? ?? 'customer',
      city: map['city'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photoUrl: map['photoUrl'] as String? ?? '',
      fcmToken: map['fcmToken'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      warningCount: map['warningCount'] as int? ?? 0,
      termsAccepted: map['termsAccepted'] as bool? ?? false,
      termsAcceptedAt: (map['termsAcceptedAt'] as Timestamp?)?.toDate(),
      termsVersion: map['termsVersion'] as String? ?? '',
      artisanTermsAccepted: map['artisanTermsAccepted'] as bool?,
      shippingTermsAccepted: map['shippingTermsAccepted'] as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'city': city,
      'createdAt': Timestamp.fromDate(createdAt),
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
      'isActive': isActive,
      'warningCount': warningCount,
      'termsAccepted': termsAccepted,
      'termsAcceptedAt': termsAcceptedAt != null ? Timestamp.fromDate(termsAcceptedAt!) : null,
      'termsVersion': termsVersion,
      'artisanTermsAccepted': artisanTermsAccepted,
      'shippingTermsAccepted': shippingTermsAccepted,
    };
  }
}
