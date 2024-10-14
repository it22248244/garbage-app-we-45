import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool _showTaxiDrivers = true; // Placeholder to trigger the list rendering
  final List<Driver> _filteredTaxiDrivers = [
    Driver('John Doe', '5000', 4.5, 100, 'assets/images/driver1.png'),
    Driver('Jane Smith', '4500', 4.2, 80, 'assets/images/driver2.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
      ),
      body: _showTaxiDrivers
          ? ListView.builder(
        itemCount: _filteredTaxiDrivers.length,
        itemBuilder: (context, index) {
          final driver = _filteredTaxiDrivers[index];
          return GestureDetector(
            onTap: () {
              // Handle navigation or other interactions here
            },
            child: Card(
              color: const Color(0xffeceff1),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                leading: CircleAvatar(
                  backgroundImage: AssetImage(driver.imagePath),
                ),
                title: Text(
                  driver.name,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.price,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.amber, size: 16.0),
                        const SizedBox(width: 4.0),
                        Text(
                          '${driver.rating} (${driver.reviews} reviews)',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    String replyMessage = ''; // To store input from text field

                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.topSlide,
                      showCloseIcon: true,
                      title: "Warning",
                      desc: "Are you sure to verify this booking",
                      body: Column(
                        children: [
                          const Text(
                            'Type your reply:',
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            onChanged: (value) {
                              replyMessage = value; // Capture user's input
                            },
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Reply Message',
                              labelStyle: TextStyle(color: Colors.black),
                              fillColor: Colors.black,
                              focusedBorder: OutlineInputBorder(
                                // Border when focused
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              enabledBorder: OutlineInputBorder(
                                // Border when not focused
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {
                        if (replyMessage.isNotEmpty) {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.success,
                            animType: AnimType.bottomSlide,
                            showCloseIcon: true,
                            title: "Success",
                            desc: "Reply sent successfully: $replyMessage",
                            btnOkOnPress: () {
                              // Handle further actions after success
                            },
                            dialogBackgroundColor: Colors.white,
                            titleTextStyle:
                            const TextStyle(color: Colors.black),
                            descTextStyle:
                            const TextStyle(color: Colors.black),
                          ).show();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please enter a reply message before sending.')),
                          );
                        }
                      },
                      dialogBackgroundColor: Colors.white,
                      titleTextStyle:
                      const TextStyle(color: Colors.black),
                      descTextStyle:
                      const TextStyle(color: Colors.black),
                    ).show();

                    print('Reply button pressed for ${driver.name}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Button color green
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(20.0), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'Reply',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        },
      )
          : const Center(child: Text('No taxi drivers to show.')),
    );
  }
}

class Driver {
  final String name;
  final String price;
  final double rating;
  final int reviews;
  final String imagePath;

  Driver(this.name, this.price, this.rating, this.reviews, this.imagePath);
}
