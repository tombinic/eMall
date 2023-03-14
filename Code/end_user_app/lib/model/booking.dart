import 'package:flutter/material.dart';
import 'package:end_user_app/model/charging_station.dart';

/// Represents a booking for a charging station.
class Booking {
  /// The ID of the booking.
  late int id;

  /// The date of the booking.
  late DateTime? date;

  /// The start time of the booking.
  late TimeOfDay start;

  /// The end time of the booking.
  late TimeOfDay end;

  /// The username of the end user who made the booking.
  late String euUsername;

  /// The ID of the charging socket being booked.
  late int chargingSocketId;

  /// The type of the charging socket being booked.
  late String chargingSocketType;

  /// The charging station being booked.
  late ChargingStation chargingStation;

  /// Creates a new instance of [Booking] from scratch.
  Booking.fromScratch();

  /// Creates a new instance of [Booking] with the given [euUsername] and [chargingStation].
  Booking.fromUsernameAndChargingStation(this.euUsername, this.chargingStation);

  /// Creates a new instance of [Booking] with the given [id], [date], [start], [end], [euUsername], [chargingSocketType], and [chargingStation].
  Booking(this.id, this.date, this.start, this.end, this.euUsername,
      this.chargingSocketType, this.chargingStation);

  /// Creates a new instance of [Booking] with the given [id], [date], [start], [end].
  Booking.fromIdDateStartEnd(this.id, this.date, this.start, this.end);

  /// Creates a new instance of [Booking] from a JSON [Map].
  Booking.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        date = DateTime.parse(json["date"].toString()),
        start = TimeOfDay(
            hour: int.parse(json['start'].toString().split(":")[0]), minute: 0),
        end = TimeOfDay(
            hour: int.parse(json['end'].toString().split(":")[0]), minute: 0),
        euUsername = json['enduser_id'],
        chargingSocketId = json['chargingsocket_number'],
        chargingStation = ChargingStation(
            int.parse(json['charging_station']["id"]),
            json['charging_station']["name"],
            json['charging_station']["address"]);
}
