import 'dart:io';
import 'package:drivers_app/admin_dashboard/sites.dart';
import 'package:drivers_app/global/global_var.dart';
import 'package:drivers_app/methods/common_methods.dart'; // Adjust the import based on your project structure
import 'package:drivers_app/widgets/loading_dialog.dart'; // Adjust the import based on your project structure
import 'package:drivers_app/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class Restaurants extends StatefulWidget {
  final String userName;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const Restaurants({
    Key? key,
    required this.userName,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  }) : super(key: key);

  @override
  _RestaurantsState createState() => _RestaurantsState();
}

class _RestaurantsState extends State<Restaurants> {
  int _selectedIndex = 0; // Track the selected index
  bool _showRestaurantForm = false; // Track visibility of Package form
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _restaurants = [];
  List<Map<String, dynamic>> _inquiries = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
    _fetchInquiries();
  }


  // Controllers for the form fields
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _certificationController = TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // controller packages
  final TextEditingController _restaurantNameController = TextEditingController();
  final TextEditingController _restaurantLocationController = TextEditingController();
  final TextEditingController _restaurantCuisineController = TextEditingController();
  final TextEditingController _restaurantOpeningHoursController = TextEditingController();
  final TextEditingController _restaurantLiquorAvailabilityController = TextEditingController();
  final TextEditingController _restaurantSeatingCapacityController = TextEditingController();
  final TextEditingController _restaurantParkingAvailabilityController = TextEditingController();

  CommonMethods cMethods = CommonMethods();
  XFile? imageFile; // For image upload
  String urlForUploadImage = "";
  String urlForRestaurantUploadImage = "";
  String urlForRestaurantManagerUploadImage = ""; // To store image URL

  void _onButtonPressed(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
      // Hide package form if navigating away from Packages tab
      if (index != 2) {
        _showRestaurantForm = false; // Reset package form visibility
      }
    });
  }

  @override
  void dispose() {
    _experienceController.dispose();
    _positionController.dispose();
    _certificationController.dispose();
    _expertiseController.dispose();
    _languageController.dispose();
    _descriptionController.dispose();
    _restaurantNameController.dispose();
    _restaurantLocationController.dispose();
    _restaurantCuisineController.dispose();
    _restaurantOpeningHoursController.dispose();
    _restaurantLiquorAvailabilityController.dispose();
    _restaurantSeatingCapacityController.dispose();
    _restaurantParkingAvailabilityController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trash Bin Collector Dashboard"),
        backgroundColor: const Color(
            0xff149777), // Green background for the AppBar
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavButton("Trash Bin Collectors' Manager", 0),
              _buildNavButton("Appointments", 1),
              _buildNavButton("Collectors", 2),
              _buildNavButton("Feedbacks", 3),
            ],
          ),
          const SizedBox(height: 20), // Space between buttons and content
          // Content Section
          Expanded(
            child: _getContentWidget(),
          ),
        ],
      ),
    );
  }

  //fetch tour packages
  void _fetchRestaurants() async {
    try {
      String userId = widget.userId; // User ID passed to the Sites page
      DatabaseEvent event = await _database
          .child('restaurant_list') // Access the tour_packages node
          .child(userId)         // Navigate to the user's node using userId
          .child('restaurants')     // Access the packages node for that user
          .once();               // Perform the read operation

      final snapshot = event.snapshot;
      if (snapshot.exists) {
        // Get the packages under the user's node
        Map<dynamic, dynamic>? restaurants = snapshot.value as Map<dynamic, dynamic>?; // Safe cast
        if (restaurants != null) { // Check if packages is not null
          _restaurants = restaurants.entries.map((entry) {
            Map<String, dynamic> restaurantData = Map<String, dynamic>.from(entry.value);
            restaurantData['restaurantId'] = entry.key; // Store the key as 'packageId'
            return restaurantData;
          }).toList();
        }
      } else {
        setState(() {
          _errorMessage = 'No Collectors found for this user.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching Collectors: $e'; // Update error message on exception
      });
    } finally {
      setState(() {
        _isLoading = false; // Update loading state
      });
    }
  }

  Widget _buildNavButton(String title, int index) {
    bool isSelected = _selectedIndex == index; // Check if button is selected
    return ElevatedButton(
      onPressed: () => _onButtonPressed(index),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xff149777) : Colors.white,
        // Green if selected, white otherwise
        foregroundColor: isSelected ? Colors.white : Colors.black,
        // Text color
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 10), // Button padding
      ),
      child: Text(title),
    );
  }

  Widget _getContentWidget() {
    switch (_selectedIndex) {
      case 0:
        return _buildRestaurantManagerDetailsForm(); // Call the form for Guide Details
      case 1:
        return _buildMyBookings();
      case 2:
        return _buildRestaurantsTab();  // Packages tab with button to show form
      case 3:
        return _buildFeedbacks();
      default:
        return Center(child: Text("No Content Available"));
    }
  }

  //guide details UI

  Widget _buildRestaurantManagerDetailsForm() {
    bool isRestaurantManagerEnabled = false; // Track toggle switch state

    return SingleChildScrollView( // Wrap with SingleChildScrollView for scrolling
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Align children to the start
          children: [
            // Heading
            const Text(
              "Collector Manager Details",
              style: TextStyle(
                fontSize: 36, // Set font size
                fontWeight: FontWeight.bold, // Set font weight
                color: Color(0xff149777), // Green color
              ),
            ),
            const SizedBox(height: 20), // Space after heading

            GestureDetector(
              onTap: () {
                chooseImageFromGallery();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                decoration: BoxDecoration(
                  color: Colors.teal, // Button background color
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4.0, // Shadow effect
                      offset: Offset(2, 2), // Shadow position
                    ),
                  ],
                ),
                child: const Text(
                  "Choose Image",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Space after image prompt

            // Toggle Switch
            // Space between toggle and fields

            // Experience Text Field
            _buildTextField(_experienceController, "Experience"),
            const SizedBox(height: 20), // Space between fields

            // Service Text Field
            _buildTextField(_positionController, "Position"),
            const SizedBox(height: 20), // Space between fields

            // Certification Text Field
            _buildTextField(_certificationController, "Certifications"),
            const SizedBox(height: 20), // Space between fields


            // Expertise Text Field
            _buildTextField(_expertiseController, "Expertise"),
            const SizedBox(height: 20), // Space between fields

            // Language Text Field
            _buildTextField(_languageController, "Languages"),
            const SizedBox(height: 20), // Space between fields

            // Description Text Field
            _buildTextField(_descriptionController, "Description"),
            const SizedBox(height: 20), // Space between fields

            // Submit Button
            ElevatedButton(
              onPressed: () {
                checkIfNetworkIsAvailable(); // Call your network check function
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff149777), // Green button
                foregroundColor: Colors.white, // White text
              ),
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        // Label color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
          borderSide: const BorderSide(
              color: Color(0xff149777)), // Border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
          borderSide: const BorderSide(
              color: Color(0xff149777)), // Enabled border color
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
          borderSide: const BorderSide(
              color: Color(0xff149777)), // Focused border color
        ),
      ),
      style: const TextStyle(color: Colors.black), // Text color
    );
  }

  checkIfNetworkIsAvailable() {
    cMethods.checkConnectivity(context);

    if (imageFile != null) { // Ensure you have an image selected
      restaurantManagerFormValidation();
    } else {
      cMethods.displaySnackBar(
          "Image must be selected.", context); // SnackBar if no image
    }
  }

  restaurantManagerFormValidation() {
    // Validate the experience
    if (_experienceController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("Experience field cannot be empty.", context);
    }
    // Validate the service
    else if (_positionController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("position field cannot be empty.", context);
    }
    // Validate the certification
    else if (_certificationController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("Certification field cannot be empty.", context);
    }
    // Validate the expertise
    else if (_expertiseController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("Expertise field cannot be empty.", context);
    }
    // Validate the languages
    else if (_languageController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("Language field cannot be empty.", context);
    }
    // Validate the description
    else if (_descriptionController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("Description field cannot be empty.", context);
    } else {
      restaurantManagerUploadImage();
    }
  }

  restaurantManagerUploadImage() async {
    // Reference to Firebase storage
    String fileName = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child("restaurant_list")
        .child(fileName);
    UploadTask uploadTask = storageReference.putFile(File(imageFile!.path));
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    await taskSnapshot.ref.getDownloadURL().then((urlImage) {
      urlForRestaurantManagerUploadImage = urlImage;

      saveRestaurantManagerInfoToDatabase();
    });
  }

  saveRestaurantManagerInfoToDatabase() {


    final restaurantManagerRef = FirebaseDatabase.instance.ref().child("restaurant_list");
    restaurantManagerRef.child(widget.userId).set({
      "uid": widget.userId,
      "firstName": widget.firstName,
      "lastName": widget.lastName,
      "email": widget.email,
      "phone": widget.phone,
      "experience": _experienceController.text.trim(),
      "position": _positionController.text.trim(),
      "certification": _certificationController.text.trim(),
      "expertise": _expertiseController.text.trim(),
      "languages": _languageController.text.trim(),
      "description": _descriptionController.text.trim(),
      "status": "approved",
      "thumbnail": urlForRestaurantManagerUploadImage,
    }).then((value) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (c) => _buildPackagesTab(),
      //   ),
      // );

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        showCloseIcon: true,
        title: "Success",
        desc: "Managers been create successfully!",
        btnOkOnPress: () {
          // Navigate to BookingDetailsPage if the OK button is pressed
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => Dashboard(userName: userName, userId: userId,),
          //   ),
          // );
        },
        dialogBackgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.black),
        descTextStyle: TextStyle(color: Colors.black),
      ).show();
    });
  }

  void chooseImageFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    setState(() {
      imageFile = pickedImage; // Store the selected image
    });
  }

  /////////////////////////////////////////////////////////////////// section 2 /////////////////////////////////////////////////////////////////////////////
  // packages UI
  Widget _buildRestaurantsTab() {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : Column(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the buttons horizontally
              children: [
                if (!_showRestaurantForm)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showRestaurantDetailsForm();// Toggle form visibility
                      });

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff149777), // Green button
                      foregroundColor: Colors.white, // White text
                    ),
                    child: const Text("Add Collector"), // Button text
                  ),

                const SizedBox(width: 10), // Space between the buttons
              ],
            ),
          ),
          const SizedBox(height: 20), // Space between button and form
          // Additional space between the form and the package list

          // Expanded widget to allow ListView to fit within the Column
          Expanded(
            child: ListView.builder(
              itemCount: _restaurants.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        // Display the image with rounded corners
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            _restaurants[index]['thumbnail'] ?? '',
                            height: 100, // Adjust height to make the image smaller
                            width: 100,  // Fixed width for image
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Text('Image not available'),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Package name
                              Text(
                                _restaurants[index]['restaurant_name'] ?? 'No Name',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              // Package location
                              Text(
                                'Collector ID: ${_restaurants[index]['restaurant_location'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              // Package price
                              Text(
                                'Collect Location: ${_restaurants[index]['restaurant_opening_hours'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              // Package ID (Firebase-generated key)
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            // Edit Button
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFA726),
                                  foregroundColor: const Color(0xFF8D6E63),
                                ),
                                onPressed: () {

                                  _showEditRestaurantDialog(_restaurants[index]);
                                },
                                child: const Text("Edit"),
                              ),
                            ),
                            const SizedBox(height: 8), // Spacing between buttons
                            // Delete Button
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    animType: AnimType.topSlide,
                                    showCloseIcon: true,
                                    title: "Warning",
                                    desc: "Are you sure you want to Delete this record?",
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
                                        desc: "Record has been deleted successfully!",
                                        btnOkOnPress: () {
                                          // Navigate to BookingDetailsPage if the OK button is pressed
                                          _deleteRestaurant(_restaurants[index]['restaurantId']);
                                        },
                                        dialogBackgroundColor: Colors.white,
                                        titleTextStyle: TextStyle(color: Colors.black),
                                        descTextStyle: TextStyle(color: Colors.black),
                                      ).show();

                                      // Show a snackbar to indicate that the payment was canceled
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Payment canceled!')),
                                      );
                                    },
                                    dialogBackgroundColor: Colors.white,
                                    titleTextStyle: TextStyle(color: Colors.black),
                                    descTextStyle: TextStyle(color: Colors.black),
                                  ).show();

                                },
                                child: const Text("Delete"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


// package dana form eka
  Widget _buildRestaurantTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey), // Light black label color
        border: const OutlineInputBorder(),
      ),
      style: const TextStyle(color: Colors.black), // Black text color
    );
  }

