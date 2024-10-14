import 'package:drivers_app/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class PaymentPage3 extends StatelessWidget {
  final String userName;
  final String userId;
  final String restaurantName;
  final String restaurantOpeningHours;
  final String restaurantPrice;
  final String dateRange;
  final String userID;
  final String emergencyContact;
  final String restaurantImage;

  const PaymentPage3({
    Key? key,
    required this.userName,
    required this.userId,
    required this.restaurantName,
    required this.restaurantOpeningHours,
    required this.restaurantPrice,
    required this.dateRange,
    required this.userID,
    required this.emergencyContact,
    required this.restaurantImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Payment Details', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.teal),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Card(
          color: Colors.white, // Main card color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Summary Section
                _buildSectionTitle('Booking Summary'),
                SizedBox(height: 10),
                _buildBookingSummary(),
                SizedBox(height: 20),

                // Personal Details Section
                _buildSectionTitle('Personal Details'),
                SizedBox(height: 10),
                _buildPersonalDetails(),
                SizedBox(height: 20),

                // Payment Details Section
                _buildSectionTitle('Payment Details'),
                SizedBox(height: 10),
                _buildPaymentFields(),
                SizedBox(height: 20),

                // Confirm and Cancel Buttons
                _buildPaymentButtons(context),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _buildBookingSummary() {
    return Card(
      color: Colors.white, // Ensure booking summary card is white
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.person, 'Guide Name: $restaurantName'),
            _buildInfoRow(Icons.access_time, 'Duration: $restaurantOpeningHours'),
            _buildInfoRow(Icons.local_offer, 'Package: $restaurantPrice'),
            _buildInfoRow(Icons.calendar_today, 'Date: $dateRange'),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetails() {
    return Card(
      color: Colors.white, // Ensure personal details card is white
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.person, 'Name: $userName'),
            _buildInfoRow(Icons.credit_card, 'NIC: $userID'),
            _buildInfoRow(Icons.phone, 'Emergency Contact: $emergencyContact'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentFields() {
    return Card(
      color: Colors.white, // Ensure payment fields card is white
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Card Number', keyboardType: TextInputType.number),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Expiry Date', keyboardType: TextInputType.datetime),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildTextField('CVV', keyboardType: TextInputType.number, obscureText: true),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildEstimatedValue(),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimatedValue() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estimated Value', style: TextStyle(color: Colors.black)),
            Text(
              'Rs. $restaurantPrice',
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Method', style: TextStyle(color: Colors.black)),
            Image.asset(
              'assets/images/creditcard.png', // Ensure this image exists in your assets folder
              width: 80,
              height: 60,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          child: Text('Confirm Payment', style: TextStyle(color: Colors.white)),
          onPressed: () {
            // Show success dialog
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.bottomSlide,
              showCloseIcon: true,
              title: "Success",
              desc: "Payment successfully completed!",
              btnOkOnPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Dashboard(userName: userName, userId: userId),
                  ),
                );
              },
              dialogBackgroundColor: Colors.white,
              titleTextStyle: TextStyle(color: Colors.black),
              descTextStyle: TextStyle(color: Colors.black),
            ).show();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            minimumSize: Size(double.infinity, 50),
          ),
        ),
        SizedBox(height: 8),
        ElevatedButton(
          child: Text('Cancel Payment', style: TextStyle(color: Color(0xFF8D6E63))),
          onPressed: () {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.warning,
              animType: AnimType.topSlide,
              showCloseIcon: true,
              title: "Warning",
              desc: "Are you sure you want to cancel this payment?",
              btnCancelOnPress: () {},
              btnOkOnPress: () {
                // Show success dialog if payment is canceled
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.success,
                  animType: AnimType.bottomSlide,
                  showCloseIcon: true,
                  title: "Success",
                  desc: "Payment has been canceled successfully!",
                  btnOkOnPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Dashboard(userName: userName, userId: userId),
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
            backgroundColor: Colors.orange,
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String info) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal),
        SizedBox(width: 8),
        Expanded(child: Text(info, style: TextStyle(color: Colors.black))),
      ],
    );
  }

  Widget _buildTextField(String label, {
    String? prefixText,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
        ),
        labelStyle: TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
        ),
      ),
      style: TextStyle(color: Colors.black),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xff149777),
      selectedItemColor: Colors.pink,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
