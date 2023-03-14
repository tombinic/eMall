import 'package:end_user_app/view/booking_calendar.dart';
import 'package:end_user_app/model/charging_socket.dart';
import 'package:end_user_app/model/charging_station.dart';
import 'package:end_user_app/controller/api_response.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:end_user_app/controller/api_manager.dart';
import 'package:geolocator/geolocator.dart';

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  late List<ChargingStation> cs;
  Future<List<ChargingStation>>? futureCs;
  ApiResponse apiResponse = ApiResponse();
  final ApiManager apiManager = ApiManager();
  final Map<String, Marker> markers = {};
  late BitmapDescriptor myIcon;
  bool serviceEnabled = false;
  LatLng currentPosition = const LatLng(0, 0);
  BorderRadiusGeometry radius = const BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  @override
  void initState() {
    super.initState();
    cs = [];
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(devicePixelRatio: 2.5),
            'assets/images/charging-station.png')
        .then((onValue) {
      myIcon = onValue;
    });
    futureCs = _getNearbyChargingStations();
  }

  Future<void> _checkUserPermission() async {
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  Future<void> _getUserLocation() async {
    var position = await GeolocatorPlatform.instance.getCurrentPosition();

    currentPosition = LatLng(position.latitude, position.longitude);
  }

  Future<List<ChargingStation>> _getNearbyChargingStations() async {
    await _checkUserPermission();
    await _getUserLocation();
    apiResponse = await apiManager.getNearbyChargingStation(
        currentPosition.latitude, currentPosition.longitude);

    if ((apiResponse.ApiError) == "") {
      cs = (apiResponse.Data as List<ChargingStation>).toList();
    } else {
      showInSnackBar(apiResponse.ApiError.toString());
    }
    return cs;
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Widget buildCs(ChargingStation cs) {
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
              return BookingCalendarDemoApp(
                chargingStation: cs,
                csType: ChargingSocket.fromTypePrice("Fast charge", 0.0),
                reCall: false,
              );
            }));
          },
          contentPadding: const EdgeInsets.all(5),
          dense: true,
          title: Text(
            "Charging station ${cs.name}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            "${cs.address}\n${cs.status}",
            style: const TextStyle(fontSize: 10),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_outlined),
          iconColor: const Color.fromARGB(255, 194, 57, 235),
        ),
      ),
    );
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
      markers.clear();
      for (final cs in apiResponse.Data as List<ChargingStation>) {
        final marker = Marker(
          icon: myIcon,
          markerId: MarkerId(cs.id.toString()),
          position: LatLng(double.parse(cs.lat), double.parse(cs.long)),
          infoWindow: InfoWindow(
            title: cs.name,
            snippet: cs.address,
          ),
          onTap: () => {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return BookingCalendarDemoApp(
                chargingStation: cs,
                csType: ChargingSocket.fromTypePrice("Fast charge", 0.0),
                reCall: false,
              );
            }))
          },
        );
        markers[cs.id.toString()] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            body: Center(
          child: FutureBuilder<List<ChargingStation>>(
              future: futureCs,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SlidingUpPanel(
                    maxHeight: MediaQuery.of(context).size.height * .70,
                    minHeight: 40.0,
                    panel: Center(
                      child: ListView(
                        children: cs.map(buildCs).toList(),
                      ),
                    ),
                    collapsed: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 194, 57, 235),
                          borderRadius: radius),
                      child: const Center(
                        child: Text(
                          "Let's Charge!",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    borderRadius: radius,
                    body: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: currentPosition,
                        zoom: 13,
                      ),
                      zoomGesturesEnabled: true,
                      markers: markers.values.toSet(),
                      myLocationEnabled: true,
                    ),
                  );
                }
                return const CircularProgressIndicator(
                  color: Color.fromARGB(255, 194, 57, 235),
                );
              }),
        )));
  }
}
