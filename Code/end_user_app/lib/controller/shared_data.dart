import 'package:end_user_app/model/booking.dart';
import 'package:flutter/material.dart';

/// The class SharedData extends ChangeNotifier and serves as a central data repository for application state.
///
/// It contains fields for various pieces of data, such as the base URL, a flag indicating if charging is enabled, a Booking instance, an ID for a charging station, and a level of charge.
///
/// It has both getters and setters for these fields, and the setters call notifyListeners to trigger a rebuild of the widgets that use this data. This makes the class an implementation of the Observable pattern, ensuring that changes to the data are propagated throughout the application.
class SharedData extends ChangeNotifier {
  /// This is a boolean attribute indicating whether the charging process is enabled or not.
  bool _enabledCharge = false;

  /// This is an integer attribute representing the ID of the charging station. The default value is set to -1, indicating no charging station is selected.
  int _csId = -1;

  /// This is a double attribute representing the level of charge of the vehicle. The default value is set to 0, indicating no charge is available.
  double _levelOfCharge = 0;

  /// This is an object of type Booking representing the current booking. The default value is created using the fromScratch constructor.
  Booking _booking = Booking.fromScratch();

  /// This is a string attribute representing the base URL of the API. The default value is an empty string, indicating no URL has been set.
  String _baseUrl = "";

  String get getBasedUrl => _baseUrl;
  bool get enabledCharge => _enabledCharge;
  Booking get getBooking => _booking;
  int get csId => _csId;
  double get getLevelOfCharge => _levelOfCharge;

  set enableCharge(bool value) {
    _enabledCharge = value;
    notifyListeners();
  }

  set setBaseUrl(String value) {
    _baseUrl = value;
  }

  set setLevelOfCharge(double value) {
    Future.microtask(() {
      _levelOfCharge = value;
      notifyListeners();
    });
  }

/*
  set setLevelOfCharge(double value) {
    _levelOfCharge = value;
    notifyListeners();
  }
*/
  set setBooking(Booking value) {
    _booking = value;
    notifyListeners();
  }

  set disableCharge(bool value) {
    _enabledCharge = value;
    notifyListeners();
  }

  set setCsId(int value) {
    _csId = value;
    notifyListeners();
  }
}
