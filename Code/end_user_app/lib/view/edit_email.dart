import 'package:end_user_app/model/end_user.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:end_user_app/controller/api_manager.dart';
import 'package:end_user_app/controller/api_response.dart';

// This class handles the Page to edit the Email Section of the User Profile.
class EditEmailFormPage extends StatefulWidget {
  const EditEmailFormPage({Key? key, required this.endUser}) : super(key: key);
  final EndUser endUser;
  @override
  EditEmailFormPageState createState() {
    return EditEmailFormPageState();
  }
}

class EditEmailFormPageState extends State<EditEmailFormPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool isLoading = false;
  ApiResponse apiResponse = ApiResponse();
  final ApiManager apiManager = ApiManager();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void updateUserValue(String email) {
    widget.endUser.email = email;
  }

  AppBar appBarEditEmail(BuildContext context) {
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
        appBar: appBarEditEmail(context),
        body: Form(
          key: formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: TextFormField(
                          // Handles Form Validation
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email.';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Your email address'),
                          controller: emailController,
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
                                    if (formKey.currentState!.validate() &&
                                        EmailValidator.validate(
                                            emailController.text)) {
                                      updateUserValue(emailController.text);
                                      setState(() {
                                        isLoading = true;
                                      });
                                      apiResponse = await apiManager
                                          .updateEmail(widget.endUser);

                                      if ((apiResponse.ApiError) == "") {
                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);
                                      } else {
                                        showInSnackBar(
                                            apiResponse.ApiError.toString());
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
        ));
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
