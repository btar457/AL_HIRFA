/// ثوابت القوانين المالية والتشغيلية لمنصة AL-HIRFA (راجع AL-HIRFA-Legal-Rules.md — PART 9.1).
class AppRules {
  AppRules._();

  // العمولات
  static const double productCommission = 0.10;
  static const double shippingCommission = 0.10;
  static const int fixedDeliveryFee = 5000;
  static const int companyNetDelivery = 4500;
  static const int platformDeliveryFee = 500;

  // التأمين والتسوية
  static const int securityDeposit = 500000;
  static const int settlementDays = 7;
  static const double latePenaltyRate = 0.02;
  static const int minWithdrawal = 50000;
  static const int holdPeriodHours = 72;

  // الطلبات
  static const int sellerApprovalHours = 48;
  static const int shippingAcceptMinutes = 5;
  static const int shippingRetryMinutes = 10;
  static const int shippingMaxRetries = 3;
  static const int reviewWindowDays = 7;

  // العقوبات
  static const int consecutiveRejectsWarning = 3;
  static const int monthlyRejectsSuspension = 5;
  static const int suspensionDays = 7;
  static const int longSuspensionDays = 30;

  // التقييم
  static const double badRatingThreshold = 2.5;
  static const double goodRatingThreshold = 4.5;
  static const int consecutiveBadRatings = 3;

  // البلاغات
  static const int reportsForAutoSuspend = 3;
  static const int reviewHours = 24;
  static const int disputeResolutionHours = 48;
  static const int appealDays = 7;

  // صندوق الضمان
  static const double guaranteeFundRate = 0.05;
}
