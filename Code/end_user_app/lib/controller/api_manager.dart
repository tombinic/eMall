import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:end_user_app/model/booking.dart';
import 'package:end_user_app/model/charging_socket.dart';
import 'package:end_user_app/model/charging_station.dart';
import 'package:end_user_app/model/end_user.dart';
import 'package:end_user_app/model/payment_method.dart';
import 'package:end_user_app/controller/api_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:end_user_app/config/config.dart';
import 'package:crypto/crypto.dart';

/// Class to manage and handle http request.
class ApiManager {
  ApiManager();

  /// Base url to application server.
  final String _baseUrl = Config().baseUrl;

  ///This function is used to register a new user by sending a HTTP POST request to the /signup endpoint of a server. The function takes in the [name], [surname], [email], [username], and [password] of the user as parameters.
  ///
  ///Before sending the request, the password is hashed using the SHA-256 algorithm and converted to a string. The request is then sent with the user's information in the body, including the hashed password.
  ///
  ///The response from the server is decoded into a JSON object, and its status code is checked to determine if the registration was successful. If the status code is 200, the function sets the Data property of the ApiResponse object to a new instance of an object. If the status code is 500, the error message from the server is stored in the ApiError property of the ApiResponse object.
  ///In case of a SocketException, the function sets the ApiError property of the ApiResponse object to a default error message.
  ///
  /// Returns a [Future] containing an [ApiResponse] object.
  Future<ApiResponse> registerUser(String name, String surname, String email,
      String username, String password) async {
    ApiResponse apiResponse = ApiResponse();
    List<int> bytes = utf8.encode(password);
    Digest digest = sha256.convert(bytes);
    String hash = digest.toString();
    try {
      final response = await http.post(Uri.parse("$_baseUrl/signup"), body: {
        "name": name,
        "surname": surname,
        "email": email,
        "username": username,
        "password": hash,
        "type": "enduser"
      });

      Map<String, dynamic> data = jsonDecode(response.body);

      switch (data["status_code"]) {
        case 200:
          apiResponse.Data = Object();
          break;
        case 500:
          apiResponse.ApiError = response.body;
          break;
      }
    } on SocketException {
      apiResponse.ApiError = "Server error. Please retry";
    }
    return apiResponse;
  }

  /// This function is used to authenticate a user by sending a HTTP POST request to the /login endpoint of a server. The function takes in the [username] and [password] of the user as parameters.
  ///
  /// Before sending the request, the password is hashed using the SHA-256 algorithm and converted to a string. The request is then sent with the username and hashed password in the body.
  /// The response from the server is checked for its status code, and the behavior of the function depends on the status code. If the status code is 200, the response body is decoded into a JSON object, and a new EndUser object is created from the username data. This new object is then stored in the Data property of the ApiResponse object.
  ///
  /// If the status code is 404 or 500, the error message from the server is stored in the ApiError property of the ApiResponse object.
  /// In case of a SocketException, the function sets the ApiError property of the ApiResponse object to a default error message.
  ///
  /// Returns a [Future] containing an [ApiResponse] object.
  Future<ApiResponse> authenticateUser(String username, String password) async {
    ApiResponse apiResponse = ApiResponse();
    List<int> bytes = utf8.encode(password);
    Digest digest = sha256.convert(bytes);
    String hash = digest.toString();

    try {
      final response = await http.post(Uri.parse("$_baseUrl/login"),
          body: {"username": username, "password": hash, "type": "enduser"});

      int statusCode = response.statusCode;

      switch (statusCode) {
        case 200:
          Map<String, dynamic> data = jsonDecode(response.body);
          apiResponse.Data = EndUser.fromUsername(data["data"][0]["username"]);
          break;
        case 404:
          apiResponse.ApiError = response.body;
          break;
        case 500:
          apiResponse.ApiError = response.body;
          break;
      }
    } on SocketException {
      apiResponse.ApiError = "Server error. Please retry";
    }
    return apiResponse;
  }

