import 'dart:io';
import 'package:drivers_app/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';

class HelpDesk extends StatefulWidget {
  const HelpDesk({super.key});

  @override
  State<HelpDesk> createState() => _HelpDeskState();
}

class _HelpDeskState extends State<HelpDesk> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController inquiresTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController(); // Ensure password field exists

  CommonMethods cMethods = CommonMethods();
  XFile? imageFile; // Ensure this variable is defined if needed

  void checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);
  }

  void signUpFormValidation() {
    if (userNameTextEditingController.text.trim().length < 4) {
      cMethods.displaySnackBar("Your name must be at least 4 or more characters.", context);
    } else if (userPhoneTextEditingController.text.trim().length < 10) {
      cMethods.displaySnackBar("Your phone number must be at least 10 digits.", context);
    } else if (!emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("Please write a valid email.", context);
    } else if (inquiresTextEditingController.text.isEmpty) {
      cMethods.displaySnackBar("Please enter an inquiry.", context);
    } else {
      sendInquires();
    }
  }

  Future<void> sendInquires() async {
    checkIfNetworkIsAvailable(); // Ensure network is available before sending
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Sending your inquiry..."),
    );

    try {
      // Create a unique reference for each inquiry
      DatabaseReference inquiriesRef = FirebaseDatabase.instance.ref().child("inquiries").push();

      Map<String, String> inquiriesDataMap = {
        "name": userNameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": userPhoneTextEditingController.text.trim(),
        "message": inquiresTextEditingController.text.trim(),
        "blockStatus": "no",
      };

      // Save user data to the database
      await inquiriesRef.set(inquiriesDataMap); // Use push() reference for unique entry
      Navigator.pop(context);
      cMethods.displaySnackBar("Inquiry sent successfully!", context);

      // Optionally clear the fields after submission
      clearFields();
    } catch (error) {
      Navigator.pop(context);
      cMethods.displaySnackBar(error.toString(), context);
    }
  }

  void clearFields() {
    userNameTextEditingController.clear();
    userPhoneTextEditingController.clear();
    emailTextEditingController.clear();
    inquiresTextEditingController.clear();
    passwordTextEditingController.clear(); // Clear password field as well
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              // Title label at the top
              const Text(
                "Create an Inquiry", // Label at the top
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20), // Space between label and form

              // Inquiry form inside a Card
              Card(
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
                          "assets/images/helpdesk1.png",
                          width: 500,
                          height: 350,
                          fit: BoxFit.cover, // Adjust the fit as needed
                        ),
                      ),
                      // Text fields + buttons
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            TextField(
                              controller: userNameTextEditingController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                labelText: "Your Name",
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 22),
                            TextField(
                              controller: userPhoneTextEditingController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: "Your Phone",
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 22),
                            TextField(
                              controller: emailTextEditingController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: "Your Email",
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 22),
                            TextField(
                              controller: inquiresTextEditingController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                labelText: "Your Inquiries",
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () {
                                checkIfNetworkIsAvailable();
                                signUpFormValidation();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff149777),
                                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                              ),
                              child: const Text(
                                "Send",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
