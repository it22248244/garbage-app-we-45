import 'package:drivers_app/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class PaymentPage extends StatelessWidget {
  final String tourName;
  final String userId;
  final String tourDuration;
  final String tourPrice;
  final String userName;
  final String image;
  final String nic; // Added NIC parameter
  final String contact; // Added contact parameter
  final String date; // Added date parameter

  // Constructor to accept the passed booking details
  const PaymentPage({
    Key? key,
    required this.userName,
    required this.userId,
    required this.tourName,
    required this.tourDuration,
    required this.tourPrice,
    required this.image,
    required this.nic, // Include NIC in the constructor
    required this.contact, // Include contact in the constructor
    required this.date, // Include date in the constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Details', style: TextStyle(color: Colors.black)),
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
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Summary Section
                _buildSectionTitle('Summary'),
                SizedBox(height: 10),
                _buildBookingSummary(),
                SizedBox(height: 20),

                // Personal Details Section
                _buildSectionTitle('Details'),
                SizedBox(height: 10),
                _buildPersonalDetails(),
                SizedBox(height: 20),

                // Payment Details Section

                // Confirm and Cancel Buttons
                _buildPaymentButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _buildBookingSummary() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.person, 'Bin ID: $tourName'),
              _buildInfoRow(Icons.access_time, 'Type: $tourDuration'),
              _buildInfoRow(Icons.local_offer, 'Bin Name: $tourName'),
              _buildInfoRow(Icons.calendar_today, 'Date: $date'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.person, 'Collector Name: $userName'),
        _buildInfoRow(Icons.credit_card, 'Collector ID: $nic'),
        _buildInfoRow(Icons.phone, 'Truck ID: $contact'),
      ],
    );
  }


  Widget _buildEstimatedValue() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estimated Waste', style: TextStyle(color: Colors.black)),
            Text(
              '$tourPrice',
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
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
          child: Text('Verify', style: TextStyle(color: Colors.white)),
          onPressed: () {
            // Show success dialog
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.bottomSlide,
              showCloseIcon: true,
              title: "Success",
              desc: "Verification successfully completed!",
              btnOkOnPress: () {
                //Navigate to Dashboard or other page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Dashboard(userName: userName, userId: userId,),
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
          child: Text('Cancel Verify', style: TextStyle(color: Color(0xFF8D6E63))),
          onPressed: () {
            // Show warning dialog
            AwesomeDialog(
              context: context,
              dialogType: DialogType.warning,
              animType: AnimType.topSlide,
              showCloseIcon: true,
              title: "Warning",
              desc: "Are you sure you want to cancel this verification?",
              btnCancelOnPress: () {},
              btnOkOnPress: () {
                // Show success dialog if payment is canceled
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.success,
                  animType: AnimType.bottomSlide,
                  showCloseIcon: true,
                  title: "Success",
                  desc: "Verfication has been canceled successfully!",
                  btnOkOnPress: () {
                    //Navigate to Dashboard or other page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Dashboard(userName: userName, userId: userId,),
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

}
