import 'package:end_user_app/model/payment_method.dart';

/// Represents an end user of the system.
class EndUser {
  /// The end user's name.
  late String name;

  /// The end user's surname.
  late String surname;

  /// The end user's username, used for authentication.
  late String username;

  /// The end user's email address.
  late String email;

  /// List of the end user's credit cards.
  late List<PaymentMethod> creditCards;

  /// Creates a new instance of [EndUser] with the given [name], [surname], [username], [email], [creditCards].
  EndUser(this.name, this.surname, this.username, this.email, this.creditCards);

  /// Creates a new instance of [EndUser] with the given [username].
  EndUser.fromUsername(this.username);

  /// Creates a new instance of [EndUser] from a JSON [Map].
  EndUser.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        name = json['name'],
        surname = json['surname'],
        email = json['email'],
        creditCards = List<PaymentMethod>.unmodifiable(json['payment_method']
            .map((e) => PaymentMethod.fromJson(e))
            .toList());
}
