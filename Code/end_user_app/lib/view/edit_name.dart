import 'package:end_user_app/model/end_user.dart';
import 'package:end_user_app/controller/api_manager.dart';
import 'package:end_user_app/controller/api_response.dart';
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';

// This class handles the Page to edit the Name Section of the User Profile.
class EditNameFormPage extends StatefulWidget {
  const EditNameFormPage({Key? key, required this.endUser}) : super(key: key);
  final EndUser endUser;

  @override
  EditNameFormPageState createState() {
    return EditNameFormPageState();
  }
}

class EditNameFormPageState extends State<EditNameFormPage> {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final secondNameController = TextEditingController();
  bool isLoading = false;
  ApiResponse apiResponse = ApiResponse();
  final ApiManager apiManager = ApiManager();

  @override
  void dispose() {
    firstNameController.dispose();
    secondNameController.dispose();
    super.dispose();
  }

  void updateUserValue(String value) {
    var values = value.split("/");
    widget.endUser.name = values[0];
    widget.endUser.surname = values[1];
  }

  AppBar appBarEditName(BuildContext context) {
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

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarEditName(context),
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              } else if (!isAlpha(value)) {
                                return 'Only Letters Please';
                              }
                              return null;
                            },
                            decoration:
                                const InputDecoration(labelText: 'First Name'),
                            controller: firstNameController,
                          ))),
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Align(
                          child: SizedBox(
                              height: 100,
                              width: MediaQuery.of(context).size.width / 1.2,
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your surname';
                                  } else if (!isAlpha(value)) {
                                    return 'Only Letters Please';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    labelText: 'Last Name'),
                                controller: secondNameController,
                              )))),
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
                                        isAlpha(firstNameController.text +
                                            secondNameController.text)) {
                                      updateUserValue(
                                          "${firstNameController.text}/${secondNameController.text}");
                                      setState(() {
                                        isLoading = true;
                                      });
                                      apiResponse = await apiManager
                                          .updateNameSurname(widget.endUser);

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
                        )),
                  )
                ]),
          )),
    );
  }
}
