import 'package:end_user_app/view/booking_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/booking.dart';

class BookingResult extends StatefulWidget {
  const BookingResult(
      {super.key,
      required this.booking,
      required this.bookingState,
      this.errorMessage});

  final Booking booking;
  final String bookingState;
  final String? errorMessage;

  @override
  State<BookingResult> createState() => _BookingResultState();
}

class _BookingResultState extends State<BookingResult> {
  AppBar appBarBookingDetail(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: widget.bookingState == "Success"
          ? Text("Booking n° ${widget.booking.id}")
          : const Text("We are sorry"),
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
  void dispose() {
    super.dispose();
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
                          child: widget.bookingState == "Success"
                              ? Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Amazing ${widget.booking.euUsername}, your booking has confirmed!",
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Oh no ${widget.booking.euUsername}, ${widget.errorMessage!}",
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 65,
                      ),
                      Center(
                          child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Charging station ${widget.booking.chargingStation.name} - ${widget.booking.chargingStation.address}",
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 5,
                      ),
                      Container(
                        height: 160.0,
                        width: 160.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: widget.bookingState == "Success"
                                ? const AssetImage('assets/images/verified.png')
                                : const AssetImage('assets/images/cancel.png'),
                            fit: BoxFit.fill,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 10,
                      ),
                      if (widget.bookingState == "Success")
                        bookingsButton(context)
                    ],
                  )
                ],
              ),
            )));
  }

  Widget bookingsButton(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              color: const Color.fromARGB(255, 194, 57, 235),
              onPressed: _handleToBookings,
              child: const Text(
                "Your bookings",
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleToBookings() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return BookingDetail(booking: widget.booking);
    }));
  }
}
