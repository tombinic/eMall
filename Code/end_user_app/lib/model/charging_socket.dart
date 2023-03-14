/// Represents a charging socket.
class ChargingSocket {
  /// Unique identifier for the charging socket.
  late int id;

  /// Number of the socket.
  late int number;

  /// Type of socket, (Rapid, Fast, Slow).
  late String type;

  /// Current status of the socket, (Busy or Free).
  late String status;

  /// Price to use the socket for a certain amount of time.
  late double price;

  /// Creates a new instance of [ChargingSocket] with the given [id], [number], [type], [status], [price].
  ChargingSocket(this.id, this.number, this.type, this.status, this.price);

  /// Creates a new instance of [ChargingSocket] with the given [tyoe], [price].
  ChargingSocket.fromTypePrice(this.type, this.price);

  /// Creates a new instance of [ChargingSocket] from scratch.
  ChargingSocket.fromScratch();

  /// Creates a new instance of [ChargingSocket] from a JSON [Map].
  ChargingSocket.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        price = json['price'];

  /// Overrides the equality operator to compare two instances of [ChargingSocket].
  @override
  bool operator ==(dynamic other) =>
      other != null &&
      other is ChargingSocket &&
      type == other.type &&
      price == other.price;

  /// Overrides the `hashCode` function to enable using instances of [ChargingSocket] as keys in a [Map].
  @override
  int get hashCode => super.hashCode;
}
