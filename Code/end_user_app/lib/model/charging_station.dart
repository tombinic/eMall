/// Represents a charging station.
class ChargingStation {
  /// The ID of the charging station.
  late int id;

  /// The name of the charging station.
  late String name;

  /// The address of the charging station.
  late String address;

  /// The latitude of the charging station's location.
  late String lat;

  /// The longitude of the charging station's location.
  late String long;

  /// The status of the charging station (available, not available).
  late String status;

  /// Creates a new instance of [ChargingStation] with the given [id], [name], [address].
  ChargingStation(this.id, this.name, this.address);

  /// Creates a new instance of [ChargingStation] with given [id].
  ChargingStation.fromId(this.id);

  /// Creates a new instance of [ChargingStation] from a JSON [Map].
  ChargingStation.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        address = json['address'],
        lat = json["lat"],
        long = json["long"],
        status = json["status"];
}