  /// This function is used to retrieve a list of nearby charging stations by sending a HTTP POST request to the /map endpoint of a server. The function takes in the [latitude] and [longitude] of the user's current location as parameters.
  /// The request is sent with the latitude and longitude in the body.
  /// The response from the server is checked for its status code, and the behavior of the function depends on the status code. If the status code is 200, the response body is decoded into a JSON object and a list of ChargingStation objects is created from the data. This list is then stored in the Data property of the ApiResponse object.
  ///
  /// If the status code is 400, the Data property of the ApiResponse object is set to an empty list and the error message from the server is stored in the ApiError property.
  /// In case of a SocketException, the function sets the ApiError property of the ApiResponse object to a default error message.
  ///
  /// Finally, the function returns the ApiResponse object, which contains either the list of ChargingStation objects or an error message.
  /// Returns a [Future] containing an [ApiResponse] object
  Future<ApiResponse> getNearbyChargingStation(
      double latitude, double longitude) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final response = await http.post(Uri.parse("$_baseUrl/map"),
          body: {"lat": latitude.toString(), "long": longitude.toString()});
      int statusCode = response.statusCode;
      Map<String, dynamic> data = jsonDecode(response.body);

      List<ChargingStation> csList = [];
      switch (statusCode) {
        case 200:
          for (var cs in data["data"]) {
            csList.add(ChargingStation.fromJson(cs));
          }
          apiResponse.Data = csList;
          break;
        case 400:
          apiResponse.Data = csList;
          apiResponse.ApiError = data.toString();
          break;
      }
    } on SocketException {
      apiResponse.ApiError = "Server error. Please retry";
    }
    return apiResponse;
  }

  /// Function to get busy bookings by charging station ID, [csId] and socket type, [socketType]
  ///
  /// This function uses the [http] package to make a GET request to the API at the
  /// URL constructed by combining the base URL and the specified charging station ID
  /// and socket type. The response is then decoded into a Map<String, dynamic> and
  /// iterated through to create a List of Booking objects, which is then added to
  /// the data field of the ApiResponse object.
  ///
  /// In case of a 200 OK response, the ApiResponse object will contain the List of
  /// Booking objects. In case of a 404 Not Found response, the ApiResponse object
  /// will contain an empty List and the error message from the response body.
  /// In case of a SocketException, the ApiResponse object will contain an error
  /// message indicating a server error.
  ///
  /// Returns a [Future] containing an [ApiResponse] object.
  Future<ApiResponse> getBusyBooking(int csId, String socketType) async {
    String url = "$_baseUrl/bookingbytype/$csId/$socketType";

    ApiResponse apiResponse = ApiResponse();
    try {
      final response = await http.get(Uri.parse(url));
      int statusCode = response.statusCode;
      List<Booking> bookingList = [];

      switch (statusCode) {
        case 200:
          Map<String, dynamic> data = jsonDecode(response.body);

          for (var b in data["data"]) {
            String splittedStart = b["start"];
            String splittedEnd = b["end"];
            int hourStart = int.parse(splittedStart.split(":")[0]);
            int minuteStart = int.parse(splittedStart.split(":")[1]);
            int hourEnd = int.parse(splittedEnd.split(":")[0]);
            int minuteEnd = int.parse(splittedEnd.split(":")[1]);

            bookingList.add(Booking.fromIdDateStartEnd(
                int.parse(b["id"].toString()),
                (DateTime.tryParse(b["date"])),
                (TimeOfDay(hour: hourStart, minute: minuteStart)),
                TimeOfDay(hour: hourEnd, minute: minuteEnd)));
          }
          apiResponse.Data = bookingList;
          break;
        case 404:
          apiResponse.Data = bookingList;
          apiResponse.ApiError = response.body;
          break;
      }
    } on SocketException {
      apiResponse.ApiError = "Server error. Please retry";
    }
    return apiResponse;
  }

  /// This function makes an HTTP POST request to the specified URL with a JSON body containing the details of a new [booking] to be created.
  ///
  /// The response is then parsed and stored in an [ApiResponse] object, which includes the details of the newly created booking or an error message if the request was not successful.
  Future<ApiResponse> newBooking(Booking booking) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final response =
          await http.post(Uri.parse("$_baseUrl/insertbooking"), body: {
        "date": booking.date.toString().split(" ")[0],
        "start": "${booking.start.hour}:00:00",
        "end": "${booking.end.hour}:00:00",
        "enduser_id": booking.euUsername,
        "chargingstation_id": booking.chargingStation.id.toString(),
        "chargingsocket_type": booking.chargingSocketType
      });
      int statusCode = response.statusCode;
      switch (statusCode) {
        case 200:
          Map<String, dynamic> data = jsonDecode(response.body);
          apiResponse.Data = Booking.fromJson(data["data"][0]);
          break;
        case 500:
          apiResponse.Data = Booking.fromUsernameAndChargingStation(
              booking.euUsername,
              ChargingStation(
                  booking.chargingStation.id,
                  booking.chargingStation.name,
                  booking.chargingStation.address));
          apiResponse.ApiError = response.body;
          break;
        case 404:
          apiResponse.Data = Booking.fromUsernameAndChargingStation(
              booking.euUsername,
              ChargingStation(
                  booking.chargingStation.id,
                  booking.chargingStation.name,
                  booking.chargingStation.address));
          apiResponse.ApiError = response.body;
          break;
      }
    } on SocketException {
      apiResponse.ApiError = "Server error. Please retry";
    }
    return apiResponse;
  }

  /// This method fetches a list of bookings associated with a given EndUser, [endUser]
  ///
  /// The endUser parameter is the user whose bookings are to be retrieved. The username of this user is used to construct the API request URL.
  ///
  /// Returns a [Future] that resolves to an [ApiResponse] object. The response data contains a list of [Booking] objects if the request was successful, otherwise it contains an error message. The [ApiResponse] also has a Data property that will contain the list of bookings.
  Future<ApiResponse> myBookings(EndUser endUser) async {
    String url = "$_baseUrl/userbooking/${endUser.username}";
    ApiResponse apiResponse = ApiResponse();
    try {
      final response = await http.get(Uri.parse(url));
      int statusCode = response.statusCode;
      List<Booking> bookingList = [];

      switch (statusCode) {
        case 200:
          Map<String, dynamic> data = jsonDecode(response.body);
          for (var b in data["data"]) {
            bookingList.add(Booking.fromJson(b));
          }
          apiResponse.Data = bookingList;
          break;
        case 500:
          apiResponse.Data = bookingList;
          apiResponse.ApiError = response.body;
          break;
        case 404:
          apiResponse.Data = bookingList;
          apiResponse.ApiError = response.body;
          break;
      }
    } on SocketException {
      apiResponse.ApiError = "Server error. Please retry";
    }
    return apiResponse;
  }

  /// Future function to delete a [booking].
  ///
  /// Sends a DELETE HTTP request to the server with the booking's ID,
  ///
  /// Returns an [ApiResponse] instance that holds the server response.
  Future<ApiResponse> deleteBooking(Booking booking) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final response =
          await http.delete(Uri.parse("$_baseUrl/booking/${booking.id}"));
      int statusCode = response.statusCode;

      switch (statusCode) {
        case 200:
          apiResponse.Data = response.body;
          break;
        case 404:
          apiResponse.ApiError = response.body;
          break;
        case 500:
          apiResponse.ApiError = response.body;
          break;
      }
    } on SocketException {
      apiResponse.ApiError = "Server error. Please retry";
    }
    return apiResponse;
  }

  /// userDetails function makes a GET request to retrieve the personal information of a specific EndUser, [endUser]
  ///
  /// The returned [ApiResponse] object contains either the EndUser data in the Data field or an error message in the ApiError field.
  ///
  /// The function uses a try-catch block to handle exceptions from the HTTP request and sets the ApiError field to a user-friendly message in case of a SocketException.
  ///
  /// If the HTTP response status code is 200, the function decodes the JSON response and creates an EndUser object from it.
  /// For status codes 404 or 500, the function sets the error message in the ApiError field.
  Future<ApiResponse> userDetails(EndUser endUser) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/personalinformation/${endUser.username}"),
      );
      int statusCode = response.statusCode;

      switch (statusCode) {
        case 200:
          Map<String, dynamic> data = jsonDecode(response.body);
          apiResponse.Data = EndUser.fromJson(data["data"][0]);
          break;
        case 404:
          apiResponse.ApiError = response.body;
          break;
        case 500:
          apiResponse.ApiError = response.body;
          break;
      }
    } on SocketException {
      apiResponse.ApiError = "Server error. Please retry";
    }
    return apiResponse;
  }

  /// Updates the name and surname of an EndUser, [endUser].
  ///
  /// Returns an [ApiResponse] object containing the updated user information
  /// or an error message if something goes wrong.
  ///
  /// An Http.put request is sent to the server at the specified _baseUrl/personalinfo/ endpoint,
  /// passing the username, name, and surname of the EndUser as a JSON object in the request body.
  ///
  /// The response from the server is then checked for its status code, which is stored in statusCode.
  /// If the status code is 200, the response body is parsed as a JSON object,
  /// the user information is extracted and stored in the Data field of the ApiResponse object.
  /// If the status code is 404 or 500, the response body is stored as an error message in the ApiError field of the ApiResponse object.
  ///
  /// If a SocketException is caught, the ApiError field of the ApiResponse object is set to
  /// "Server error. Please retry".
  Future<ApiResponse> updateNameSurname(EndUser endUser) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final response = await http.put(Uri.parse("$_baseUrl/personalinfo/"),
          body: {
            "username": endUser.username,
            "name": endUser.name,
            "surname": endUser.surname
          });

      int statusCode = response.statusCode;

      switch (statusCode) {
        case 200:
          Map<String, dynamic> data = jsonDecode(response.body);
          apiResponse.Data = EndUser.fromJson(data["data"][0]);
          break;
        case 404:
          apiResponse.ApiError = response.body;
          break;
        case 500:
          apiResponse.ApiError = response.body;
          break;
      }
    } on SocketException {
      apiResponse.ApiError = "Server error. Please retry";
    }
    return apiResponse;
  }

  /// This function updates the email of an [endUser].
  /// It takes an EndUser object as input and returns a Future [ApiResponse] object.
  /// If the request is successful (HTTP status code 200), the data field of the returned ApiResponse object is populated with the updated EndUser object.
  ///
  /// If the request fails due to a server error (e.g. SocketException), the apiError field of the returned ApiResponse object is set to an appropriate error message.
  /// If the request fails due to a client error (HTTP status code 404 or 500), the apiError field of the returned ApiResponse object is set to the error message returned by the server.
  Future<ApiResponse> updateEmail(EndUser endUser) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final response = await http.put(Uri.parse("$_baseUrl/email/"),
          body: {"username": endUser.username, "email": endUser.email});

      int statusCode = response.statusCode;

      switch (statusCode) {
        case 200:
          Map<String, dynamic> data = jsonDecode(response.body);
          apiResponse.Data = EndUser.fromJson(data["data"][0]);
          break;
        case 404:
          apiResponse.ApiError = response.body;
          break;
        case 500:
          apiResponse.ApiError = response.body;
          break;
      }
    } on SocketException {
      apiResponse.ApiError = "Server error. Please retry";
    }
    return apiResponse;
  }

  /// This function updates the password of an [endUser].
  /// It takes an EndUser object as input and returns a Future [ApiResponse] object.
  /// If the request is successful (HTTP status code 200), the data field of the returned ApiResponse object is populated with the updated EndUser object.
  ///
  /// If the request fails due to a server error (e.g. SocketException), the apiError field of the returned ApiResponse object is set to an appropriate error message.
  /// If the request fails due to a client error (HTTP status code 404 or 500), the apiError field of the returned ApiResponse object is set to the error message returned by the server.
  Future<ApiResponse> updatePassword(
      EndUser endUser, String oldPassword, String newPassword) async {
    ApiResponse apiResponse = ApiResponse();
    List<int> bytesOld = utf8.encode(oldPassword);
    Digest digestOld = sha256.convert(bytesOld);
    String hashOld = digestOld.toString();

    List<int> bytesNew = utf8.encode(newPassword);
    Digest digestNew = sha256.convert(bytesNew);
    String hashNew = digestNew.toString();
    try {
      final response = await http.put(Uri.parse("$_baseUrl/password/"), body: {
        "username": endUser.username,
        "old_password": hashOld,
        "new_password": hashNew
      });

      int statusCode = response.statusCode;

      switch (statusCode) {
        case 200:
          Map<String, dynamic> data = jsonDecode(response.body);
          apiResponse.Data = EndUser.fromJson(data["data"][0]);
          break;
        case 400:
          apiResponse.ApiError = response.body;
          break;
        case 404:
          apiResponse.ApiError = response.body;
          break;
        case 500:
          apiResponse.ApiError = response.body;
          break;
      }
    } on SocketException {
      apiResponse.ApiError = "Server error. Please retry";
    }
    return apiResponse;
  }

  /// Adds a payment method, [pm] for the given [endUser].
  ///
  /// Returns a [Future] of [ApiResponse] that contains either the updated [EndUser] data or an error message if any.
  Future<ApiResponse> addPaymentMethod(
      EndUser endUser, PaymentMethod pm) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final response =
          await http.post(Uri.parse("$_baseUrl/insertpaymentmethod/"), body: {
        "username": endUser.username,
        "card_number": pm.cardNumber,
        "cvv": pm.cvv,
        "expired_date": pm.expiredDate
      });

      int statusCode = response.statusCode;

      switch (statusCode) {
        case 200:
          Map<String, dynamic> data = jsonDecode(response.body);
          apiResponse.Data = EndUser.fromJson(data["data"][0]);
          break;
        case 404:
          apiResponse.ApiError = response.body;
          break;
        case 500:
          apiResponse.ApiError = response.body;
          break;
      }
    } on SocketException {
      apiResponse.ApiError = "Server error. Please retry";
    }
    return apiResponse;
  }

  /// Future function to remove a payment method [pm] from the [endUser] account
  ///
  /// [endUser] is the user account information.
  /// [pm] is the payment method to be removed.
  ///
  /// Returns a [Future] of type [ApiResponse] containing the response of the API request.
  Future<ApiResponse> removePaymentMethod(
      EndUser endUser, PaymentMethod pm) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final response = await http.delete(Uri.parse(
          "$_baseUrl/paymentmethod/${endUser.username}/${pm.cardNumber}"));

      int statusCode = response.statusCode;

      switch (statusCode) {
        case 200:
          Map<String, dynamic> data = jsonDecode(response.body);
          apiResponse.Data = EndUser.fromJson(data["data"][0]);
          break;
        case 404:
          apiResponse.ApiError = response.body;
          break;
        case 500:
          apiResponse.ApiError = response.body;
          break;
      }
    } on SocketException {
      apiResponse.ApiError = "Server error. Please retry";
    }
    return apiResponse;
  }

  /// Function to retrieve the price of a charging socket at a charging station.
  ///
  /// [cs], the charging station of which the socket price needs to be retrieved.
  ///
  /// Returns a [Future] of type [ApiResponse], which contains either the list of charging sockets with their respective prices,
  /// or an error message if the operation was unsuccessful.
  Future<ApiResponse> getSocketPrice(ChargingStation cs) async {
    ApiResponse apiResponse = ApiResponse();
    try {
      final response =
          await http.get(Uri.parse("$_baseUrl/socketprice/${cs.id}"));

      int statusCode = response.statusCode;
      List<ChargingSocket> socketList = [];
      switch (statusCode) {
        case 200:
          Map<String, dynamic> data = jsonDecode(response.body);
          for (var cs in data["data"]) {
            socketList.add(ChargingSocket.fromJson(cs));
          }
          apiResponse.Data = socketList;
          break;
        case 404:
          apiResponse.Data = socketList;
          apiResponse.ApiError = response.body;
          break;
        case 500:
          apiResponse.Data = socketList;
          apiResponse.ApiError = response.body;
          break;
      }
    } on SocketException {
      apiResponse.ApiError = "Server error. Please retry";
    }
    return apiResponse;
  }
}
