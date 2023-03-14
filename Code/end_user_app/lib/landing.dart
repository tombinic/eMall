import 'package:end_user_app/view/home.dart';
import 'package:end_user_app/view/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  String userId = "";

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = (prefs.getString('endUserUsername') ?? "");
    if (userId == "") {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomePage(
                    title: 'eMall',
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
