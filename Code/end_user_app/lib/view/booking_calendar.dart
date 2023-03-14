import 'package:end_user_app/view/booking_result.dart';
import 'package:end_user_app/model/booking.dart';
import 'package:end_user_app/model/charging_socket.dart';
import 'package:end_user_app/model/charging_station.dart';
import 'package:end_user_app/controller/api_manager.dart';
import 'package:end_user_app/controller/api_response.dart';
import 'package:flutter/material.dart';
import 'package:booking_calendar/booking_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingCalendarDemoApp extends StatefulWidget {
  const BookingCalendarDemoApp(
      {Key? key,
      required this.chargingStation,
      required this.csType,
      required this.reCall})
      : super(key: key);
  final ChargingStation chargingStation;
  final ChargingSocket csType;
  final bool reCall;

  @override
  State<BookingCalendarDemoApp> createState() => _BookingCalendarDemoAppState();
}

class _BookingCalendarDemoAppState extends State<BookingCalendarDemoApp> {
  final now = DateTime.now();
  late BookingService mockBookingService;
  final List<String> list = <String>['Fast', 'Slow', 'Rapid'];
  late String selectedValue;
  ApiResponse _apiResponse = ApiResponse();
  final ApiManager _apiManager = ApiManager();
  ApiResponse _apiResponseSocket = ApiResponse();
  final ApiManager _apiManagerSocket = ApiManager();
  Future<List<Booking>>? futureB;
  Future<List<ChargingSocket>>? futureChargingSocket;
  late ChargingSocket selectedCharginsSocket = widget.csType;
  late List<Booking> b;
  late List<ChargingSocket> cs;

  @override
  void initState() {
    super.initState();
    if (widget.reCall) {
      selectedCharginsSocket = widget.csType;
    }
    cs = [];
    b = [];
    futureChargingSocket = getChargingSocketPrice();
    futureB = getBusyBooking();

    mockBookingService = BookingService(
        serviceName: 'Mock Service',
        serviceDuration: 60,
        bookingStart: DateTime(now.year, now.month, now.day, 0, 0),
        bookingEnd: DateTime(now.year, now.month, now.day, 24, 0));
  }

