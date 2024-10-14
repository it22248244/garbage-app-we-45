import 'package:drivers_app/pages/dashboard.dart';
import 'package:flutter/material.dart';

class TourPackage4 extends StatelessWidget {
  final String userName;
  final String userId;
  final String taxiType;
  final String taxiNumber;
  final String taxiModel;
  final String taxiColor;
  final String taxiSeatingCapacity;
  final String taxiLuggageCapacity;
  final String taxiFeatures;
  final String taxiPrice;
  final String taxiImage;

  const TourPackage4({
    super.key,
    required this.userName,
    required this.userId,
    required this.taxiType,
    required this.taxiNumber,
    required this.taxiModel,
    required this.taxiColor,
    required this.taxiSeatingCapacity,
    required this.taxiLuggageCapacity,
    required this.taxiFeatures,
    required this.taxiPrice,
    required this.taxiImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: Text(taxiModel, style: const TextStyle(color: Colors.white)), // Use taxi model as title
        backgroundColor: const Color(0xff149777),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            color: Colors.white,
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      taxiImage,
                      height: 350,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Vehicle ID: $taxiType',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vehicle Capacity : $taxiModel',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vehicle Type: $taxiNumber',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Assigned Collection Area: $taxiSeatingCapacity',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Service Schedule: $taxiLuggageCapacity',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Driver Name: $taxiColor',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fuel Type: $taxiFeatures',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Maintenance History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    taxiPrice,
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    child: const Text(
                      'Route on Map',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Dashboard(userName: userName, userId: userId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff149777),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    child: const Text(
                      'Go Back',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
