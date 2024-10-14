import 'package:flutter/material.dart';
import 'package:drivers_app/bookings/success.dart';
import 'package:awesome_dialog/awesome_dialog.dart'; // Make sure to import this package
import 'package:drivers_app/pages/dashboard.dart';

class Booking2 extends StatelessWidget {
  final String userName; // Declare userName
  final String userId; // Declare userId

  // Constructor to accept userName and userId
  Booking2({Key? key, required this.userName, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileInfo(),
                      SizedBox(height: 20),
                      _buildRatings(),
                      SizedBox(height: 20),
                      Text(
                        'Select Package',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      _buildPackageOptions(),
                      SizedBox(height: 20),
                      _buildNextButton(context), // Pass context here
                      SizedBox(height: 10),
                      _buildBackButton(context),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.teal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.arrow_back, color: Colors.white),
              SizedBox(width: 25),
            ],
          ),
          Icon(Icons.notifications, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return SizedBox(
      width: double.infinity, // Set the width to full screen width
      child: Card(
        color: Color(0xffeceff1), // Set card background color
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center( // Center the CircleAvatar
                child: CircleAvatar(
                  radius: 100, // Adjusted radius for better visual balance
                  backgroundImage: AssetImage('assets/images/avatarman.png'),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Experience: 10 Years',
                style: TextStyle(color: Colors.black),
              ),
              Text(
                'Service: 2-20 people',
                style: TextStyle(color: Colors.black),
              ),
              Text(
                'Certification: G9, IATA 5',
                style: TextStyle(color: Colors.black),
              ),
              Text(
                'Areas: Anuradhapura, Yala, Sigiriya, Polonnaruwa',
                style: TextStyle(color: Colors.black),
              ),
              Text(
                'Expertise: Wildlife, History, Culture',
                style: TextStyle(color: Colors.black),
              ),
              Text(
                'Languages: English, Sinhala, Tamil, Chinese, Russian, Japanese, German',
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 8),
              Text(
                'Description: I am specialized in creating memorable and personalized tours.',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
                textAlign: TextAlign.center, // Center-align the description
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatings() {
    return Card(
      color: Color(0xffeceff1), // Set card background color to white
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Row(
              children: List.generate(5, (index) => Icon(Icons.star, color: Colors.amber, size: 20)),
            ),
            SizedBox(width: 8),
            Text('4.8 (4056 reviews)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(String title, String duration, String price, String backgroundImage) {
    return Card(
      elevation: 2, // Optional: Add elevation to the card
      child: Stack(
        children: [
          // Background Image for the Card
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundImage), // Background image for the card
                  fit: BoxFit.cover, // Adjust the image to cover the whole area
                ),
              ),
            ),
          ),
          // Card Content
          Padding(
            padding: const EdgeInsets.all(16.0), // Add padding to the card content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // Example text style
                ),
                SizedBox(height: 4),
                Text(
                  duration,
                  style: TextStyle(color: Colors.white), // Example text style
                ),
                SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(color: Colors.white), // Example text style
                ),
                SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {
                    // Add action for the button
                  },
                  child: Text('View', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageOptions() {
    return Row(
      children: [
        Expanded(
          child: _buildPackageCard(
            'Yala Tour',
            '2 Days',
            'Rs. 25000',
            'assets/images/avatarman.png', // Background image for Yala Tour card
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildPackageCard(
            'Sigiriya Tour',
            '3 Days',
            'Rs. 38000',
            'assets/images/avatarman.png', // Background image for Sigiriya Tour card
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Show the AwesomeDialog when the button is pressed
          AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            animType: AnimType.topSlide,
            showCloseIcon: true,
            title: "Warning",
            desc: "Are you sure to verify this booking",
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.bottomSlide,
                showCloseIcon: true,
                title: "Success",
                desc: "Verified the tourist successfully!!!",
                btnOkOnPress: () {
                  // Navigate to Dashboard if the OK button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Dashboard(userName: userName, userId: userId), // Pass userName and userId
                    ),
                  );
                },
                dialogBackgroundColor: Colors.white, // Set the background color of the success dialog to white
                titleTextStyle: TextStyle(color: Colors.black), // Set the title text color
                descTextStyle: TextStyle(color: Colors.black),  // Set the description text color
              ).show();
            },
            dialogBackgroundColor: Colors.white, // Set the background color of the warning dialog to white
            titleTextStyle: TextStyle(color: Colors.black), // Set the title text color
            descTextStyle: TextStyle(color: Colors.black),  // Set the description text color
          ).show();
        },
        child: Text('Verify Booking', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xff149777),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }




  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Dashboard(userName: userName, userId: userId), // Pass userName and userId
            ),
          );
        },
        child: Text('Back', style: TextStyle(color: Color(0xFF8D6E63))),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(0xff75103b),
      backgroundColor: Color(0xff149777),
      unselectedItemColor: Colors.white,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