  Stream<dynamic>? getBookingStreamMock(
      {required DateTime end, required DateTime start}) {
    return Stream.value([]);
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  List<DateTimeRange> generatePauseSlots() {
    DateTime dt = DateTime(now.year, now.month, now.day, now.hour);

    int currentHour = dt.hour + 1;

    return [
      DateTimeRange(
          start: DateTime(now.year, now.month, now.day, 0, 0),
          end: DateTime(now.year, now.month, now.day, currentHour, 0))
    ];
  }

  Future<dynamic> uploadBookingMock(
      {required BookingService newBooking}) async {
    DateTime date =
        DateTime.parse(newBooking.bookingStart.toIso8601String().split("T")[0]);
    TimeOfDay start = TimeOfDay.fromDateTime(newBooking.bookingStart);
    TimeOfDay end = TimeOfDay.fromDateTime(newBooking.bookingEnd);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String endUser = (prefs.getString('endUserUsername') ?? "");
    _apiResponse = await _apiManager.newBooking(Booking(
        0,
        date,
        start,
        end,
        endUser,
        selectedCharginsSocket.type,
        ChargingStation(widget.chargingStation.id, widget.chargingStation.name,
            widget.chargingStation.address)));

    if (_apiResponse.ApiError == "") {
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return BookingResult(
          booking: _apiResponse.Data as Booking,
          bookingState: 'Success',
        );
      }));
    } else {
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return BookingResult(
          booking: _apiResponse.Data as Booking,
          bookingState: 'Error',
          errorMessage: _apiResponse.ApiError,
        );
      }));
    }
    _apiResponse = await _apiManager.getBusyBooking(
        widget.chargingStation.id, selectedCharginsSocket.type);

    _apiResponseSocket = await _apiManagerSocket
        .getSocketPrice(ChargingStation.fromId(widget.chargingStation.id));
  }

  List<DateTimeRange> converted = [];

  List<DateTimeRange> convertStreamResultMock({required dynamic streamResult}) {
    converted = [];
    b = [];
    for (final b in _apiResponse.Data as List<Booking>) {
      String date = b.date!.toIso8601String().split("T")[0];
      String first = "";
      String last = "";
      if (b.start.hour >= 0 && b.start.hour < 9) {
        first = "${date}T0${b.start.hour}:00:00.000";
      } else {
        first = "${date}T${b.start.hour}:00:00.000";
      }
      if (b.end.hour >= 0 && b.end.hour < 9) {
        last = "${date}T0${b.end.hour}:00:00.000";
      } else {
        last = "${date}T${b.end.hour}:00:00.000";
      }

      DateTime start = DateTime.parse(first);
      DateTime end = DateTime.parse(last);

      if (start.hour == 23 && end.hour == 0) {
        end = end.add(const Duration(days: 1));
      }
      converted.add(DateTimeRange(start: start, end: end));
    }
    return converted;
  }

  Future<List<Booking>> getBusyBooking() async {
    _apiResponse = await _apiManager.getBusyBooking(
        widget.chargingStation.id, selectedCharginsSocket.type);
    if ((_apiResponse.ApiError) == "") {
      b = (_apiResponse.Data as List<Booking>).toList();
    } else {
      showInSnackBar(_apiResponse.ApiError.toString());
    }

    return b;
  }

  Future<List<ChargingSocket>> getChargingSocketPrice() async {
    _apiResponseSocket = await _apiManagerSocket
        .getSocketPrice(ChargingStation.fromId(widget.chargingStation.id));
    if ((_apiResponseSocket.ApiError) == "") {
      cs = (_apiResponseSocket.Data as List<ChargingSocket>).toList();
      if (!widget.reCall) {
        selectedCharginsSocket = cs[0];
      }
    } else {
      showInSnackBar(_apiResponseSocket.ApiError.toString());
    }
    return cs;
  }

  AppBar appBarBooking(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(widget.chargingStation.name),
        actions: [
          FutureBuilder<List<ChargingSocket>>(
            future: futureChargingSocket,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return DropdownButton<ChargingSocket>(
                  value: selectedCharginsSocket,
                  icon: const Icon(Icons.arrow_drop_down_sharp),
                  elevation: 16,
                  underline: Container(
                    height: 2,
                    color: const Color.fromARGB(255, 194, 57, 235),
                  ),
                  onChanged: (ChargingSocket? value) {
                    setState(() {
                      selectedCharginsSocket = value!;
                    });
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            BookingCalendarDemoApp(
                          chargingStation: widget.chargingStation,
                          csType: selectedCharginsSocket,
                          reCall: true,
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  items: cs.map<DropdownMenuItem<ChargingSocket>>(
                      (ChargingSocket value) {
                    return DropdownMenuItem<ChargingSocket>(
                      value: value,
                      child:
                          Text("${value.type.split(" ")[0]} - ${value.price}€"),
                    );
                  }).toList(),
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return const Text("");
            },
          )
        ],
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
                })));
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    initializeDateFormatting('it');

    return Scaffold(
      appBar: appBarBooking(context),
      body: Center(
          child: FutureBuilder<List<Booking>>(
        future: futureB,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return BookingCalendar(
              selectedSlotColor: const Color.fromARGB(255, 194, 57, 235),
              bookingService: mockBookingService,
              convertStreamResultToDateTimeRanges: convertStreamResultMock,
              getBookingStream: getBookingStreamMock,
              uploadBooking: uploadBookingMock,
              pauseSlots: generatePauseSlots(),
              pauseSlotColor: const Color.fromARGB(255, 100, 96, 101),
              pauseSlotText: "N.A.",
              bookingButtonColor: const Color.fromARGB(255, 194, 57, 235),
              bookingButtonText: "Book a charge",
              hideBreakTime: false,
              loadingWidget: const Text('Fetching data...'),
              uploadingWidget: const CircularProgressIndicator(
                color: Color.fromARGB(255, 194, 57, 235),
              ),
              locale: 'it_IT',
              startingDayOfWeek: StartingDayOfWeek.sunday,
            );
          }
          return const CircularProgressIndicator(
            color: Color.fromARGB(255, 194, 57, 235),
          );
        },
      )),
    );
  }
}
