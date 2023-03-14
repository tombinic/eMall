import 'dart:convert';
import 'package:end_user_app/controller/notify.dart';
import 'package:end_user_app/controller/shared_data.dart';
import 'package:end_user_app/controller/socket_singleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Charge extends StatefulWidget {
  const Charge({super.key});

  @override
  State<Charge> createState() => _ChargeState();
}

class _ChargeState extends State<Charge> {
  final socket = SocketSingleton().socket;
  late SharedData sharedData;
  double batteryLevel = 0;
  bool btnStopCharge = false;

  @override
  void initState() {
    super.initState();
    sharedData = Provider.of<SharedData>(context, listen: false);
    batteryLevel = sharedData.getLevelOfCharge;
    if (batteryLevel > 0) {
      btnStopCharge = sharedData.enabledCharge;
    }
    setState(() {
      batteryLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: appBarCharge(context),
            body: Center(
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 20,
                  ),
                  sharedData.enabledCharge
                      ? Center(
                          child: Text(
                            "Charging Station ${sharedData.getBooking.chargingStation.name}",
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        )
                      : const Center(
                          child: Text(
                            "Scan your booking!",
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 194, 57, 235)),
                          ),
                        ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 65,
                  ),
                  sharedData.enabledCharge
                      ? Center(
                          child: Text(
                            sharedData.getBooking.chargingStation.address,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        )
                      : const Text(""),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 65,
                  ),
                  sharedData.enabledCharge
                      ? Center(
                          child: Text(
                            "@Charging socket n°${sharedData.getBooking.chargingSocketId}",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : const Text(""),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 10,
                  ),
                  Center(
                    child: CircularPercentIndicator(
                      radius: 110.0,
                      lineWidth: 30.0,
                      percent: sharedData.enabledCharge ? batteryLevel : 0,
                      animation: sharedData.enabledCharge ? true : false,
                      animationDuration:
                          sharedData.enabledCharge ? batteryLevel.round() : 0,
                      center: Icon(
                        Icons.bolt,
                        size: 150.0,
                        color: sharedData.enabledCharge
                            ? const Color.fromARGB(255, 237, 202, 3)
                            : const Color.fromARGB(255, 153, 130, 160),
                      ),
                      backgroundColor: Colors.grey,
                      linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          stops: const [
                            0.0,
                            0.33,
                            0.66,
                            1.0
                          ],
                          colors: [
                            sharedData.enabledCharge
                                ? const Color.fromARGB(255, 105, 43, 123)
                                : const Color.fromARGB(255, 153, 130, 160),
                            sharedData.enabledCharge
                                ? const Color.fromARGB(255, 116, 36, 140)
                                : const Color.fromARGB(255, 153, 130, 160),
                            sharedData.enabledCharge
                                ? const Color.fromARGB(255, 194, 57, 235)
                                : const Color.fromARGB(255, 153, 130, 160),
                            sharedData.enabledCharge
                                ? const Color.fromARGB(255, 194, 57, 235)
                                : const Color.fromARGB(255, 153, 130, 160)
                          ]),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 20,
                  ),
                  !btnStopCharge
                      ? CupertinoPageScaffold(
                          backgroundColor: Colors.white,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CupertinoButton(
                                  disabledColor:
                                      const Color.fromARGB(255, 153, 130, 160),
                                  color:
                                      const Color.fromARGB(255, 194, 57, 235),
                                  onPressed: sharedData.enabledCharge
                                      ? initSocket
                                      : null,
                                  child: const Text(
                                    "Start charging",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : CupertinoPageScaffold(
                          backgroundColor: Colors.white,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CupertinoButton(
                                  disabledColor:
                                      const Color.fromARGB(255, 153, 130, 160),
                                  color:
                                      const Color.fromARGB(255, 194, 57, 235),
                                  onPressed: sharedData.enabledCharge
                                      ? leaveSocket
                                      : null,
                                  child: const Text(
                                    "Stop charging",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              )),
            )));
  }

  AppBar appBarCharge(BuildContext context) {
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
          Text("Charge Status"),
        ],
      ),
      elevation: 0,
      titleTextStyle: const TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
    );
  }

  @override
  void dispose() {
    super.dispose();
    sharedData.setLevelOfCharge = batteryLevel;
  }

  Future<void> leaveSocket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String endUser = (prefs.getString('endUserUsername') ?? "");
    var toSend = jsonDecode(
        "{\"entity\":\"emsp\",\"target\":\"battery_status\",  \"sock_num\":${sharedData.getBooking.chargingSocketId},\"station_id\":${sharedData.csId}, \"username\":\"$endUser\"}");

    if (mounted) {
      batteryLevel = 0;
      setState(() {
        batteryLevel;
        sharedData.enableCharge = false;
        btnStopCharge = false;
      });
    }

    if (!sharedData.enabledCharge) {
      if (sharedData.csId != -1 /*&& sharedData.enabledCharge*/) {
        socket.emit('leave', toSend);
        if (mounted) {
          setState(() {
            batteryLevel = 0;
          });
        }
      }
    }
  }

  Future<void> initSocket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String endUser = (prefs.getString('endUserUsername') ?? "");
    try {
      var toSend = jsonDecode(
          "{\"entity\":\"emsp\",\"target\":\"battery_status\",  \"sock_num\":${sharedData.getBooking.chargingSocketId}, \"battery\":$batteryLevel,\"station_id\":${sharedData.csId}, \"username\":\"$endUser\"}");
      socket.emit('join', toSend);
      // ignore: avoid_print
      socket.on('booking_check_outcome', (json) => print(json));
      socket.on(
          'battery_update',
          (data) => {
                batteryLevel += 0.01,
                sharedData.setLevelOfCharge = batteryLevel,
                if (mounted)
                  {
                    setState(() {
                      if (batteryLevel <= 1) {
                        batteryLevel;
                        btnStopCharge = true;
                      } else {
                        sharedData.enableCharge = false;
                        btnStopCharge = false;
                      }
                    }),
                  },
                if (!sharedData.enabledCharge)
                  {
                    if (sharedData.csId != -1 /*&& sharedData.enabledCharge*/)
                      {
                        //print("LEAVE"),
                        socket.emit('leave', toSend),
                        if (mounted)
                          {
                            sharedData.setLevelOfCharge = 0,
                            setState(() {
                              batteryLevel = 0;
                            })
                          },
                        Notify.instantNotify(endUser),
                      }
                  },
              });
      // ignore: empty_catches
    } catch (e) {}
  }
}