// Usage in the _buildPackageDetailsForm
  void _showRestaurantDetailsForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xfff0f0f0), // Set the background color of the dialog
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          title: Center( // Center the title text
            child: const Text(
              "Collector Details",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xff149777),
              ),
            ),
          ),
          content: SizedBox(
            width: 400, // Set the width of the dialog
            height: 600, // Set the height of the dialog
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust padding for keyboard
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // To fit the content inside the dialog
                children: [
                  GestureDetector(
                    onTap: () {
                      chooseImageFromGallery();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                      decoration: BoxDecoration(
                        color: Colors.teal, // Button background color
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0, // Shadow effect
                            offset: Offset(2, 2), // Shadow position
                          ),
                        ],
                      ),
                      child: const Text(
                        "Choose Image",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Text color
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // Space between elements
                  _buildRestaurantTextField(_restaurantNameController, "Collector Name"),
                  const SizedBox(height: 20),

                  _buildRestaurantTextField(_restaurantLocationController, "Collector ID"),
                  const SizedBox(height: 20),

                  _buildRestaurantTextField(_restaurantCuisineController, "Contact Information"),
                  const SizedBox(height: 20),

                  _buildRestaurantTextField(_restaurantOpeningHoursController, "Collection Area"),
                  const SizedBox(height: 20),

                  _buildRestaurantTextField(_restaurantLiquorAvailabilityController, "Attached Vehicle"),
                  const SizedBox(height: 20),

                  _buildRestaurantTextField(_restaurantSeatingCapacityController, "Collection Days"),
                  const SizedBox(height: 20),

                  _buildRestaurantTextField(_restaurantParkingAvailabilityController, "Special Notes"),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                checkIfPacakgeNetworkIsAvailable();
                print("Collector details submitted");
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff149777),
                foregroundColor: Colors.white,
              ),
              child: const Text("Submit Collector"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,// Set the text color to black
              ),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }








  checkIfPacakgeNetworkIsAvailable() {
    cMethods.checkConnectivity(context);

    if (imageFile != null) { // Ensure you have an image selected
      restaurantFormValidation();
    } else {
      cMethods.displaySnackBar(
          "Image must be selected.", context); // SnackBar if no image
    }
  }

  restaurantFormValidation() {
    // Validate the experience
    if (_restaurantNameController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    // Validate the service
    else if (_restaurantLocationController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    // Validate the certification
    else if (_restaurantCuisineController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    // Validate the areas
    else if (_restaurantOpeningHoursController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    // Validate the expertise
    else if (_restaurantLiquorAvailabilityController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    // Validate the languages
    else if (_restaurantSeatingCapacityController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    else if (_restaurantParkingAvailabilityController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    else {
      restaurantUploadImage();
    }
  }

  restaurantUploadImage() async {
    // Reference to Firebase storage
    String fileName = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child("restaurant_list")
        .child(fileName);
    UploadTask uploadTask = storageReference.putFile(File(imageFile!.path));
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    await taskSnapshot.ref.getDownloadURL().then((urlImage) {
      urlForRestaurantUploadImage = urlImage;

      saveRestaurantInfoToDatabase();
    });
  }

  void saveRestaurantInfoToDatabase() {
    final restaurantManagerRef = FirebaseDatabase.instance
        .ref()
        .child("restaurant_list")
        .child(widget.userId); // Store packages under the user's node

    // Generate a unique key for each new package
    String restaurantId = restaurantManagerRef.push().key!;

    restaurantManagerRef.child("restaurants").child(restaurantId).set({
      "restaurantId": restaurantId,
      "uid": widget.userId,
      "firstName": widget.firstName,
      "lastName": widget.lastName,
      "email": widget.email,
      "phone": widget.phone,
      "restaurant_name": _restaurantNameController.text.trim(),
      "restaurant_location": _restaurantLocationController.text.trim(),
      "restaurant_cuisine": _restaurantCuisineController.text.trim(),
      "restaurant_opening_hours": _restaurantOpeningHoursController.text.trim(),
      "restaurant_liquor_availability": _restaurantLiquorAvailabilityController.text.trim(),
      "restaurant_seating_capacity": _restaurantSeatingCapacityController.text.trim(),
      "restaurant_parking_available":_restaurantParkingAvailabilityController.text.trim(),
      "status": "approved",
      "thumbnail": urlForRestaurantUploadImage, // Image URL for the package
    }).then((value) {
      // String userName = widget.firstName + " " + widget.lastName;
      //
      // // Navigate to the Sites page with the correct data
      // Navigator.push(context, MaterialPageRoute(builder: (c) =>
      //     Sites(
      //         userName: userName,
      //         userId: widget.userId,
      //         firstName: widget.firstName,
      //         lastName: widget.lastName,
      //         email: widget.email,
      //         phone: widget.phone)));


      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        showCloseIcon: true,
        title: "Success",
        desc: "restaurant has been create successfully!",
        btnOkOnPress: () {
          _buildRestaurantsTab();
        },
        dialogBackgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.black),
        descTextStyle: TextStyle(color: Colors.black),
      ).show();
    });
  }


  void chooseRestaurantImageFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = pickedImage; // Store the selected image
    });
  }

  //dialog box eka pop up wena eka
  void _showEditRestaurantDialog(Map<String, dynamic> restaurant) {
    TextEditingController nameController = TextEditingController(text: restaurant['restaurant_name']);
    TextEditingController locationController = TextEditingController(text: restaurant['restaurant_location']);
    TextEditingController openingHoursController = TextEditingController(text: restaurant['restaurant_opening_hours'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          title: Text("Edit Collector", style: TextStyle(fontSize: 24, color: Colors.teal)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Collector Name Name", labelStyle: TextStyle(color: Colors.black54),),
                  style: TextStyle(color: Colors.black),

                ),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(labelText: "Collector ID", labelStyle: TextStyle(color: Colors.black54),),
                  style: TextStyle(color: Colors.black),
                ),
                TextField(
                  controller: openingHoursController,
                  decoration: InputDecoration(labelText: "Collection Area", labelStyle: TextStyle(color: Colors.black54),),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                _updateRestaurant(restaurant['restaurantId'], nameController.text, locationController.text, openingHoursController.text);
                Navigator.of(context).pop();
              },
              child: Text("Save", style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }
  //package update
  void _updateRestaurant(String restaurantId, String name, String location, String openingHours) async {
    try {
      await _database
          .child('restaurant_list')
          .child(widget.userId)
          .child('restaurants')
          .child(restaurantId)
          .update({
        'restaurant_name': name,
        'restaurant_location': location,
        'restaurant_opening_hours': openingHours,
      });
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        showCloseIcon: true,
        title: "Success",
        desc: "Details has been updated successfully!",
        btnOkOnPress: () {
          // Navigate to BookingDetailsPage if the OK button is pressed

          _fetchRestaurants();
        },
        dialogBackgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.black),
        descTextStyle: TextStyle(color: Colors.black),
      ).show();
      // Refresh the package list after updating

    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating Collector: $e';
      });
    }
  }
  //restaurant delete
  void _deleteRestaurant(String restaurantId) async {
    try {
      await _database
          .child('restaurant_list')
          .child(widget.userId)
          .child('restaurants')
          .child(restaurantId)
          .remove();
      // Refresh the package list after deleting
      _fetchRestaurants();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error deleting restaurant: $e';
      });
    }
  }

  void _fetchInquiries() async {
    setState(() {
      _isLoading = true; // Start loading state
    });

    try {
      // Access the inquiries node directly
      DatabaseEvent event = await _database.child('inquiries').once(); // Perform the read operation

      final snapshot = event.snapshot;
      if (snapshot.exists) {
        // Get the inquiries under the inquiries node
        Map<dynamic, dynamic>? inquiries = snapshot.value as Map<dynamic, dynamic>?; // Safe cast
        if (inquiries != null) { // Check if inquiries is not null
          _inquiries = inquiries.entries.map((entry) {
            Map<String, dynamic> inquiryData = Map<String, dynamic>.from(entry.value);
            inquiryData['inquiryId'] = entry.key; // Store the key as 'inquiryId'
            return inquiryData;
          }).toList();
        }
      } else {
        setState(() {
          _errorMessage = 'No inquiries found.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching inquiries: $e'; // Update error message on exception
      });
    } finally {
      setState(() {
        _isLoading = false; // Update loading state
      });
    }
  }

// Method to build the feedbacks screen
  Widget _buildFeedbacks() {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Feedbacks',
            style: TextStyle(color: Colors.teal), // Text color for the title
          ),
        ),
        backgroundColor: Colors.transparent, // Optional: make the AppBar background transparent
        elevation: 10, // Optional: remove shadow
        automaticallyImplyLeading: false, // Prevents showing the back arrow
      ),
      body: Container(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _inquiries.isEmpty
            ? const Center(
          child: Text(
            'No inquiries available.', // Custom message for empty inquiries
            style: TextStyle(color: Colors.white), // White text color
          ),
        )
            : ListView.builder(
          itemCount: _inquiries.length,
          itemBuilder: (context, index) {
            final inquiry = _inquiries[index];
            return GestureDetector(
              onTap: () {
                // Handle card tap interactions if needed
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      color: Colors.teal, width: 2.0), // Teal outline
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                color: const Color(0xffeceff1), // Background color similar to the other card
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(
                      Icons.feedback, // Feedback icon
                      color: Colors.teal,
                    ),
                  ),
                  title: Text(
                    inquiry['name'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue, // Light blue text color
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inquiry['message'] ?? 'No Message',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              color: Colors.amber, size: 16.0),
                          const SizedBox(width: 4.0),
                          Text(
                            inquiry['phone'] ?? 'No Phone',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      String replyMessage = '';

                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        animType: AnimType.topSlide,
                        showCloseIcon: true,
                        title: "Reply",
                        desc: "Type your reply for this inquiry.",
                        body: Column(
                          children: [
                            const Text(
                              'Type your reply:',
                              style: TextStyle(color: Colors.black),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              onChanged: (value) {
                                replyMessage = value; // Capture the user's input
                              },
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Reply Message',
                                labelStyle:
                                TextStyle(color: Colors.black),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                        btnCancelOnPress: () {},
                        btnOkOnPress: () {
                          if (replyMessage.isNotEmpty) {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.bottomSlide,
                              showCloseIcon: true,
                              title: "Success",
                              desc: "Reply sent successfully: $replyMessage",
                              btnOkOnPress: () {
                                // Handle further actions after success
                              },
                              dialogBackgroundColor: Colors.white,
                              titleTextStyle: const TextStyle(
                                  color: Colors.black),
                              descTextStyle: const TextStyle(
                                  color: Colors.black),
                            ).show();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please enter a reply message before sending.')),
                            );
                          }
                        },
                        dialogBackgroundColor: Colors.white,
                        titleTextStyle:
                        const TextStyle(color: Colors.black),
                        descTextStyle:
                        const TextStyle(color: Colors.black),
                      ).show();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Button color green
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Text(
                      'Reply',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMyBookings() {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'My Appointments',
            style: TextStyle(color: Colors.teal), // Text color for the title
          ),
        ),
        backgroundColor: Colors.transparent, // Make AppBar background transparent
        elevation: 10, // Optional: set shadow
        automaticallyImplyLeading: false, // Prevents showing the back arrow
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading indicator
          : _inquiries.isEmpty
          ? const Center(
        child: Text(
          'No inquiries available.', // Custom message for empty inquiries
          style: TextStyle(color: Colors.white), // White text color
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // 4 items per row
          crossAxisSpacing: 8.0, // Horizontal space between items
          mainAxisSpacing: 8.0, // Vertical space between items
          childAspectRatio: 0.7, // Control the height/width ratio
        ),
        itemCount: _inquiries.length,
        itemBuilder: (context, index) {
          final inquiry = _inquiries[index];
          return GestureDetector(
            onTap: () {
              // Handle card tap interactions if needed
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.teal, width: 2.0), // Teal outline
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
              color: const Color(0xffeceff1), // Background color
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(
                        Icons.add_alert, // Feedback icon
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      inquiry['name'] ?? 'No Name', // Inquirer name
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue, // Light blue text color
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      inquiry['message'] ?? 'No Message', // Inquirer message
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone, color: Colors.amber, size: 16.0),
                        const SizedBox(width: 4.0),
                        Text(
                          inquiry['phone'] ?? 'No Phone', // Inquirer phone number
                          style: const TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: () {
                        // Action for Verify button
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.warning,
                          animType: AnimType.topSlide,
                          showCloseIcon: true,
                          title: "Warning",
                          desc: "Are you sure you want to verify this appointment?",
                          btnCancelOnPress: () {},
                          btnOkOnPress: () {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.bottomSlide,
                              showCloseIcon: true,
                              title: "Success",
                              desc: "appointment is verified successfully!",
                              btnOkOnPress: () {
                                Navigator.pop(context);
                              },
                            ).show();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('appointment verified!')),
                            );
                          },
                        ).show();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Button color green
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text(
                        'Verify appointment',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }




}
