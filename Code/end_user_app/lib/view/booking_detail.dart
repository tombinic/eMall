import 'dart:convert';
import 'package:end_user_app/controller/api_manager.dart';
import 'package:end_user_app/controller/api_response.dart';
import 'package:end_user_app/controller/shared_data.dart';
import 'package:end_user_app/controller/socket_singleton.dart';
import 'package:end_user_app/view/charge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/booking.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class BookingDetail extends StatefulWidget {
  const BookingDetail({super.key, required this.booking});
  final Booking booking;

  @override
  State<BookingDetail> createState() => _BookingDetailState();
}

class _BookingDetailState extends State<BookingDetail> {
  ApiResponse _apiResponse = ApiResponse();
  final ApiManager _apiManager = ApiManager();
  bool _isLoading = false;
  final socket = SocketSingleton().socket;

  @override
  void initState() {
    super.initState();
    initSocket(widget.booking);
  }

  @override
  void dispose() {
    super.dispose();
    var toSend = jsonDecode(
        "{\"entity\":\"emsp\",\"target\":\"booking_check\", \"username\":\"balestrieriNiccolò\",\"booking_id\":\"${widget.booking.id}\"}");
    socket.emit('leave', toSend);
  }

  AppBar appBarBookingDetail(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: const Text("Booking Detail"),
      elevation: 0,
      titleTextStyle: const TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
      leading: GestureDetector(
        child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              size: 20,
              color: Color.fromARGB(255, 194, 57, 235),
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            backgroundColor: Colors.white,
            appBar: appBarBookingDetail(context),
            body: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 20,
                      ),
                      Center(
                        child: Text(
                          "Charging Station ${widget.booking.chargingStation.name}",
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 65,
                      ),
                      Center(
                        child: Text(
                          widget.booking.chargingStation.address,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 65,
                      ),
                      Center(
                          child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            const WidgetSpan(
                              child: Icon(Icons.calendar_today_sharp, size: 20),
                            ),
                            TextSpan(
                              text:
                                  "${widget.booking.date.toString().split(" ")[0]}\n",
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.black),
                            ),
                            const WidgetSpan(
                              child: Icon(Icons.watch, size: 20),
                            ),
                            TextSpan(
                              text:
                                  "${widget.booking.start.hour}.${widget.booking.start.minute}0-${widget.booking.end.hour}.${widget.booking.end.minute}0",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            )
                          ],
                        ),
                      )),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 65,
                      ),
                      Center(
                        child: Text(
                          "Socket n° ${widget.booking.chargingSocketId}",
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 65,
                      ),
                      PrettyQr(
                        image:
                            const AssetImage('assets/images/LogoViolet1.png'),
                        size: 200,
                        data: widget.booking.id.toString(),
                        errorCorrectLevel: QrErrorCorrectLevel.M,
                        typeNumber: null,
                        roundEdges: true,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 65,
                      ),
                      const Center(
                        child: Text(
                          "Scan this QR-code at the designed socket",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 7,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 50,
                      ),
                      _isLoading
                          ? const CircularProgressIndicator(
                              color: Color.fromARGB(255, 194, 57, 235),
                            )
                          : deleteBookingButton(context)
                    ],
                  )
                ],
              ),
            )));
  }

  Widget deleteBookingButton(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              color: const Color.fromARGB(255, 194, 57, 235),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                _apiResponse = await _apiManager.deleteBooking(widget.booking);

                if ((_apiResponse.ApiError) == "") {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                } else {
                  // ignore: use_build_context_synchronously
                  showInSnackBar(context, _apiResponse.ApiError.toString());
                }
                setState(() {
                  _isLoading = false;
                });
              },
              child: const Text(
                "Delete booking",
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showInSnackBar(BuildContext context, String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> initSocket(Booking b) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String endUser = (prefs.getString('endUserUsername') ?? "");
    // ignore: use_build_context_synchronously
    final sharedData = Provider.of<SharedData>(context, listen: false);
    try {
      socket.connect();
      var toSend = jsonDecode(
          "{\"entity\":\"emsp\",\"target\":\"booking_check\", \"username\":\"$endUser\",\"booking_id\":\"${b.id}\"}");

      socket.emit('join', toSend);
      socket.on(
          'booking_check_outcome',
          (tmp) => {
                if (tmp == "true")
                  {
                    sharedData.enableCharge = true,
                    sharedData.setCsId = b.chargingStation.id,
                    sharedData.setBooking = b,
                    MaterialPageRoute(builder: (_) => const Charge()),
                    /*
                     Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Charge())),*/
                  }
                else
                  {
                    //print("false"),
                  }
              });
    } catch (e) {
      //print(e.toString());
    }
  }
}
