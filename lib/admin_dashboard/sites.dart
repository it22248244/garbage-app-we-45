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

class Sites extends StatefulWidget {
  final String userName;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const Sites({
    Key? key,
    required this.userName,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  }) : super(key: key);

  @override
  _SitesState createState() => _SitesState();
}

class _SitesState extends State<Sites> {
  int _selectedIndex = 0; // Track the selected index
  bool _showSiteForm = false; // Track visibility of Package form
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _sites = [];
  List<Map<String, dynamic>> _inquiries = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSites();
    _fetchInquiries();
  }


  // Controllers for the form fields
  final TextEditingController _managerAddressController = TextEditingController();
  final TextEditingController _managerExperienceController = TextEditingController();
  final TextEditingController _managerAgeController = TextEditingController();
  final TextEditingController _managerSpecialtiesHoursController = TextEditingController();
  final TextEditingController _managerLicenceController = TextEditingController();

  // controller sites
  final TextEditingController _siteNameController = TextEditingController();
  final TextEditingController _siteDescriptionController = TextEditingController();
  final TextEditingController _siteLocationController = TextEditingController();
  final TextEditingController _siteOpeningHoursController = TextEditingController();
  final TextEditingController _siteEntranceFeeController = TextEditingController();
  final TextEditingController _siteKeyHighlightsController = TextEditingController();
  final TextEditingController _siteFacilitiesController = TextEditingController();

  CommonMethods cMethods = CommonMethods();
  XFile? imageFile; // For image upload
  String urlForUploadImage = "";
  String urlForSiteUploadImage = "";
  String urlForManagerUploadImage = ""; // To store image URL

  void _onButtonPressed(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
      // Hide package form if navigating away from Packages tab
      if (index != 2) {
        _showSiteForm = false; // Reset package form visibility
      }
    });
  }

  @override
  void dispose() {
    _managerAddressController.dispose();
    _managerExperienceController.dispose();
    _managerAgeController.dispose();
    _managerSpecialtiesHoursController.dispose();
    _managerLicenceController.dispose();


    _siteNameController.dispose();
    _siteDescriptionController.dispose();
    _siteLocationController.dispose();
    _siteOpeningHoursController.dispose();
    _siteEntranceFeeController.dispose();
    _siteKeyHighlightsController.dispose();
    _siteFacilitiesController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Area Information Dashboard"),
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
              _buildNavButton("Area Manager Details", 0),
              _buildNavButton("inquiries", 1),
              _buildNavButton("Areas", 2),
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

  void _fetchSites() async {
    try {
      String userId = widget.userId; // User ID passed to the Sites page
      DatabaseEvent event = await _database
          .child('site_list') // Access the tour_packages node
          .child(userId)         // Navigate to the user's node using userId
          .child('sites')     // Access the packages node for that user
          .once();               // Perform the read operation

      final snapshot = event.snapshot;
      if (snapshot.exists) {
        // Get the packages under the user's node
        Map<dynamic, dynamic>? sites = snapshot.value as Map<dynamic, dynamic>?; // Safe cast
        if (sites != null) { // Check if packages is not null
          _sites = sites.entries.map((entry) {
            Map<String, dynamic> siteData = Map<String, dynamic>.from(entry.value);
            siteData['siteId'] = entry.key; // Store the key as 'packageId'
            return siteData;
          }).toList();
        }
      } else {
        setState(() {
          _errorMessage = 'No sites found for this user.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching sites: $e'; // Update error message on exception
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
        return _buildSiteManagerDetailsForm(); // Call the form for Guide Details
      case 1:
        return _buildMyBookings();
      case 2:
        return _buildSiteTab();  // Packages tab with button to show form
      case 3:
        return _buildFeedbacks();
      default:
        return Center(child: Text("No Content Available"));
    }
  }

  //guide details UI

  Widget _buildSiteManagerDetailsForm() {
    bool isTourGuideEnabled = false; // Track toggle switch state

    return SingleChildScrollView( // Wrap with SingleChildScrollView for scrolling
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Align children to the start
          children: [
            // Heading
            const Text(
              "Area Manager Details",
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
            _buildTextField(_managerAddressController, "Official Address"),
            const SizedBox(height: 20), // Space between fields

            // Service Text Field
            _buildTextField(_managerExperienceController, "Experience"),
            const SizedBox(height: 20), // Space between fields

            // Certification Text Field
            _buildTextField(_managerAgeController, "Age"),
            const SizedBox(height: 20), // Space between fields

            // Areas Text Field
            _buildTextField(_managerSpecialtiesHoursController, "Specialities"),
            const SizedBox(height: 20), // Space between fields

            // Expertise Text Field
            _buildTextField(_managerLicenceController, "Licence"),
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
      siteManagerFormValidation();
    } else {
      cMethods.displaySnackBar(
          "Image must be selected.", context); // SnackBar if no image
    }
  }

  siteManagerFormValidation() {
    // Validate the experience
    if (_managerAddressController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("Experience field cannot be empty.", context);
    }
    // Validate the service
    else if (_managerExperienceController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("Service field cannot be empty.", context);
    }
    // Validate the certification
    else if (_managerAgeController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("Certification field cannot be empty.", context);
    }
    // Validate the areas
    else if (_managerSpecialtiesHoursController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("Areas field cannot be empty.", context);
    }
    // Validate the expertise
    else if (_managerLicenceController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("Expertise field cannot be empty.", context);
    } else {
      siteManagerUploadImage();
    }
  }

  siteManagerUploadImage() async {
    // Reference to Firebase storage
    String fileName = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child("site_managers")
        .child(fileName);
    UploadTask uploadTask = storageReference.putFile(File(imageFile!.path));
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    await taskSnapshot.ref.getDownloadURL().then((urlImage) {
      urlForManagerUploadImage = urlImage;

      saveSiteManagerInfoToDatabase();
    });
  }

  saveSiteManagerInfoToDatabase() {

    final siteManagerRef = FirebaseDatabase.instance.ref().child("site_managers");
    siteManagerRef.child(widget.userId).set({
      "uid": widget.userId,
      "firstName": widget.firstName,
      "lastName": widget.lastName,
      "email": widget.email,
      "phone": widget.phone,
      "address": _managerAddressController.text.trim(),
      "experience": _managerExperienceController.text.trim(),
      "age": _managerAgeController.text.trim(),
      "specialities": _managerSpecialtiesHoursController.text.trim(),
      "licence": _managerLicenceController.text.trim(),
      "status": "approved",
      "thumbnail": urlForManagerUploadImage,
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
        desc: "Area Manager has been create successfully!",
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


  ///////////////////////////////////////////////////////////////////////////////////////// section 2 /////////////////////////////////////////////////////////////////////////////////////////////
  // packages UI
  Widget _buildSiteTab() {
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
                if (!_showSiteForm)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showSiteDetailsForm();// Toggle form visibility
                      });

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff149777), // Green button
                      foregroundColor: Colors.white, // White text
                    ),
                    child: const Text("Add Area"), // Button text
                  ),

                const SizedBox(width: 10), // Space between the buttons
              ],
            ),
          ),

          const SizedBox(height: 20), // Space between buttons and site list

          // Expanded widget to allow ListView to fit within the Column
          Expanded(
            child: ListView.builder(

              itemCount: _sites.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        // Display site image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            _sites[index]['thumbnail'] ?? '',
                            height: 100,
                            width: 100,
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
                              Text(
                                _sites[index]['site_name'] ?? 'No Name',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Location: ${_sites[index]['site_location'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Collecting Time: ${_sites[index]['site_opening_hours'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Collect Items: ${_sites[index]['site_entrance_fee'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFA726),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  _showEditSiteDialog(_sites[index]);
                                },
                                child: const Text("Edit"),
                              ),
                            ),
                            const SizedBox(height: 8),
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
                                    desc: "Are you sure you want to delete this record?",
                                    btnCancelOnPress: () {},
                                    btnOkOnPress: () {
                                      _deleteSite(_sites[index]['siteId']);
                                    },
                                    dialogBackgroundColor: Colors.white,
                                    titleTextStyle: const TextStyle(color: Colors.black),
                                    descTextStyle: const TextStyle(color: Colors.black),
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
  Widget _buildSiteTextField(TextEditingController controller, String labelText) {
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
  void _showSiteDetailsForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xfff0f0f0), // Set the background color of the dialog
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          title: Center( // Center the title text
            child:const Text(
              "Area Details",
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
                        "Choose Area Image",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Text color
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // Space between elements
                  _buildSiteTextField(_siteNameController, "Area Name"),
                  const SizedBox(height: 20),

                  _buildSiteTextField(_siteDescriptionController, "Pick Up Days"),
                  const SizedBox(height: 20),

                  _buildSiteTextField(_siteLocationController, "Location"),
                  const SizedBox(height: 20),

                  _buildSiteTextField(_siteOpeningHoursController, "Time Window"),
                  const SizedBox(height: 20),

                  _buildSiteTextField(_siteEntranceFeeController, "Waste Types Collected"),
                  const SizedBox(height: 20),

                  _buildSiteTextField(_siteKeyHighlightsController, "Special Collections"),
                  const SizedBox(height: 20),

                  _buildSiteTextField(_siteFacilitiesController, "Description"),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                checkIfSiteNetworkIsAvailable();
                print("Area details submitted");
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff149777),
                foregroundColor: Colors.white,
              ),
              child: const Text("Submit Area"),
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



  checkIfSiteNetworkIsAvailable() {
    cMethods.checkConnectivity(context);

    if (imageFile != null) { // Ensure you have an image selected
      siteFormValidation();
    } else {
      cMethods.displaySnackBar(
          "Image must be selected.", context); // SnackBar if no image
    }
  }

  siteFormValidation() {
    // Validate the experience
    if (_siteNameController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    // Validate the service
    else if (_siteDescriptionController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    // Validate the certification
    else if (_siteLocationController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    // Validate the areas
    else if (_siteOpeningHoursController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    // Validate the expertise
    else if (_siteEntranceFeeController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    // Validate the languages
    else if (_siteKeyHighlightsController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    else if (_siteFacilitiesController.text
        .trim()
        .isEmpty) {
      cMethods.displaySnackBar("field cannot be empty.", context);
    }
    else {
      siteUploadImage();
    }
  }

  siteUploadImage() async {
    // Reference to Firebase storage
    String fileName = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child("site_list")
        .child(fileName);
    UploadTask uploadTask = storageReference.putFile(File(imageFile!.path));
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    await taskSnapshot.ref.getDownloadURL().then((urlImage) {
      urlForSiteUploadImage = urlImage;

      saveSiteInfoToDatabase();
    });
  }

  void saveSiteInfoToDatabase() {
    final tourGuideRef = FirebaseDatabase.instance
        .ref()
        .child("site_list")
        .child(widget.userId); // Store packages under the user's node

    // Generate a unique key for each new package
    String siteId = tourGuideRef.push().key!;

    tourGuideRef.child("sites").child(siteId).set({
      "siteId": siteId,
      "uid": widget.userId,
      "firstName": widget.firstName,
      "lastName": widget.lastName,
      "email": widget.email,
      "phone": widget.phone,
      "site_name": _siteNameController.text.trim(),
      "site_description": _siteDescriptionController.text.trim(),
      "site_location": _siteLocationController.text.trim(),
      "site_opening_hours": _siteOpeningHoursController.text.trim(),
      "site_entrance_fee": _siteEntranceFeeController.text.trim(),
      "site_key_highlight": _siteKeyHighlightsController.text.trim(),
      "site_facilities": _siteFacilitiesController.text.trim(),
      "status": "approved",
      "thumbnail": urlForSiteUploadImage, // Image URL for the package
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
        desc: "Area has been create successfully!",
        btnOkOnPress: () {
          _buildSiteTab();
        },
        dialogBackgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.black),
        descTextStyle: TextStyle(color: Colors.black),
      ).show();
    });
  }


  void chooseSiteImageFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = pickedImage; // Store the selected image
    });
  }




  //dialog box eka pop up wena eka
  void _showEditSiteDialog(Map<String, dynamic> package) {
    TextEditingController nameController = TextEditingController(text: package['site_name']);
    TextEditingController locationController = TextEditingController(text: package['site_location']);
    TextEditingController hoursController = TextEditingController(text: package['site_opening_hours']);
    TextEditingController entranceFeeController = TextEditingController(text: package['site_entrance_fee'].toString());
    TextEditingController descriptionController = TextEditingController(text: package['site_description']);
    TextEditingController highlightController = TextEditingController(text: package['site_key_highlight']);
    TextEditingController facilitiesController = TextEditingController(text: package['site_facilities']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          backgroundColor: Colors.white,
          title: Text("Edit Area", style: TextStyle(fontSize: 24, color: Colors.teal)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Area Name", labelStyle: TextStyle(color: Colors.black54),),
                  style: TextStyle(color: Colors.black),

                ),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(labelText: "Pick Up Days", labelStyle: TextStyle(color: Colors.black54),),
                  style: TextStyle(color: Colors.black),
                ),
                TextField(
                  controller: hoursController,
                  decoration: InputDecoration(labelText: "Location", labelStyle: TextStyle(color: Colors.black54),),
                  style: TextStyle(color: Colors.black),
                ),
                TextField(
                  controller: entranceFeeController,
                  decoration: InputDecoration(labelText: "Time Window", labelStyle: TextStyle(color: Colors.black54),),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.black),
                ),
                TextField(
                  controller: facilitiesController,
                  decoration: InputDecoration(labelText: "Waste Types Collected", labelStyle: TextStyle(color: Colors.black54),),
                  style: TextStyle(color: Colors.black),
                ),
                TextField(
                  controller: highlightController,
                  decoration: InputDecoration(labelText: "Special Collections", labelStyle: TextStyle(color: Colors.black54),),
                  style: TextStyle(color: Colors.black),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: "Description", labelStyle: TextStyle(color: Colors.black54),),
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
                _updateSite(package['siteId'], nameController.text, locationController.text, hoursController.text, entranceFeeController.text , facilitiesController.text , highlightController.text , descriptionController.text);
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
  void _updateSite(String siteId, String name, String location, String hours, String price, String facilities, String highlights, String description) async {
    try {
      await _database
          .child('site_list')
          .child(widget.userId)
          .child('sites')
          .child(siteId)
          .update({
        'site_name': name,
        'site_location': location,
        'site_opening_hours': hours,
        'site_entrance_fee': price,
        'site_description': facilities,
        'site_key_highlight': highlights,
        'site_facilities': description,
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

          _fetchSites();
        },
        dialogBackgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.black),
        descTextStyle: TextStyle(color: Colors.black),
      ).show();
      // Refresh the package list after updating

    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating site: $e';
      });
    }
  }
  //package delete
  void _deleteSite(String siteId) async {
    try {
      await _database
          .child('site_list')
          .child(widget.userId)
          .child('sites')
          .child(siteId)
          .remove();
      // Refresh the package list after deleting
      _fetchSites();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error deleting Area: $e';
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
            'Inquiries',
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
                          desc: "Are you sure you want to verify this Inquiry?",
                          btnCancelOnPress: () {},
                          btnOkOnPress: () {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.bottomSlide,
                              showCloseIcon: true,
                              title: "Success",
                              desc: "Inquiry is verified successfully!",
                              btnOkOnPress: () {
                                Navigator.pop(context);
                              },
                            ).show();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Booking verified!')),
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
                        'Verify Booking',
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
