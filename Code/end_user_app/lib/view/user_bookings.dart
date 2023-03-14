import 'dart:async';
import 'package:end_user_app/view/booking_detail.dart';
import 'package:end_user_app/model/booking.dart';
import 'package:end_user_app/model/end_user.dart';
import 'package:end_user_app/controller/api_manager.dart';
import 'package:end_user_app/controller/api_response.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyBooking extends StatefulWidget {
  const MyBooking({super.key});

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
  late List<Booking> bookingValid;
  late List<Booking> bookingExpired;
  Future<List<Booking>>? futureBookingExpired;
  Future<List<Booking>>? futureBookingValid;
  ApiResponse _apiResponse = ApiResponse();
  final ApiManager _apiManager = ApiManager();

  @override
  void initState() {
    super.initState();
    bookingValid = [];
    bookingExpired = [];
    futureBookingValid = getUserBookings();
  }

  FutureOr onGoBack(dynamic value) {
    futureBookingValid = getUserBookings();
    setState(() {});
  }

  Future<List<Booking>> getUserBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String endUser = (prefs.getString('endUserUsername') ?? "");
    _apiResponse = await _apiManager.myBookings(EndUser.fromUsername(endUser));

    if ((_apiResponse.ApiError) == "") {
      bookingValid = (_apiResponse.Data as List<Booking>).toList();
    } else {
      showInSnackBar(_apiResponse.ApiError.toString());
    }
    futureBookingExpired = getUserExpiredBooking();
    return bookingValid;
  }

  Future<List<Booking>> getUserExpiredBooking() async {
    for (Booking booking in bookingValid) {
      if (booking.date
                  .toString()
                  .split(" ")[0]
                  .compareTo(DateTime.now().toIso8601String().split("T")[0]) <
              0 ||
          (booking.end.hour
                      .toString()
                      .compareTo(TimeOfDay.now().hour.toString()) <
                  0 &&
              booking.date.toString().split(" ")[0].compareTo(
                      DateTime.now().toIso8601String().split("T")[0]) ==
                  0)) {
        bookingExpired.add(booking);
      }
    }

    for (Booking booking in bookingExpired) {
      bookingValid.remove(booking);
    }

    return bookingExpired;
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  AppBar appBarBooking(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.bolt,
            color: Color.fromARGB(255, 194, 57, 235),
            size: 35,
          ),
          Text("My bookings"),
        ],
      ),
      elevation: 0,
      titleTextStyle: const TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
    );
  }

  Widget buildBooking(Booking bv) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            color: Color.fromARGB(255, 248, 244, 244)),
        child: ListTile(
          leading: const ImageIcon(AssetImage("assets/images/bolt.png")),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return BookingDetail(booking: bv);
            })).then(onGoBack);
          },
          contentPadding: const EdgeInsets.all(5),
          dense: true,
          title: Text(
            "${bv.chargingStation.name} - ${bv.chargingStation.address}",
            style: const TextStyle(fontSize: 15),
          ),
          subtitle: Text(
            bv.date.toString().split(" ")[0],
            style: const TextStyle(fontSize: 9),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_outlined),
          iconColor: const Color.fromARGB(255, 194, 57, 235),
        ),
      ),
    );
  }

  Widget buildBookingExpired(Booking bv) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            color: Color.fromARGB(255, 248, 244, 244)),
        child: ListTile(
          leading: const ImageIcon(AssetImage("assets/images/bolt.png")),
          contentPadding: const EdgeInsets.all(5),
          dense: true,
          title: Text(
            "${bv.chargingStation.name} - ${bv.chargingStation.address}",
            style: const TextStyle(fontSize: 15),
          ),
          subtitle: Text(
            bv.date.toString().toString().split(" ")[0],
            style: const TextStyle(fontSize: 9),
          ),
          iconColor: const Color.fromARGB(255, 194, 57, 235),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: appBarBooking(context),
            body: Center(
                child: FutureBuilder<List<Booking>>(
              future: futureBookingValid,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _activeBookings(),
                        Row(children: const <Widget>[
                          Expanded(child: Divider()),
                          Text("Expired Booking"),
                          Expanded(child: Divider()),
                        ]),
                        _expiredBookings()
                      ],
                    ),
                  );
                }
                return const CircularProgressIndicator(
                  color: Color.fromARGB(255, 194, 57, 235),
                );
              },
            ))));
  }

  Widget _activeBookings() {
    return Center(
      child: ListView(
        reverse: false,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: bookingValid.map(buildBooking).toList(),
      ),
    );
  }

  Widget _expiredBookings() {
    return Center(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: bookingExpired.map(buildBookingExpired).toList(),
      ),
    );
  }
}
