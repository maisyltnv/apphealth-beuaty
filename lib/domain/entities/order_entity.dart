class OrderEntity {
  const OrderEntity({
    required this.id,
    required this.totalAmountLak,
    required this.status,
    required this.paymentReceiptUrl,
    required this.createdAt,
  });

  final int id;
  final double totalAmountLak;
  final String status;
  final String paymentReceiptUrl;
  final DateTime? createdAt;

  factory OrderEntity.fromJson(Map<String, dynamic> j) {
    DateTime? created;
    final raw = j['created_at'];
    if (raw is String) {
      created = DateTime.tryParse(raw);
    }
    return OrderEntity(
      id: (j['id'] as num).toInt(),
      totalAmountLak: (j['total_amount_lak'] as num?)?.toDouble() ?? 0,
      status: j['status'] as String? ?? '',
      paymentReceiptUrl: j['payment_receipt_url'] as String? ?? '',
      createdAt: created,
    );
  }
}
