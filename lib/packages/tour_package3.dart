import 'package:drivers_app/pages/dashboard.dart';
import 'package:drivers_app/payment/booking_details3.dart';
import 'package:flutter/material.dart';

class TourPackage3 extends StatelessWidget {
  final String userName;
  final String userId;
  final String restaurantName;
  final String restaurantLocation;
  final String restaurantCuisine;
  final String restaurantOpeningHours;
  final String restaurantLiquorAvailability;
  final String restaurantSeatingCapacity;
  final String restaurantParkingAvailable;
  final String restaurantImage;

  const TourPackage3({
    super.key,
    required this.userName,
    required this.userId,
    required this.restaurantName,
    required this.restaurantLocation,
    required this.restaurantCuisine,
    required this.restaurantOpeningHours,
    required this.restaurantLiquorAvailability,
    required this.restaurantSeatingCapacity,
    required this.restaurantParkingAvailable,
    required this.restaurantImage,
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
        title: Text(restaurantName, style: const TextStyle(color: Colors.white)), // Use restaurantName
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
                      restaurantImage,
                      height: 400,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Collector Name: $restaurantName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact Number: $restaurantCuisine',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff149777),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Collector ID: $restaurantLocation',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Collect Locations: $restaurantOpeningHours',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Attached Vehicle ID: $restaurantLiquorAvailability',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Special Notes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    child: const Text(
                      'Route on map',
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

  static Widget _buildInfoContainer(IconData icon, String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
