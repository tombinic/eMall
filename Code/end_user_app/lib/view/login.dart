import 'package:end_user_app/config/config.dart';
import 'package:end_user_app/model/end_user.dart';
import 'package:end_user_app/controller/api_response.dart';
import 'package:end_user_app/view/home.dart';
import 'package:end_user_app/view/set_ip_address.dart';
import 'package:end_user_app/view/sign_up.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:end_user_app/controller/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _key = GlobalKey();
  final bool validate = false;
  String usernameTyped = "";
  String passwordTyped = "";
  bool obscureText = true;
  String baseUrl = "";
  String baseUrlWebSocket = "";

  @override
  void initState() {
    super.initState();
    _initProperties();
  }

  Future<void> _initProperties() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    baseUrl = (prefs.getString('baseUrl') ?? "");
    baseUrlWebSocket = (prefs.getString('baseUrlWebSocket') ?? "");

    if (baseUrl == "" && baseUrlWebSocket == "") {
      // ignore: use_build_context_synchronously
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const ServerIp()));
    } else {
      Config().baseUrl = (prefs.getString('baseUrl'))!;
      Config().baseUrlWebSocket = (prefs.getString('baseUrlWebSocket'))!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20.0),
            child: Center(
              child: Form(
                key: _key,
                autovalidateMode: AutovalidateMode.always,
                child: _getFormUI(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getFormUI() {
    return Column(
      children: <Widget>[
        const ImageIcon(
          AssetImage("assets/images/logo_login.png"),
          color: Color.fromARGB(255, 194, 57, 235),
          size: 170,
        ),
        const SizedBox(height: 50.0),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Username',
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ),
          validator: validateUsername,
          onSaved: (String? value) {
            setState(() {
              usernameTyped = value!;
            });
          },
        ),
        const SizedBox(height: 20.0),
        TextFormField(
            autofocus: false,
            obscureText: obscureText,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Password',
              contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
                child: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  semanticLabel:
                      obscureText ? 'show password' : 'hide password',
                ),
              ),
            ),
            onSaved: (String? value) {
              passwordTyped = value!;
            }),
        const SizedBox(height: 15.0),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: loginButton(context),
        ),
        TextButton(
          onPressed: _sendToRegisterPage,
          child: const Text('Not a member? Sign up now',
              style: TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }

  Widget loginButton(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              color: const Color.fromARGB(255, 194, 57, 235),
              onPressed: handleSubmitted,
              child: const Text(
                "Login",
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleSubmitted() async {
    ApiResponse apiResponse = ApiResponse();
    final ApiManager apiManager = ApiManager();
    if (!_key.currentState!.validate()) {
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      _key.currentState!.save();

      apiResponse =
          await apiManager.authenticateUser(usernameTyped, passwordTyped);

      if ((apiResponse.ApiError) == "") {
        _saveAndRedirectToHome(apiResponse);
      } else {
        showInSnackBar(apiResponse.ApiError.toString());
      }
    }
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void _saveAndRedirectToHome(ApiResponse apiResponse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        "endUserUsername", (apiResponse.Data as EndUser).username);
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const HomePage(
                  title: 'eMall',
                )));
  }

  void _sendToRegisterPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const SignUpPage()));
  }

  String? validateUsername(String? value) {
    if (value!.isEmpty) {
      return "Username is Required";
    }
    return null;
  }
}
