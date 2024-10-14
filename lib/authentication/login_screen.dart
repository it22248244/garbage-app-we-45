import 'package:drivers_app/authentication/signup_screen.dart';
import 'package:drivers_app/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);
    signInFormValidation();
  }

  signInFormValidation() {
    if (!emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("Please write a valid email.", context);
    } else if (passwordTextEditingController.text.trim().length < 6) {
      cMethods.displaySnackBar("Your password must be at least 6 or more characters.", context);
    } else {
      signInUser();
    }
  }

  signInUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Loading Your Account..."),
    );

    final User? userFirebase = (
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).catchError((errorMsg) {
          Navigator.pop(context);
          cMethods.displaySnackBar(errorMsg.toString(), context);
        })
    ).user;

    if (!context.mounted) return;
    Navigator.pop(context);

    if (userFirebase != null) {
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("admin").child(userFirebase.uid);
      usersRef.once().then((snap) {
        if (snap.snapshot.value != null) {
          if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
            String userName = (snap.snapshot.value as Map)["name"]; // Extract the userName
            String userId = userFirebase.uid; // Extract the userId
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => Dashboard(userName: userName, userId: userId), // Pass both userName and userId to Dashboard
              ),
            );
          } else {
            FirebaseAuth.instance.signOut();
            cMethods.displaySnackBar("You are blocked. Contact admin.", context);
          }
        } else {
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackBar("Your record does not exist as a user.", context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center( // Center widget to center the card
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Card(
              color: Colors.white, // Set card color to white
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(40), // Padding inside the card
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                      child: Image.asset(
                        "assets/images/logoGarbage.jpeg",
                        width: 220,
                        fit: BoxFit.cover, // Adjust the fit as needed
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      "Login as an Admin",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff149777), // Set color to grey
                      ),
                    ),
                    // Text fields + buttons
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          TextField(
                            controller: emailTextEditingController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: "Your Email",
                              labelStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey, // Set label color to grey
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.grey, // Text color in the field
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 22),
                          TextField(
                            controller: passwordTextEditingController,
                            obscureText: true,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              labelText: "Your Password",
                              labelStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey, // Set label color to grey
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.grey, // Text color in the field
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () {
                              checkIfNetworkIsAvailable();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff149777),
                              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                            ),
                            child: const Text("Login", style: TextStyle(color: Colors.white)), // Set button text color to white
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // TextButton
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => SignupScreen()));
                      },
                      child: const Text(
                        "Don't have an account? Register Here",
                        style: TextStyle(
                          color: Colors.blue, // Set color to blue
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
