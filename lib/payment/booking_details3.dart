import 'package:drivers_app/payment/payment_page3.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class BookingDetailsPage3 extends StatefulWidget {
  final String userName; // Correct parameter names
  final String userId;
  final String restaurantName;
  final String restaurantOpeningHours;
  final String restaurantPrice;
  final String image;

  const BookingDetailsPage3({
    Key? key,
    required this.userName,
    required this.userId,
    required this.restaurantName,
    required this.restaurantOpeningHours,
    required this.restaurantPrice,
    required this.image,
  }) : super(key: key);

  @override
  _BookingDetailsPage3State createState() => _BookingDetailsPage3State();
}

class _BookingDetailsPage3State extends State<BookingDetailsPage3> {
  DateTime? startDate;
  DateTime? endDate;
  bool agreeToTerms = false;

  final TextEditingController idController = TextEditingController();
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
      ),
      body: Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Card(
          color: Colors.white, // Set the card background color to white
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Restaurant: ${widget.restaurantName}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 16),
                _buildInfoRow(Icons.local_offer, 'Cost: ${widget.restaurantPrice}'),
                SizedBox(height: 8),
                _buildInfoRow(Icons.access_time, 'Opening Hours: ${widget.restaurantOpeningHours}'),
                SizedBox(height: 16),
                Text(
                  'Select Dates',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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
                          style: const TextStyle(color: Colors.black),
                        ),
                        Icon(Icons.calendar_today, color: Colors.teal),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'ID / Passport Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 8),
                _buildTextField('ID / Passport Number', controller: idController),
                SizedBox(height: 16),
                _buildTextField(
                  'Emergency Contact',
                  controller: emergencyContactController,
                  prefixText: '+94 ',
                  keyboardType: TextInputType.phone,
                ),
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
                    ),
                    Expanded(
                      child: Text(
                        'I agree with the terms and conditions.',
                        style: TextStyle(color: Colors.black),
                      ),
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
                        idController.text.isNotEmpty &&
                        emergencyContactController.text.isNotEmpty) {

                      String formattedDateRange =
                          '${DateFormat('d MMM yyyy').format(startDate!)} - ${DateFormat('d MMM yyyy').format(endDate!)}';

                      // Pass parameters to PaymentPage3
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage3(
                            userName: widget.userName,
                            userId: widget.userId,
                            restaurantName: widget.restaurantName,
                            restaurantOpeningHours: widget.restaurantOpeningHours,
                            restaurantPrice: widget.restaurantPrice,
                            dateRange: formattedDateRange,
                            userID: idController.text,
                            emergencyContact: emergencyContactController.text,
                            restaurantImage: widget.image,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please complete all fields and agree to the terms.')),
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

  Widget _buildTextField(String label, {String? prefixText, TextEditingController? controller, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black), // Text color inside the text field
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        labelStyle: TextStyle(color: Colors.black), // Label text color
        hintStyle: TextStyle(color: Colors.black), // Hint text color
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
      ),
    );
  }
}
