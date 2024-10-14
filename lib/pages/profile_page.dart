import 'dart:io';
import 'package:drivers_app/global/global_var.dart';
import 'package:drivers_app/pages/dashboard.dart';
import 'package:drivers_app/admin_dashboard/admin_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';
import 'package:drivers_app/authentication/login_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class ProfilePage extends StatefulWidget {
  final String userId; // Pass the userId from the previous screen
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController firstNameTextEditingController = TextEditingController();
  TextEditingController lastNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();
  XFile? imageFile;
  String urlForUploadImage = "";

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  // Fetch user details from Firebase
  void getUserDetails() async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("admin").child(widget.userId);
    userRef.once().then((snapshot) {
      // Checking if snapshot exists
      if (snapshot.snapshot.exists) {
        var userData = snapshot.snapshot.value as Map<dynamic, dynamic>;

        // Updating text fields with data from Firebase
        firstNameTextEditingController.text = userData['firstName'] ?? '';
        lastNameTextEditingController.text = userData['lastName'] ?? '';
        userNameTextEditingController.text = "${firstNameTextEditingController.text} ${lastNameTextEditingController.text}";
        userPhoneTextEditingController.text = userData['phone'] ?? '';
        emailTextEditingController.text = userData['email'] ?? '';
        urlForUploadImage = userData['photo'] ?? '';

        setState(() {});
      }
    });
  }

  // Validate the input fields and upload the new image if selected
  void validateAndUpdate() {
    // Validation logic here...
    updateUserDetails();
  }

  // Update user details in Firebase
  void updateUserDetails() async {
    User? currentUser = FirebaseAuth.instance.currentUser; // Get the current authenticated user

    if (currentUser != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("admin").child(widget.userId);

      Map<String, dynamic> userDataMap = {
        "photo": urlForUploadImage,
        "name": userNameTextEditingController.text.trim(),
        "firstName": firstNameTextEditingController.text.trim(),
        "lastName": lastNameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": userPhoneTextEditingController.text.trim(),
        "password": passwordTextEditingController.text.trim(),
        "id": currentUser.uid, // Use the current user's UID
        "blockStatus": "no",
      };

      // Update the user's data in Firebase Realtime Database
      userRef.update(userDataMap).then((_) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          showCloseIcon: true,
          title: "Success",
          desc: "Profile Updated Successfully!!!!!",
          btnOkOnPress: () {
            // Navigate to LoginScreen if the OK button is pressed
            cMethods.displaySnackBar("Profile updated successfully", context);
          },
          dialogBackgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.black),
          descTextStyle: TextStyle(color: Colors.black),
        ).show();

      }).catchError((error) {
        cMethods.displaySnackBar(error.toString(), context);
      });
    } else {
      cMethods.displaySnackBar("User not logged in", context);
    }
  }

  chooseImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
      uploadImageToStorage();
    }
  }

  uploadImageToStorage() async {
    String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImage = FirebaseStorage.instance.ref().child("Images").child(imageIDName);
    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlForUploadImage = await snapshot.ref.getDownloadURL();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              final String userName = userNameTextEditingController.text.trim();
              final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
              final String firstName = firstNameTextEditingController.text.trim();
              final String lastName = lastNameTextEditingController.text.trim();
              final String email = emailTextEditingController.text.trim();
              final String phone = userPhoneTextEditingController.text.trim();

              // Navigate to AdminDashboard without using const
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminDashboard(
                    userName: userName,
                    userId: userId,
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    phone: phone,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.dashboard),
            tooltip: 'Go to Dashboard',
            color: Colors.white,
            iconSize: 40,
          ),
        ],
        backgroundColor: const Color(0xff149777), // Green color for AppBar background
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(height: 40),
              imageFile == null
                  ? urlForUploadImage.isNotEmpty
                  ? CircleAvatar(
                radius: 86,
                backgroundImage: NetworkImage(urlForUploadImage),
              )
                  : const CircleAvatar(
                radius: 86,
                backgroundImage: AssetImage("assets/images/avatarman.png"),
              )
                  : Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: FileImage(File(imageFile!.path)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  chooseImageFromGallery();
                },
                child: const Text(
                  "Choose Image",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              // Text fields + buttons
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextField(
                      controller: userNameTextEditingController,
                      readOnly: true, // Make the username read-only
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
                      readOnly: true, // Make email read-only
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
                        labelText: "New Password",
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
                    ElevatedButton(
                      onPressed: validateAndUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff149777),
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                      ),
                      child: const Text(
                        "Update",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: () {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.warning,
                          animType: AnimType.topSlide,
                          showCloseIcon: true,
                          title: "Warning",
                          desc: "Are you sure you want to Sign out?",
                          btnCancelOnPress: () {
                            // Do nothing if cancel is pressed
                          },
                          btnOkOnPress: () {
                            // Show a success dialog if the user confirms cancellation
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.bottomSlide,
                              showCloseIcon: true,
                              title: "Success",
                              desc: "Signing out.........",
                              btnOkOnPress: () {
                                // Navigate to LoginScreen if the OK button is pressed
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              dialogBackgroundColor: Colors.white,
                              titleTextStyle: TextStyle(color: Colors.black),
                              descTextStyle: TextStyle(color: Colors.black),
                            ).show();
                          },
                          dialogBackgroundColor: Colors.white,
                          titleTextStyle: TextStyle(color: Colors.black),
                          descTextStyle: TextStyle(color: Colors.black),
                        ).show();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA726),
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(fontSize: 16, color: Color(0xFF8D6E63)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
