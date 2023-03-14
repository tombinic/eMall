import 'package:end_user_app/model/end_user.dart';
import 'package:end_user_app/controller/api_manager.dart';
import 'package:end_user_app/controller/api_response.dart';
import 'package:flutter/material.dart';

// This class handles the Page to edit the Email Section of the User Profile.
class EditPasswordFormPage extends StatefulWidget {
  const EditPasswordFormPage({Key? key, required this.endUser})
      : super(key: key);
  final EndUser endUser;
  @override
  EditPasswordFormPageState createState() {
    return EditPasswordFormPageState();
  }
}

class EditPasswordFormPageState extends State<EditPasswordFormPage> {
  final formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final oldPasswordController = TextEditingController();
  bool isLoading = false;
  ApiResponse apiResponse = ApiResponse();
  final ApiManager apiManager = ApiManager();

  @override
  void dispose() {
    newPasswordController.dispose();
    oldPasswordController.dispose();
    super.dispose();
  }

  AppBar appBarEditPassword(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(
          color: Colors
              .black), // set backbutton color here which will reflect in all screens.
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
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: appBarEditPassword(context),
        body: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: TextFormField(
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your old password.';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  labelText: 'Old password'),
                              controller: oldPasswordController,
                            ))),
                    Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: TextFormField(
                              obscureText: true,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !validatePassword(value)) {
                                  return 'Please enter a new valid password.';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  labelText: 'New password'),
                              controller: newPasswordController,
                            ))),
                    Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 1.2,
                              height: 50,
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Color.fromARGB(255, 194, 57, 235),
                                    )
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 194, 57, 235)),
                                      onPressed: () async {
                                        // Validate returns true if the form is valid, or false otherwise.
                                        if (formKey.currentState!.validate()) {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          apiResponse =
                                              await apiManager.updatePassword(
                                                  widget.endUser,
                                                  oldPasswordController.text,
                                                  newPasswordController.text);

                                          if ((apiResponse.ApiError) == "") {
                                            // ignore: use_build_context_synchronously
                                            Navigator.pop(context);
                                          } else {
                                            showInSnackBar(apiResponse.ApiError
                                                .toString());
                                          }
                                          setState(() {
                                            isLoading = false;
                                          });
                                        }
                                      },
                                      child: const Text(
                                        'Update',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                            )))
                  ]),
            )));
  }

  bool validatePassword(String value) {
    String pattern = r'(^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,}$)';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty || value.length < 8 || !regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
