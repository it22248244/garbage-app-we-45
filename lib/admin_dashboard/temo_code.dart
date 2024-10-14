import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _packages = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTourPackages();
  }

  void _fetchTourPackages() async {
    try {
      String userId = widget.userId; // User ID passed to the Sites page
      DatabaseEvent event = await _database
          .child('tour_packages') // Access the tour_packages node
          .child(userId)         // Navigate to the user's node using userId
          .child('packages')     // Access the packages node for that user
          .once();               // Perform the read operation

      final snapshot = event.snapshot;
      if (snapshot.exists) {
        // Get the packages under the user's node
        Map<dynamic, dynamic>? packages = snapshot.value as Map<dynamic, dynamic>?; // Safe cast
        if (packages != null) { // Check if packages is not null
          _packages = packages.entries.map((entry) {
            Map<String, dynamic> packageData = Map<String, dynamic>.from(entry.value);
            packageData['packageId'] = entry.key; // Store the key as 'packageId'
            return packageData;
          }).toList();
        }
      } else {
        setState(() {
          _errorMessage = 'No packages found for this user.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching packages: $e'; // Update error message on exception
      });
    } finally {
      setState(() {
        _isLoading = false; // Update loading state
      });
    }
  }

  void _showEditPackageDialog(Map<String, dynamic> package) {
    TextEditingController nameController = TextEditingController(text: package['package_name']);
    TextEditingController locationController = TextEditingController(text: package['package_location']);
    TextEditingController priceController = TextEditingController(text: package['package_price'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Edit Package", style: TextStyle(fontSize: 16, color: Colors.teal)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Package Name", labelStyle: TextStyle(color: Colors.black54),),
                  style: TextStyle(color: Colors.black),

                ),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(labelText: "Location", labelStyle: TextStyle(color: Colors.black54),),
                  style: TextStyle(color: Colors.black),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: "Price", labelStyle: TextStyle(color: Colors.black54),),
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
                _updatePackage(package['packageId'], nameController.text, locationController.text, double.tryParse(priceController.text) ?? 0.0);
                Navigator.of(context).pop();
              },
              child: Text("Save", style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  void _updatePackage(String packageId, String name, String location, double price) async {
    try {
      await _database
          .child('tour_packages')
          .child(widget.userId)
          .child('packages')
          .child(packageId)
          .update({
        'package_name': name,
        'package_location': location,
        'package_price': price,
      });
      // Refresh the package list after updating
      _fetchTourPackages();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating package: $e';
      });
    }
  }

  void _deletePackage(String packageId) async {
    try {
      await _database
          .child('tour_packages')
          .child(widget.userId)
          .child('packages')
          .child(packageId)
          .remove();
      // Refresh the package list after deleting
      _fetchTourPackages();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error deleting package: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tour Packages"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : ListView.builder(
        itemCount: _packages.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            margin: EdgeInsets.all(10.0),
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  // Display the image with rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _packages[index]['thumbnail'] ?? '',
                      height: 100, // Adjust height to make the image smaller
                      width: 100,  // Fixed width for image
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Text('Image not available'),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Package name
                        Text(
                          _packages[index]['package_name'] ?? 'No Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        // Package location
                        Text(
                          'Location: ${_packages[index]['package_location'] ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        // Package price
                        Text(
                          'Price: ${_packages[index]['package_price'] ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        // Package ID (Firebase-generated key)
                        Text(
                          'Package ID: ${_packages[index]['packageId'] ?? 'N/A'}',
                          style: TextStyle(
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
                            backgroundColor: Color(0xFFFFA726),
                            foregroundColor: Color(0xFF8D6E63),
                          ),
                          onPressed: () {
                            _showEditPackageDialog(_packages[index]);
                          },
                          child: Text("Edit"),
                        ),
                      ),
                      SizedBox(height: 8), // Spacing between buttons
                      // Delete Button
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            _deletePackage(_packages[index]['packageId']);
                          },
                          child: Text("Delete"),
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
    );
  }
}
