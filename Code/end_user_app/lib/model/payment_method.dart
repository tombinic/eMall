/// Represents a payment method for an end user.
class PaymentMethod {
  /// The card number of the payment method
  String cardNumber;

  /// The cvv of the payment method
  String cvv;

  /// The expired date of the payment method
  String expiredDate;

  /// Creates a new instance of [PaymentMethod] with the given [card_number], [cvv], [expired_date].
  PaymentMethod(this.cardNumber, this.cvv, this.expiredDate);

  /// Creates a new instance of [PaymentMethod] from a JSON [Map].
  PaymentMethod.fromJson(Map<String, dynamic> json)
      : cardNumber = json['card_number'],
        cvv = json['cvv'],
        expiredDate = json['expired_date'];
}
