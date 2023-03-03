import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:regis_login/screen/home.dart';
import '../model/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatelessWidget {
  @override
  final formKey = GlobalKey<FormState>();
  Profile profile = Profile(email: '', password: '', name: '', lastname: '');
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Error"),
              ),
              body: Center(
                child: Text("${snapshot.error}"),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Register"),
              ),
              body: Container(
                child: Padding(
                  padding: const EdgeInsets.all(11.0),
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "E-mail",
                            style: TextStyle(fontSize: 20),
                          ),
                          TextFormField(
                            validator: MultiValidator([
                              RequiredValidator(
                                  errorText: "Please input E-mail"),
                              EmailValidator(errorText: "E-mail not match"),
                            ]),
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (String? email) {
                              profile.email = email!;
                            },
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Password",
                            style: TextStyle(fontSize: 20),
                          ),
                          TextFormField(
                            validator: RequiredValidator(
                                errorText: "Please input Password"),
                            obscureText: true,
                            onSaved: (String? password) {
                              profile.password = password!;
                            },
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Firstname",
                            style: TextStyle(fontSize: 20),
                          ),
                          TextFormField(
                            validator: RequiredValidator(
                                errorText: "Please input Firstname"),
                            onSaved: (String? Firstname) {
                              profile.name = Firstname!;
                            },
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Lastname",
                            style: TextStyle(fontSize: 20),
                          ),
                          TextFormField(
                            validator: RequiredValidator(
                                errorText: "Please input Lastname"),
                            onSaved: (String? lastname) {
                              profile.lastname = lastname!;
                            },
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              child: Text(
                                "Register",
                                style: TextStyle(fontSize: 20),
                              ),
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState?.save();
                                  try {
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: profile.email,
                                            password: profile.password)
                                        .then((value) => {
                                              formKey.currentState?.reset(),
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Create account complete",
                                                  gravity: ToastGravity.TOP),
                                              Navigator.pushReplacement(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return HomeScreen();
                                              }))
                                            });
                                  } on FirebaseAuthException catch (e) {
                                    print(e.code);
                                    String message;
                                    if (e.code == 'email-already-in-use') {
                                      message =
                                          'E-mail to use in system , please create new E-mail.';
                                    } else if (e.code == 'weak-password') {
                                      message =
                                          'Password must be 6 or more characters long.';
                                    } else {
                                      message = '${e.message}';
                                    }

                                    Fluttertoast.showToast(
                                        msg: "${e.message}",
                                        gravity: ToastGravity.TOP);
                                  }
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}
