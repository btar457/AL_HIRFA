/// ملخّص محفظة محسوب من سجل transactions (لا يُخزَّن كمستند مستقل).
class WalletModel {
  final int availableBalance;
  final int pendingBalance; // ضمن فترة الاحتجاز (72 ساعة للحرفي)
  final int totalEarnings;

  const WalletModel({
    this.availableBalance = 0,
    this.pendingBalance = 0,
    this.totalEarnings = 0,
  });
}
