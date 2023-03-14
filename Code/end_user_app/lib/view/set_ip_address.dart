import 'package:end_user_app/config/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerIp extends StatefulWidget {
  const ServerIp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ServerIpState createState() => _ServerIpState();
}

class _ServerIpState extends State<ServerIp> {
  final addressTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String errorText = "";
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 50.0, horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Set IP addresses of the application server",
                        style: TextStyle(fontSize: 20),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: TextFormField(
                            controller: addressTextController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the IP address.';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                hintText: 'Enter the server address')),
                      ),
                      setIp(context),
                      if (error) Text(errorText),
                    ],
                  ),
                ))));
  }

  void submit() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      Config().baseUrl = "http://${addressTextController.text}:5000/api";
      Config().baseUrlWebSocket = "http://${addressTextController.text}:5000";
      saveIp();
      Navigator.pop(context);
    }
  }

  Future<void> saveIp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        "baseUrl", "http://${addressTextController.text}:5000/api");
    await prefs.setString(
        "baseUrlWebSocket", "http://${addressTextController.text}:5000");
  }

  Widget setIp(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              color: const Color.fromARGB(255, 194, 57, 235),
              onPressed: submit,
              child: const Text(
                "Login",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
