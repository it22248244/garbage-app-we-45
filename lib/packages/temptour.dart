import 'package:drivers_app/pages/dashboard.dart';
import 'package:drivers_app/payment/booking_details.dart';
import 'package:flutter/material.dart';

class TourPackage1 extends StatelessWidget {
  final String userName; // Add userName property
  final String userId;
  final String tourName;
  final String tourDuration;
  final String tourPrice;
  final String image;

  // Constructor to accept parameters
  const TourPackage1({
    super.key,
    required this.userName,
    required this.userId,
    required this.tourName,
    required this.tourDuration,
    required this.tourPrice,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: Text(tourName, style: TextStyle(color: Colors.white)), // Use this.tourName
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
          padding: const EdgeInsets.all(40.0),
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset('$image'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'About',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '$tourPrice',
                              style: TextStyle(
                                color: Color(0xff149777),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Embark on an unforgettable adventure through Yala National Park, Sri Lanka\'s most famous wildlife sanctuary.',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextButton(
                          child: const Text(
                            'Read more',
                            style: TextStyle(color: Color(0xff149777)),
                          ),
                          onPressed: () {
                            // Handle read more action
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Ratings and Reviews',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: const [
                            Icon(Icons.star, color: Colors.amber),
                            Icon(Icons.star, color: Colors.amber),
                            Icon(Icons.star, color: Colors.amber),
                            Icon(Icons.star, color: Colors.amber),
                            Icon(Icons.star, color: Colors.amber),
                            SizedBox(width: 8),
                            Text(
                              '4.8 (4056 reviews)',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoContainer(
                              Icons.access_time,
                              '$tourDuration',
                              'Duration',
                            ),
                            _buildInfoContainer(
                              Icons.landscape,
                              '3 of 5',
                              'Difficulty',
                            ),
                            _buildInfoContainer(
                              Icons.thermostat,
                              '32°C',
                              'Climate',
                            ),
                          ],
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
                            'Book Now',
                            style: TextStyle(color: Color(0xFF8D6E63)),
                          ),
                          onPressed: () {
                            this.userName;
                            this.userId;
                            this.tourName;
                            this.tourDuration;
                            this.tourPrice;
                            this.image;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingDetailsPage(userName:userName, userId:userId, tourName: tourName, tourDuration:tourDuration, tourPrice:tourPrice, image:image),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            minimumSize: const Size(double.infinity, 50),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xff149777),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
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
