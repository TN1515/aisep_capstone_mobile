class SubscriptionPaymentRequest {
  final int targetPlan;
  final int amount;

  SubscriptionPaymentRequest({
    required this.targetPlan,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'targetPlan': targetPlan,
    'amount': amount,
  };
}

class PaymentInfoDto {
  final String checkoutUrl;
  final int orderCode;

  PaymentInfoDto({
    required this.checkoutUrl,
    required this.orderCode,
  });

  factory PaymentInfoDto.fromJson(Map<String, dynamic> json) {
    return PaymentInfoDto(
      checkoutUrl: json['checkoutUrl'] ?? '',
      orderCode: json['orderCode'] ?? 0,
    );
  }
}
