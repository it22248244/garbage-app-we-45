import 'package:drivers_app/payment/payment_page4.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import this package for date formatting

class BookingDetailsPage4 extends StatefulWidget {
  final String userName;
  final String userId;
  final String taxiModel;
  final String taxiSeatingCapacity;
  final String taxiPrice;
  final String image; // Added parameter for the tour image
   // Added tour duration parameter

  // Constructor to accept the tour details
  const BookingDetailsPage4({
    Key? key,
    required this.userName,
    required this.userId,
    required this.taxiModel,
    required this.taxiSeatingCapacity,
    required this.taxiPrice,
    required this.image,
    // Added tour duration parameter
  }) : super(key: key);

  @override
  _BookingDetailsPage4State createState() => _BookingDetailsPage4State();
}

class _BookingDetailsPage4State extends State<BookingDetailsPage4> {
  DateTime? startDate;
  DateTime? endDate;
  bool agreeToTerms = false;

  final TextEditingController nicController = TextEditingController();
  final TextEditingController emergencyContactController = TextEditingController();
  final TextEditingController userNameController = TextEditingController(); // New controller

  @override
  void initState() {
    super.initState();
    userNameController.text = widget.userName; // Initialize with the passed userName
  }

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
                SizedBox(height: 8),
                _buildInfoRow(Icons.directions_car, 'Taxi Model: ${widget.taxiModel}'),
                SizedBox(height: 8),
                _buildInfoRow(Icons.people, 'Seating Capacity: ${widget.taxiSeatingCapacity}'),
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
                  'Total Price: ${widget.taxiPrice} (2 Days)', // Adjust this as necessary
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                _buildTextField('User Name', controller: userNameController), // Use the controller here
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
                  child: Text('Customize Tour', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    // Handle customize tour
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: Size(double.infinity, 50),
                  ),
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

                      String userName = userNameController.text; // Use the controller for the user name
                      String userId = widget.userId;
                      String taxiModel = widget.taxiModel;
                      String taxiSeatingCapacity = widget.taxiSeatingCapacity;
                      String taxiPrice = widget.taxiPrice;
                      String dateRange = '${DateFormat('d MMM yyyy').format(startDate!)} - ${DateFormat('d MMM yyyy').format(endDate!)}';
                      String nic = nicController.text;
                      String contact = emergencyContactController.text;
                      String image = widget.image;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage4(
                            userName: userName,
                            userId: userId,
                            taxiModel: taxiModel,
                            taxiSeatingCapacity: taxiSeatingCapacity,
                            taxiPrice: taxiPrice,
                            date: dateRange,
                            nic: nic,
                            contact: contact,
                            image: image,
                            // Pass tourDuration to PaymentPage4
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal),
        SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.black)),
      ],
    );
  }
}
