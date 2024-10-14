import 'dart:io';
import 'package:drivers_app/admin_dashboard/admin_dashboard.dart';
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

class Transportation extends StatefulWidget {
  final String userName;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const Transportation({
    Key? key,
    required this.userName,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  }) : super(key: key);

  @override
  _TransportationState createState() => _TransportationState();
}

class _TransportationState extends State<Transportation> {
  int _selectedIndex = 0; // Track the selected index
  bool _showtaxiForm = false; // Track visibility of Package form
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _taxies = [];
  List<Map<String, dynamic>> _inquiries = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTaxi();
    _fetchInquiries();
  }


  // Controllers for the form fields
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _yearsOfExperienceController = TextEditingController();
  final TextEditingController _languageSpokenController = TextEditingController();
  final TextEditingController _professionalLinksController = TextEditingController();

  // controller packages
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _vehicleColorController = TextEditingController();
  final TextEditingController _seatingCapacityController = TextEditingController();
  final TextEditingController _luggageCapacityController = TextEditingController();
  final TextEditingController _priceForKilomiterController = TextEditingController();
  final TextEditingController _specialFeaturesController = TextEditingController();

  CommonMethods cMethods = CommonMethods();
  XFile? imageFile; // For image upload
  String urlForUploadImage = "";
  String urlForTaxiUploadImage = "";
  String urlFortaxiDriverUploadImage = ""; // To store image URL

  void _onButtonPressed(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
      // Hide package form if navigating away from Packages tab
      if (index != 2) {
        _showtaxiForm = false; // Reset package form visibility
      }
    });
  }

  @override
  void dispose() {
    _licenseNumberController.dispose();
    _yearsOfExperienceController.dispose();
    _languageSpokenController.dispose();
    _professionalLinksController.dispose();

    _vehicleTypeController.dispose();
    _vehicleNumberController.dispose();
    _vehicleModelController.dispose();
    _vehicleColorController.dispose();
    _seatingCapacityController.dispose();
    _luggageCapacityController.dispose();
    _specialFeaturesController.dispose();
    _priceForKilomiterController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Garbage Truck Dashboard"),
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
              _buildNavButton("Garbage Truck Driver Details", 0),
              _buildNavButton("Route", 1),
              _buildNavButton("Truck", 2),
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
  void _fetchTaxi() async {
    try {
      String userId = widget.userId; // User ID passed to the Sites page
      DatabaseEvent event = await _database
          .child('taxi_list') // Access the tour_packages node
          .child(userId)         // Navigate to the user's node using userId
          .child('taxi')     // Access the packages node for that user
          .once();               // Perform the read operation

      final snapshot = event.snapshot;
      if (snapshot.exists) {
        // Get the packages under the user's node
        Map<dynamic, dynamic>? taxies = snapshot.value as Map<dynamic, dynamic>?; // Safe cast
        if (taxies != null) { // Check if taxies is not null
          _taxies = taxies.entries.map((entry) {
            Map<String, dynamic> taxiData = Map<String, dynamic>.from(entry.value);
            taxiData['taxiId'] = entry.key; // Store the key as 'packageId'
            return taxiData;
          }).toList();
        }
      } else {
        setState(() {
          _errorMessage = 'No Garbage Truck found for this user.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching Garbage Truck: $e'; // Update error message on exception
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
        return _buildtaxiDriverDetailsForm(); // Call the form for Guide Details
      case 1:
        return _buildMyBookings();
      case 2:
        return _buildTaxiesTab();  // Packages tab with button to show form
      case 3:
        return _buildFeedbacks();
      default:
        return Center(child: Text("No Content Available"));
    }
  }

  //guide details UI

  Widget _buildtaxiDriverDetailsForm() {
    bool istaxiDriverEnabled = false; // Track toggle switch state

    return SingleChildScrollView( // Wrap with SingleChildScrollView for scrolling
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Align children to the start
          children: [
            // Heading
            const Text(
              "Garbage Truck Driver Details",
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

            const SizedBox(height: 20), // Space between toggle and fields

            // Experience Text Field
            _buildTextField(_licenseNumberController, "License Number"),
            const SizedBox(height: 20), // Space between fields

            // Service Text Field
            _buildTextField(_yearsOfExperienceController, "Years Of Experience"),
            const SizedBox(height: 20), // Space between fields

            // Certification Text Field
            _buildTextField(_languageSpokenController, "Language Spoken"),
            const SizedBox(height: 20), // Space between fields

            // Areas Text Field
            _buildTextField(_professionalLinksController, "Professional Links"),
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
      taxiDriverFormValidation();
    } else {
      cMethods.displaySnackBar(
          "Image must be selected.", context); // SnackBar if no image
    }
  }

  taxiDriverFormValidation() {
    // Validate the experience
    if (_licenseNumberController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("License field cannot be empty.", context);
    }
    // Validate the service
    else if (_yearsOfExperienceController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("Experience field cannot be empty.", context);
    }
    // Validate the certification
    else if (_languageSpokenController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("language field cannot be empty.", context);
    }
    // Validate the areas
    else if (_professionalLinksController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("professional field cannot be empty.", context);
    } else {
      taxiDriverUploadImage();
    }
  }

  taxiDriverUploadImage() async {
    // Reference to Firebase storage
    String fileName = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child("taxi_drivers")
        .child(fileName);
    UploadTask uploadTask = storageReference.putFile(File(imageFile!.path));
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    await taskSnapshot.ref.getDownloadURL().then((urlImage) {
      urlFortaxiDriverUploadImage = urlImage;

      saveTaxiDriverInfoToDatabase();
    });
  }

  saveTaxiDriverInfoToDatabase() {


    final taxiDriverRef = FirebaseDatabase.instance.ref().child("taxi_drivers");
    taxiDriverRef.child(widget.userId).set({
      "uid": widget.userId,
      "firstName": widget.firstName,
      "lastName": widget.lastName,
      "email": widget.email,
      "phone": widget.phone,
      "license": _licenseNumberController.text.trim(),
      "yearsOfExperience": _yearsOfExperienceController.text.trim(),
      "languageSpoken": _languageSpokenController.text.trim(),
      "professionalLinks": _professionalLinksController.text.trim(),
      "status": "approved",
      "thumbnail": urlFortaxiDriverUploadImage,
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
        desc: "Garbage Truck Driver has been create successfully!",
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
  // taxies UI
  Widget _buildTaxiesTab() {
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
                if (!_showtaxiForm)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showTaxiDetailsForm();// Toggle form visibility
                      });

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff149777), // Green button
                      foregroundColor: Colors.white, // White text
                    ),
                    child: const Text("Add Garbage Truck"), // Button text
                  ),

                const SizedBox(width: 10), // Space between the buttons
              ],
            ),
          ),
          const SizedBox(height: 20), // Space between button and form
          // Additional space between the form and the taxi list

          // Expanded widget to allow ListView to fit within the Column
          Expanded(
            child: ListView.builder(
              itemCount: _taxies.length,
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
                            _taxies[index]['thumbnail'] ?? '',
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
                                _taxies[index]['vehicle_type'] ?? 'No Name',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              // Package location
                              Text(
                                'Vehicle Model: ${_taxies[index]['vehicle_model'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              // Package price
                              Text(
                                'Driver Name: ${_taxies[index]['vehicle_color'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Collection Area: ${_taxies[index]['vehicle_seating_capacity'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Description: ${_taxies[index]['vehicle_price'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              // Package ID (Firebase-generated key)
                              Text(
                                'Taxi ID: ${_taxies[index]['taxiId'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
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

                                  _showEditTaxiDialog(_taxies[index]);
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
                                          _deleteTaxi(_taxies[index]['taxiId']);
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
  Widget _buildTaxiTextField(TextEditingController controller, String labelText) {
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
  void _showTaxiDetailsForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xfff0f0f0), // Set the background color of the dialog
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          title: const Center( // Center the title text
            child: Text(
              "Garbage Truck Details",
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
                  _buildTaxiTextField(_vehicleTypeController, "Vehicle ID"),
                  const SizedBox(height: 20),

                  _buildTaxiTextField(_vehicleNumberController, "Vehicle Type"),
                  const SizedBox(height: 20),

                  _buildTaxiTextField(_vehicleModelController, "Vehicle Capacity"),
                  const SizedBox(height: 20),

                  _buildTaxiTextField(_vehicleColorController, "Driver Name"),
                  const SizedBox(height: 20),

                  _buildTaxiTextField(_seatingCapacityController, "Assigned Collection Area"),
                  const SizedBox(height: 20),

                  _buildTaxiTextField(_luggageCapacityController, "Service Schedule"),
                  const SizedBox(height: 20),

                  _buildTaxiTextField(_specialFeaturesController, "Fuel Type"),
                  const SizedBox(height: 20),

                  _buildTaxiTextField(_priceForKilomiterController, "Maintenance History"),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                checkIfPacakgeNetworkIsAvailable();
                print("Garbage Truck details submitted");
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff149777),
                foregroundColor: Colors.white,
              ),
              child: const Text("Submit Garbage Truck"),
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
      taxiFormValidation();
    } else {
      cMethods.displaySnackBar(
          "Image must be selected.", context); // SnackBar if no image
    }
  }

  taxiFormValidation() {
    // Validate the experience
    if (_vehicleTypeController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    // Validate the service
    else if (_vehicleNumberController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    // Validate the certification
    else if (_vehicleModelController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    // Validate the areas
    else if (_vehicleColorController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    // Validate the expertise
    else if (_seatingCapacityController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    // Validate the languages
    else if (_luggageCapacityController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    else if (_specialFeaturesController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    else if (_priceForKilomiterController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    else {
      taxiUploadImage();
    }
  }

  taxiUploadImage() async {
    // Reference to Firebase storage
    String fileName = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child("taxi_list")
        .child(fileName);
    UploadTask uploadTask = storageReference.putFile(File(imageFile!.path));
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    await taskSnapshot.ref.getDownloadURL().then((urlImage) {
      urlForTaxiUploadImage = urlImage;

      saveTaxiInfoToDatabase();
    });
  }

  void saveTaxiInfoToDatabase() {
    final taxiDriverRef = FirebaseDatabase.instance
        .ref()
        .child("taxi_list")
        .child(widget.userId); // Store packages under the user's node

    // Generate a unique key for each new package
    String taxiId = taxiDriverRef.push().key!;

    taxiDriverRef.child("taxi").child(taxiId).set({
      "taxiId": taxiId,
      "uid": widget.userId,
      "firstName": widget.firstName,
      "lastName": widget.lastName,
      "email": widget.email,
      "phone": widget.phone,
      "vehicle_type": _vehicleTypeController.text.trim(),
      "vehicle_number": _vehicleNumberController.text.trim(),
      "vehicle_model": _vehicleModelController.text.trim(),
      "vehicle_color": _vehicleColorController.text.trim(),
      "vehicle_seating_capacity": _seatingCapacityController.text.trim(),
      "vehicle_luggage_capacity": _luggageCapacityController.text.trim(),
      "vehicle_features": _specialFeaturesController.text.trim(),
      "vehicle_price": _priceForKilomiterController.text.trim(),
      "status": "approved",
      "thumbnail": urlForTaxiUploadImage, // Image URL for the package
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
        desc: "Garbage Truck has been create successfully!",
        btnOkOnPress: () {
          _buildTaxiesTab();
        },
        dialogBackgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.black),
        descTextStyle: TextStyle(color: Colors.black),
      ).show();
    });
  }


  void choosePacakageImageFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = pickedImage; // Store the selected image
    });
  }

  //dialog box eka pop up wena eka
  void _showEditTaxiDialog(Map<String, dynamic> taxi) {
    TextEditingController typeController = TextEditingController(text: taxi['vehicle_type']);
    TextEditingController modelController = TextEditingController(text: taxi['vehicle_model']);
    TextEditingController colorController = TextEditingController(text: taxi['vehicle_color']);
    TextEditingController capacityController = TextEditingController(text: taxi['vehicle_seating_capacity']);
    TextEditingController priceController = TextEditingController(text: taxi['vehicle_price'].toString());
    TextEditingController numberController = TextEditingController(text: taxi['vehicle_number']);
    TextEditingController LcapacityController = TextEditingController(text: taxi['vehicle_luggage_capacity']);
    TextEditingController featuresController = TextEditingController(text: taxi['vehicle_features']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          title: Text("Edit Garbage Truck", style: TextStyle(fontSize: 16, color: Colors.teal)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: "Vehicle ID", labelStyle: TextStyle(color: Colors.black54),),
                  style: TextStyle(color: Colors.black),

                ),
                TextField(
                  controller: modelController,
                  decoration: InputDecoration(labelText: "Vehicle Type", labelStyle: TextStyle(color: Colors.black54),),
                  style: TextStyle(color: Colors.black),
                ),
                TextField(
                  controller: colorController,
                  decoration: InputDecoration(labelText: "Vehicle Capacity", labelStyle: TextStyle(color: Colors.black54),),
                  style: TextStyle(color: Colors.black),
                ),
                TextField(
                  controller: capacityController,
                  decoration: InputDecoration(labelText: "Driver Name", labelStyle: TextStyle(color: Colors.black54),),
                  style: TextStyle(color: Colors.black),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: "Assigned Collection Area", labelStyle: TextStyle(color: Colors.black54),),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.black),
                ),
                TextField(
                  controller: numberController,
                  decoration: InputDecoration(labelText: "Service Schedule", labelStyle: TextStyle(color: Colors.black54),),
                  style: TextStyle(color: Colors.black),
                ),
                TextField(
                  controller: LcapacityController,
                  decoration: InputDecoration(labelText: "Fuel Type", labelStyle: TextStyle(color: Colors.black54),),
                  style: TextStyle(color: Colors.black),
                ),
                TextField(
                  controller: featuresController,
                  decoration: InputDecoration(labelText: "Maintenance History", labelStyle: TextStyle(color: Colors.black54),),
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
                _updateTaxi(taxi['taxiId'], typeController.text, modelController.text, colorController.text, capacityController.text, priceController.text, numberController.text, LcapacityController.text, featuresController.text);
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
  void _updateTaxi(String taxiId, String type, String model, String color, String capacity, String price , String number, String Lcapacity, String features) async {
    try {
      await _database
          .child('taxi_list')
          .child(widget.userId)
          .child('taxi')
          .child(taxiId)
          .update({
        'vehicle_type': type,
        'vehicle_model': model,
        'vehicle_color': color,
        'vehicle_seating_capacity': capacity,
        'vehicle_price': price,
        'vehicle_number': number,
        'vehicle_luggage_capacity': Lcapacity,
        'vehicle_features': features,
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

          _fetchTaxi();
        },
        dialogBackgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.black),
        descTextStyle: TextStyle(color: Colors.black),
      ).show();
      // Refresh the package list after updating

    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating Truck: $e';
      });
    }
  }
  //package delete
  void _deleteTaxi(String taxiId) async {
    try {
      await _database
          .child('taxi_list')
          .child(widget.userId)
          .child('taxi')
          .child(taxiId)
          .remove();
      // Refresh the package list after deleting
      _fetchTaxi();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error deleting Truck: $e';
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
            'Route',
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
          'No Route available.', // Custom message for empty inquiries
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
                          desc: "Are you sure you want to verify this Route?",
                          btnCancelOnPress: () {},
                          btnOkOnPress: () {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.bottomSlide,
                              showCloseIcon: true,
                              title: "Success",
                              desc: "Route is verified successfully!",
                              btnOkOnPress: () {
                                Navigator.pop(context);
                              },
                            ).show();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Route verified!')),
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
                        'Verify Route',
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
