import 'package:cloud_firestore/cloud_firestore.dart';

/// بيانات المستخدم المخزّنة في مجموعة "users" على Firestore.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // customer/artisan/shipping/admin
  final String city;

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
      'termsAccepted': termsAccepted,
      'termsAcceptedAt': termsAcceptedAt != null ? Timestamp.fromDate(termsAcceptedAt!) : null,
      'termsVersion': termsVersion,
      'artisanTermsAccepted': artisanTermsAccepted,
      'shippingTermsAccepted': shippingTermsAccepted,
    };
  }
}
