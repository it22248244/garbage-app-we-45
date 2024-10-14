import 'package:drivers_app/pages/dashboard.dart';
import 'package:flutter/material.dart';

class TourPackage2 extends StatelessWidget {
  final String userName;
  final String userId;
  final String siteName;
  final String siteDescription;
  final String siteLocation;
  final String siteThumbnail;
  final String siteOpeningHours;
  final String siteEntranceFee;
  final String siteKeyHighlight;
  final String siteFacilities;

  const TourPackage2({
    super.key,
    required this.userName,
    required this.userId,
    required this.siteName,
    required this.siteDescription,
    required this.siteLocation,
    required this.siteThumbnail,
    required this.siteOpeningHours,
    required this.siteEntranceFee,
    required this.siteKeyHighlight,
    required this.siteFacilities,
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
        title: Text(siteName, style: const TextStyle(color: Colors.white)), // Updated to use siteName
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
                      siteThumbnail,
                      height: 350,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Area Name : $siteName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Waste type collected: $siteEntranceFee',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff149777),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Collecting Time: $siteOpeningHours',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Collecting Days: $siteLocation',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Special Collections',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    siteKeyHighlight,
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pick Up Days',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    siteFacilities,
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'description',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    siteDescription,
                    style: const TextStyle(color: Colors.black),
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
