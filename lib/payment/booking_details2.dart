import 'package:drivers_app/payment/payment_page.dart';
import 'package:drivers_app/payment/payment_page2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import this package for date formatting

class BookingDetailsPage2 extends StatefulWidget {
  final String siteName;
  final String userId;
  final String siteOpeningHours;
  final String siteEntranceFee;
  final String userName; // Add userId parameter
  final String image; // Added parameter for the tour image

  // Constructor to accept the tour details
  const BookingDetailsPage2({
    Key? key,
    required this.userName,
    required this.userId, // Include userId in the constructor
    required this.siteName, // Changed to siteName
    required this.siteOpeningHours, // Changed to siteOpeningHours
    required this.siteEntranceFee, // Changed to siteEntranceFee
    required this.image,
  }) : super(key: key);

  @override
  _BookingDetailsPage2State createState() => _BookingDetailsPage2State();
}

class _BookingDetailsPage2State extends State<BookingDetailsPage2> {
  DateTime? startDate;
  DateTime? endDate;
  bool agreeToTerms = false;

  final TextEditingController nicController = TextEditingController();
  final TextEditingController emergencyContactController = TextEditingController();

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: startDate ?? DateTime.now(),
        end: endDate ?? DateTime.now().add(Duration(days: 1)), // Default range of one day
      ),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.teal,
            colorScheme: ColorScheme.light(primary: Colors.teal),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child ?? SizedBox(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Booking Details', style: TextStyle(color: Colors.black)),
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
      body: Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Site Name: ${widget.siteName}', // Updated to show siteName
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                _buildInfoRow(Icons.local_offer, 'Entrance Fee: ${widget.siteEntranceFee}'),
                SizedBox(height: 8),
                _buildInfoRow(Icons.access_time, 'Opening Hours: ${widget.siteOpeningHours}'),
                SizedBox(height: 16),
                Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDateRange(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          startDate != null && endDate != null
                              ? '${DateFormat('d MMM yyyy').format(startDate!)} - ${DateFormat('d MMM yyyy').format(endDate!)}'
                              : 'Select date range',
                          style: TextStyle(color: Colors.black),
                        ),
                        Icon(Icons.calendar_today, color: Colors.teal),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Total Price: ${widget.siteEntranceFee} (for selected dates)', // Adjusted for entrance fee
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                _buildTextField(widget.userName),
                SizedBox(height: 16),
                _buildTextField('NIC / Passport', controller: nicController),
                SizedBox(height: 16),
                _buildTextField('Emergency Contact Number',
                    controller: emergencyContactController,
                    prefixText: '+94 ',
                    keyboardType: TextInputType.phone),
                SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: Colors.red,
                    ),
                    Expanded(
                      child: Text('I agree with terms and conditions',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  child: Text('Book Now', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    if (startDate != null &&
                        endDate != null &&
                        agreeToTerms &&
                        nicController.text.isNotEmpty &&
                        emergencyContactController.text.isNotEmpty) {
                      // Handle booking
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booking Successful!')),
                      );

                      String userName = widget.userName;
                      String userId = widget.userId;
                      String siteName = widget.siteName;
                      String siteOpeningHours = widget.siteOpeningHours;
                      String siteEntranceFee = widget.siteEntranceFee;
                      String dateRange = '${DateFormat('d MMM yyyy').format(startDate!)} - ${DateFormat('d MMM yyyy').format(endDate!)}';
                      String nic = nicController.text;
                      String contact = emergencyContactController.text;
                      String image = widget.image;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage2(
                            userName: userName,
                            userId: userId,
                            // Pass the userId to PaymentPage
                            tourName: siteName,
                            tourDuration: siteOpeningHours,
                            tourPrice: siteEntranceFee,
                            date: dateRange,
                            nic: nic,
                            contact: contact,
                            image: image,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Please fill all fields and agree to terms.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
                SizedBox(height: 16), // Add space between buttons
                ElevatedButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to the previous page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Use a different color for the Cancel button
                    minimumSize: Size(double.infinity, 50),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal, size: 20),
        SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.black)),
      ],
    );
  }

  Widget _buildTextField(String label, {
    String? prefixText,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black), // Set text color to black
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal), // Keep the border color teal
        ),
        labelStyle: TextStyle(color: Colors.black),
      ),
    );
  }
}
