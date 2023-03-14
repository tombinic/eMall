import 'package:end_user_app/controller/api_response.dart';
import 'package:end_user_app/view/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:end_user_app/controller/api_manager.dart';
import 'package:string_validator/string_validator.dart';
import 'package:email_validator/email_validator.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SignUpPageState();
  }
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _key = GlobalKey();
  final bool validate = false;
  String usernameTyped = "";
  String passwordTyped = "";
  String nameTyped = "";
  String surnameTyped = "";
  String emailTyped = "";
  bool obscureText = true;

  @override
  void initState() {
    super.initState();
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
        const SizedBox(height: 0.0),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Name',
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ),
          validator: validateName,
          onSaved: (String? value) {
            setState(() {
              nameTyped = value!;
            });
          },
        ),
        const SizedBox(height: 20.0),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Surname',
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ),
          validator: validateSurname,
          onSaved: (String? value) {
            setState(() {
              surnameTyped = value!;
            });
          },
        ),
        const SizedBox(height: 20.0),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Email',
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ),
          validator: validateEmail,
          onSaved: (String? value) {
            setState(() {
              emailTyped = value!;
            });
          },
        ),
        const SizedBox(height: 20.0),
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
            validator: validatePassword,
            onSaved: (String? value) {
              setState(() {
                passwordTyped = value!;
              });
            }),
        const SizedBox(height: 15.0),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: signUpButton(context),
        ),
        TextButton(
          onPressed: _sendToLogin,
          child: const Text('Already a member? Login now',
              style: TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }

  Widget signUpButton(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              color: const Color.fromARGB(255, 194, 57, 235),
              onPressed: handleSubmitted,
              child: const Text(
                "SignUp",
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleSubmitted() async {
    final ApiManager apiManager = ApiManager();
    ApiResponse apiResponse = ApiResponse();
    if (!_key.currentState!.validate()) {
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      _key.currentState!.save();

      apiResponse = await apiManager.registerUser(
          nameTyped, surnameTyped, emailTyped, usernameTyped, passwordTyped);

      if ((apiResponse.ApiError) == "") {
        redirectToLogin();
      } else {
        showInSnackBar((apiResponse.ApiError));
      }
    }
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void redirectToLogin() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void _sendToLogin() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  String? validatePassword(String? value) {
    String pattern = r'(^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,}$)';
    RegExp regExp = RegExp(pattern);
    if (value!.isEmpty) {
      return "Password is Required";
    } else if (value.length < 8) {
      return "Password must minimum eight characters";
    } else if (!regExp.hasMatch(value)) {
      return "Password at least one uppercase letter, one lowercase letter and one number";
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    } else if (!isAlpha(value)) {
      return 'Only Letters Please';
    }
    return null;
  }

  String? validateSurname(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your surname';
    } else if (!isAlpha(value)) {
      return 'Only Letters Please';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!EmailValidator.validate(value)) {
      return 'Only Valid Mail Please';
    }
    return null;
  }
}
