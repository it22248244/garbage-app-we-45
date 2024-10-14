import 'dart:io';

import 'package:drivers_app/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drivers_app/authentication/login_screen.dart';
import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController firstNameTextEditingController = TextEditingController();
  TextEditingController lastNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();
  XFile? imageFile;
  String urlForUploadImage = "";

  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);

    if (imageFile != null) {
      signUpFormValidation();
    } else {
      cMethods.displaySnackBar("Please choose an image", context);
    }
  }

  signUpFormValidation() {
    if (userNameTextEditingController.text.trim().length < 3) {
      cMethods.displaySnackBar("Your name must be at least 3 or more characters.", context);
    } else if (firstNameTextEditingController.text.trim().length < 3) {
      cMethods.displaySnackBar("Your first name must be at least 3 or more characters.", context);
    } else if (lastNameTextEditingController.text.trim().length < 3) {
      cMethods.displaySnackBar("Your last name must be at least 3 or more characters.", context);
    } else if (userPhoneTextEditingController.text.trim().length < 10) {
      cMethods.displaySnackBar("Your phone number must be at least 10 digits.", context);
    } else if (!emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("Please enter a valid email address.", context);
    } else if (passwordTextEditingController.text.trim().length < 6) {
      cMethods.displaySnackBar("Your password must be at least 6 or more characters.", context);
    } else if (confirmPasswordTextEditingController.text.trim() != passwordTextEditingController.text.trim()) {
      cMethods.displaySnackBar("Passwords do not match.", context);
    } else {
      uploadImageToStorage();
    }
  }


  uploadImageToStorage() async {
    String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImage = FirebaseStorage.instance.ref().child("Images").child(imageIDName);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlForUploadImage = await snapshot.ref.getDownloadURL();

    setState(() {
      urlForUploadImage;
    });
    registerNewUser();
  }

  registerNewUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Registering Your Account..."),
    );

    final User? userFirebase = (
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).catchError((errorMsg) {
          Navigator.pop(context);
          cMethods.displaySnackBar(errorMsg.toString(), context);
        })
    ).user;

    if (!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("admin").child(userFirebase!.uid);


    Map<String, dynamic> adminDataMap = {
      "photo": urlForUploadImage,
      "name": userNameTextEditingController.text.trim(),
      "firstName": firstNameTextEditingController.text.trim(), // Added first name
      "lastName": lastNameTextEditingController.text.trim(),   // Added last name
      "email": emailTextEditingController.text.trim(),
      "phone": userPhoneTextEditingController.text.trim(),
      "password":passwordTextEditingController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
    };


    // Save user data to the database
    usersRef.set(adminDataMap);

    // Navigate to Dashboard, passing both userName and userId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => Dashboard(
          userName: userNameTextEditingController.text.trim(), // Pass the userName
          userId: userFirebase.uid, // Pass the userId
        ),
      ),
    );
  }

  chooseImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Card(
            color: Colors.white, // Set card color to white
            elevation: 5, // Add some elevation
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  imageFile == null
                      ? const CircleAvatar(
                    radius: 86,
                    backgroundImage: AssetImage("assets/images/logoGarbage.jpeg"),
                  )
                      : Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: FileImage(
                          File(
                            imageFile!.path,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      chooseImageFromGallery();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFA726), // Background color
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text(
                      "Choose Image",
                      style: TextStyle(
                        color: Color(0xFF8D6E63), // Text color
                      ),
                    ),
                  ),

                  // GestureDetector(
                  //   onTap: () {
                  //     chooseImageFromGallery();
                  //   },
                  //   child: const Text(
                  //     "Choose Image",
                  //     style: TextStyle(
                  //       fontSize: 26,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.black, // Set color to grey
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 10),
                  // Text fields + buttons
                  Padding(
                    padding:
                    const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        TextField(
                          controller: userNameTextEditingController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: "Username",
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey, // Set label color to grey
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.black, // Text color in the field
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 22),
                        TextField(
                          controller: firstNameTextEditingController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: "First Name",
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey, // Set label color to grey
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.black, // Text color in the field
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 22),
                        TextField(
                          controller: lastNameTextEditingController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: "Last Name",
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey, // Set label color to grey
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.black, // Text color in the field
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 22),
                        TextField(
                          controller: userPhoneTextEditingController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: "Your Phone",
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey, // Set label color to grey
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.black, // Text color in the field
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
                              color: Colors.grey, // Set label color to grey
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.black, // Text color in the field
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
                            color: Colors.black, // Text color in the field
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: confirmPasswordTextEditingController,
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: "Confirm Password",
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey, // Set label color to grey
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.black, // Text color in the field
                            fontSize: 15,
                          ),
                        ),


                        //signup
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: checkIfNetworkIsAvailable,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff149777),
                            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                          ),
                          child: const Text(
                            "Already have an account? Login Here",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
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
