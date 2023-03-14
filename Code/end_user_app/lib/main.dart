import 'package:end_user_app/view/login.dart';
import 'package:end_user_app/view/sign_up.dart';
import 'package:end_user_app/controller/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:end_user_app/view/home.dart';
import 'package:material_color_generator/material_color_generator.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'landing.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() => {
      runApp(ChangeNotifierProvider(
        create: (_) => SharedData(),
        child: const App(),
      )),
      AwesomeNotifications().initialize('resource://mipmap/icon', [
        NotificationChannel(
            channelKey: "instant_notifications",
            channelName: "Basic Instant Notification",
            channelDescription: "Charge completed")
      ])
    };

class App extends StatefulWidget {
  const App({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eMall',
      routes: {
        '/': (context) => const Landing(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(title: 'eMall'),
        '/signup': (context) => const SignUpPage()
      },
      initialRoute: "/",
      theme: ThemeData(
        primarySwatch: generateMaterialColor(
            color: const Color.fromARGB(255, 194, 57, 235)),
      ),
    );
  }
}
