import 'package:end_user_app/view/Login.dart';
import 'package:end_user_app/view/edit_email.dart';
import 'package:end_user_app/view/edit_name.dart';
import 'package:end_user_app/view/credit_card.dart';
import 'package:end_user_app/view/edit_password.dart';
import 'package:end_user_app/model/end_user.dart';
import 'package:end_user_app/model/payment_method.dart';
import 'package:end_user_app/controller/api_manager.dart';
import 'package:end_user_app/controller/api_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late EndUser _endUser;
  Future<EndUser>? _futureEndUser;
  ApiResponse _apiResponse = ApiResponse();
  final ApiManager _apiManager = ApiManager();

  @override
  void initState() {
    super.initState();
    _futureEndUser = _getUserInfo();
  }

  Future<EndUser> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String endUserUsername = (prefs.getString('endUserUsername') ?? "");

    _apiResponse =
        await _apiManager.userDetails(EndUser.fromUsername(endUserUsername));

    if ((_apiResponse.ApiError) == "") {
      _endUser = _apiResponse.Data as EndUser;
    } else {
      showInSnackBar(_apiResponse.ApiError.toString());
    }
    return _endUser;
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      theme: ThemeData(
          backgroundColor: Colors.white,
          primaryColor: const Color.fromARGB(255, 194, 57, 235),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 194, 57, 235),
                  shadowColor: const Color.fromARGB(255, 194, 57, 235),
                  elevation: 20,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0.0))))),
          inputDecorationTheme: InputDecorationTheme(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(0.0))),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              foregroundColor: Colors.black,
            ),
          )),
      home: profilePage(),
    );
  }

  Widget profilePage() {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: FutureBuilder<EndUser>(
                future: _futureEndUser,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          AppBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            toolbarHeight: 50,
                          ),
                          InkWell(
                              onTap: () {},
                              child: const CircleAvatar(
                                radius: 50,
                                //backgroundColor: color,
                                child: CircleAvatar(
                                  backgroundImage:
                                      AssetImage("assets/images/team.png"),
                                  backgroundColor: Colors.white,
                                  radius: 70,
                                ),
                              )),
                          Center(
                            child: Text(
                              "@${_endUser.username}",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 20,
                          ),
                          buildUserInfoDisplay(
                              "${_endUser.name} ${_endUser.surname}",
                              EditNameFormPage(endUser: _endUser)),
                          buildUserInfoDisplay(_endUser.email,
                              EditEmailFormPage(endUser: _endUser)),
                          buildUserInfoDisplay(
                              "*****", EditPasswordFormPage(endUser: _endUser)),
                          SizedBox(
                            height: 140,
                            child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.all(12),
                                itemBuilder: (context, index) {
                                  if (index == _endUser.creditCards.length) {
                                    return addCreditCard();
                                  }
                                  return buildCreditCard(
                                      _endUser.creditCards[index]);
                                },
                                separatorBuilder: (context, index) {
                                  return const SizedBox(width: 12);
                                },
                                itemCount: (_endUser.creditCards.length + 1)),
                          ),
                          saveChanges(context),
                        ],
                      ),
                    );
                  }
                  return const CircularProgressIndicator(
                    color: Color.fromARGB(255, 194, 57, 235),
                  );
                },
              ),
            )));
  }

  Widget addCreditCard() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/add.png"),
                  fit: BoxFit.scaleDown),
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              color: Color.fromARGB(255, 255, 255, 255)),
          child: SizedBox(
            height: 50,
            width: 50,
            child: ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CreditCard(
                    endUser: _endUser,
                  );
                })).then(onGoBack1);
              },
              contentPadding: const EdgeInsets.all(5),
              dense: true,
            ),
          )),
    );
  }

  Widget buildCreditCard(PaymentMethod pm) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/credit-card.png"),
                  fit: BoxFit.fill),
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              color: Color.fromARGB(255, 255, 255, 255)),
          child: SizedBox(
            height: 50,
            width: 100,
            child: ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CreditCard(
                    paymentMethod: pm,
                    endUser: _endUser,
                  );
                })).then(onGoBack1);
              },
              contentPadding: const EdgeInsets.all(5),
              dense: true,
            ),
          )),
    );
  }

  Widget buildUserInfoDisplay(String getValue, Widget editPage) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "",
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: 1,
          ),
          Container(
              width: MediaQuery.of(context).size.width / 1.2,
              height: 40,
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                color: Color.fromARGB(255, 194, 57, 235),
                width: 1,
              ))),
              child: Row(children: [
                Expanded(
                    child: TextButton(
                        onPressed: () {
                          navigateSecondPage(editPage);
                        },
                        child: Text(
                          getValue,
                          style: const TextStyle(fontSize: 16, height: 1.4),
                        ))),
                const Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.grey,
                  size: 40.0,
                ),
              ]))
        ],
      ));

  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  FutureOr onGoBack1(dynamic value) {
    setState(() {});
    _futureEndUser = _getUserInfo();
  }

  Widget saveChanges(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              color: const Color.fromARGB(255, 194, 57, 235),
              onPressed: handleLogout,
              child: const Text(
                "Logout",
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('endUserUsername');
    prefs.remove('baseUrl');
    prefs.remove('baseUrlWebSocket');
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void navigateSecondPage(Widget editForm) {
    Route route = MaterialPageRoute(builder: (context) => editForm);
    Navigator.push(context, route).then(onGoBack);
  }
}
