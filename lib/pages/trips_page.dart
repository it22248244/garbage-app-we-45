import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:drivers_app/bookings/Booking1.dart';
import 'package:drivers_app/bookings/Booking2.dart';
import 'package:awesome_dialog/awesome_dialog.dart'; // Make sure to import this package
import 'package:drivers_app/pages/dashboard.dart';

import '../global/global_var.dart';

class TripsPage extends StatefulWidget {
  final String userName; // Added parameter for the user's name

  const TripsPage({super.key, required this.userName}); // Updated constructor

  @override
  _TripsPageState createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  final TextEditingController _searchController = TextEditingController();

  // Sample data for each section
  List<Guide> _guides = [
    Guide('Namal Perera', 'Rs. 12500 / Day', 'assets/images/avatarman.png', 4.5, 4096),
    Guide('Antonie Jayakody', 'Rs. 13500 / Day', 'assets/images/avatarman.png', 4.8, 2085),
    Guide('Shavin De Silva', 'Rs. 13800 / Day', 'assets/images/avatarman.png', 4.7, 96),
    Guide('Thevin Athuadda', 'Rs. 14200 / Day', 'assets/images/avatarman.png', 4.6, 580),
  ];

  List<Guide> _hotels = [
    Guide('Hotel Sunshine', 'Rs. 8000 / Night', 'assets/images/avatarman.png', 4.2, 1200),
    Guide('The Grand Hotel', 'Rs. 12000 / Night', 'assets/images/avatarman.png', 4.6, 950),
    Guide('Cozy Inn', 'Rs. 6000 / Night', 'assets/images/avatarman.png', 4.0, 500),
    Guide('Luxury Stay', 'Rs. 15000 / Night', 'assets/images/avatarman.png', 4.8, 700),
  ];

  List<Guide> _taxiDrivers = [
    Guide('Thevin Samishka', 'He is awesome. meet you soon', 'assets/images/avatarman.png', 4.7, 1),
    Guide('Don Nipuna', 'He\'s such a kind man. well done brother. highly recomended', 'assets/images/avatarman.png', 4.5, 1),
    Guide('Thiwanka Wijerathne', 'i visited lots of places. he is the safest driver i met', 'assets/images/avatarman.png', 4.6, 1),
    Guide('Ruwanya Hettiarachchi', 'That car was very comfotable, meetr you soon broh', 'assets/images/avatarman.png', 4.4, 1),
  ];

  List<Guide> _restaurants = [
    Guide('Spicy House', 'Rs. 500 / Meal', 'assets/images/avatarman.png', 4.9, 800),
    Guide('Food Palace', 'Rs. 700 / Meal', 'assets/images/avatarman.png', 4.3, 650),
    Guide('Dine & Wine', 'Rs. 900 / Meal', 'assets/images/avatarman.png', 4.5, 400),
    Guide('The Food Station', 'Rs. 800 / Meal', 'assets/images/avatarman.png', 4.6, 520),
  ];

  List<Guide> _filteredGuides = [];
  List<Guide> _filteredHotels = [];
  List<Guide> _filteredTaxiDrivers = [];
  List<Guide> _filteredRestaurants = [];

  bool _showGuides = true; // Track which section to show
  bool _showHotels = false; // Track if Hotels section is shown
  bool _showTaxiDrivers = false; // Track if Taxi Drivers section is shown
  bool _showRestaurants = false; // Track if Restaurants section is shown

  @override
  void initState() {
    super.initState();
    // Initialize the filtered lists to show all items at start
    _filteredGuides = _guides;
    _filteredHotels = _hotels;
    _filteredTaxiDrivers = _taxiDrivers;
    _filteredRestaurants = _restaurants;
  }

  void _filterGuides(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredGuides = _guides;
      } else {
        _filteredGuides = _guides.where((guide) {
          return guide.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _filterHotels(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredHotels = _hotels;
      } else {
        _filteredHotels = _hotels.where((hotel) {
          return hotel.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _filterTaxiDrivers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTaxiDrivers = _taxiDrivers;
      } else {
        _filteredTaxiDrivers = _taxiDrivers.where((driver) {
          return driver.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _filterRestaurants(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRestaurants = _restaurants;
      } else {
        _filteredRestaurants = _restaurants.where((restaurant) {
          return restaurant.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _updateSection(bool isGuides, bool isHotels, bool isTaxiDrivers, bool isRestaurants) {
    setState(() {
      _showGuides = isGuides;
      _showHotels = isHotels;
      _showTaxiDrivers = isTaxiDrivers;
      _showRestaurants = isRestaurants;
      _searchController.clear(); // Clear search input when changing sections
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff149777),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff000000)),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
        title: Text(
          'Hi ${widget.userName}', // Display the dynamic user name
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xff149777)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Tour Packages....',
                        hintStyle: const TextStyle(color: Colors.black), // Set hint text color to black
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.black), // Set text color to black
                      onChanged: (value) {
                        if (_showGuides) {
                          _filterGuides(value);
                        } else if (_showHotels) {
                          _filterHotels(value);
                        } else if (_showTaxiDrivers) {
                          _filterTaxiDrivers(value);
                        } else if (_showRestaurants) {
                          _filterRestaurants(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _updateSection(true, false, false, false); // Show Tour Guides
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showGuides ? const Color(0xff149777) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Dashboard',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateSection(false, true, false, false); // Show Hotels
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showHotels ? const Color(0xff149777) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Bookings',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateSection(false, false, true, false); // Show Taxi Drivers
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showTaxiDrivers ? const Color(0xff149777) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Reviews',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // List View for Guides, Hotels, Taxi Drivers, or Restaurants
            Expanded(
              child: _showGuides
                  ? Scaffold(
                appBar: AppBar(
                  centerTitle: true, // Center the title
                  title: Text(
                    'Profit Analysis',
                    style: TextStyle(color: Colors.black), // Change text color to black
                  ),
                  backgroundColor: Color(0xFFFFA726), // Set background color to yellow
                  elevation: 10,
                  // Remove the shadow effect if needed
                  leading: SizedBox.shrink(), // Remove the leading icon (arrow)
                ),

                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Line Chart
                        SizedBox(
                          width: MediaQuery.of(context).size.width, // Full width
                          height: 350, // Height of the line chart
                          child: Card(
                            elevation: 4,
                            margin: const EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: true),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: true),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(color: Colors.blueAccent, width: 2),
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      isCurved: true,
                                      color: Colors.blue,
                                      belowBarData: BarAreaData(show: false),
                                      spots: [
                                        FlSpot(0, 1),
                                        FlSpot(1, 2),
                                        FlSpot(2, 1.5),
                                        FlSpot(3, 3),
                                        FlSpot(4, 2.5),
                                        FlSpot(5, 4),
                                        FlSpot(6, 3),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Bar Chart
                        SizedBox(
                          width: MediaQuery.of(context).size.width, // Full width
                          height: 350, // Height of the bar chart
                          child: Card(
                            elevation: 4,
                            margin: const EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: BarChart(
                                BarChartData(
                                  barGroups: [
                                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 1, color: Colors.blue)]),
                                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 2, color: Colors.green)]),
                                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 1.5, color: Colors.red)]),
                                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 3, color: Colors.orange)]),
                                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 2.5, color: Colors.purple)]),
                                    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 4, color: Colors.teal)]),
                                    BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 3, color: Colors.cyan)]),
                                  ],
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: true),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: true),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(color: Colors.black, width: 1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Pie Chart
                        SizedBox(
                          width: MediaQuery.of(context).size.width, // Full width
                          height: 350, // Height of the pie chart
                          child: Card(
                            elevation: 2,
                            margin: const EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      value: 25,
                                      color: Colors.blue,
                                      title: 'Guide A',
                                      radius: 30,
                                    ),
                                    PieChartSectionData(
                                      value: 30,
                                      color: Colors.green,
                                      title: 'Guide B',
                                      radius: 30,
                                    ),
                                    PieChartSectionData(
                                      value: 20,
                                      color: Colors.red,
                                      title: 'Guide C',
                                      radius: 30,
                                    ),
                                    PieChartSectionData(
                                      value: 25,
                                      color: Colors.orange,
                                      title: 'Guide D',
                                      radius: 30,
                                    ),
                                  ],
                                  borderData: FlBorderData(show: false),
                                  centerSpaceRadius: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )

              : _showHotels
                  ? ListView.builder(
                itemCount: _filteredHotels.length,
                itemBuilder: (context, index) {
                  final hotel = _filteredHotels[index];
                  return GestureDetector(
                    onTap: () {
                      // Replace 'exampleUserName' and 'exampleUserId' with actual values.
                      String userName = 'exampleUserName'; // Get this value dynamically
                      String userId = 'exampleUserId';     // Get this value dynamically

                      if (index == 0) { // Check if it is the first card
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Booking1(userName: userName, userId: userId)), // Pass required parameters
                        );
                      } else if (index == 1) { // Check if it is the second card
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Booking2(userName: userName, userId: userId)), // Navigate to Booking2
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('This hotel is not available for details.')),
                        );
                      }
                    },
                    child: Card(
                      color: const Color(0xffeceff1),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(hotel.imagePath),
                        ),
                        title: Text(
                          hotel.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel.price,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16.0),
                                const SizedBox(width: 4.0),
                                Text(
                                  '${hotel.rating} (${hotel.reviews} reviews)',
                                  style: const TextStyle(fontSize: 14, color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )


                  : _showTaxiDrivers
                  ? ListView.builder(
                itemCount: _filteredTaxiDrivers.length,
                itemBuilder: (context, index) {
                  final driver = _filteredTaxiDrivers[index];
                  return GestureDetector(
                    onTap: () {
                      // String userName = 'exampleUserName'; // Get this value dynamically
                      // String userId = 'exampleUserId';     // Get this value dynamically
                      //
                      // if (index == 0) { // Check if it is the first card
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => Review1()), // Pass required parameters
                      //   );
                      // } else if (index == 1) { // Check if it is the second card
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => Booking2(userName: userName, userId: userId)), // Navigate to Booking2
                      //   );
                      // } else {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     const SnackBar(content: Text('This hotel is not available for details.')),
                      //   );
                      // }
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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.lightBlue),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver.price,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16.0),
                                const SizedBox(width: 4.0),
                                Text(
                                  '${driver.rating} (${driver.reviews} reviews)',
                                  style: const TextStyle(fontSize: 14, color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Add the Reply button in the trailing position
                        trailing: ElevatedButton(
                          onPressed: () {

                            String replyMessage = ''; // To store the input from the text field

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
                                      replyMessage = value; // Capture the user's input
                                    },
                                    style: const TextStyle(color: Colors.black),
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Reply Message',
                                      labelStyle: TextStyle(color: Colors.black),
                                      fillColor: Colors.black,
                                      focusedBorder: OutlineInputBorder( // Border when the TextField is focused
                                        borderSide: BorderSide(color: Colors.black), // Focused border color
                                      ),
                                      enabledBorder: OutlineInputBorder( // Default border color when not focused
                                        borderSide: BorderSide(color: Colors.black), // Default border color
                                      ),
                                       // General outline border
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
                                    desc: "Reply sent successfully: $replyMessage", // Show the reply message in the second dialog
                                    btnOkOnPress: () {
                                      //Navigate to Dashboard if the OK button is pressed

                                    },
                                    dialogBackgroundColor: Colors.white, // Set the background color of the success dialog to white
                                    titleTextStyle: const TextStyle(color: Colors.black), // Set the title text color
                                    descTextStyle: const TextStyle(color: Colors.black),  // Set the description text color
                                  ).show();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter a reply message before sending.')),
                                  );
                                }
                              },
                              dialogBackgroundColor: Colors.white, // Set the background color of the warning dialog to white
                              titleTextStyle: const TextStyle(color: Colors.black), // Set the title text color
                              descTextStyle: const TextStyle(color: Colors.black),  // Set the description text color
                            ).show();

                            // Add your reply button action here
                            print('Reply button pressed for ${driver.name}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Button color green
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0), // Rounded corners
                            ),
                          ),
                          child: const Text(
                            'Reply',
                            style: TextStyle(color: Colors.white), // Text color white
                          ),
                        ),
                      ),
                    ),
                  );

                },

              )
                  : _showRestaurants
                  ? ListView.builder(
                itemCount: _filteredRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = _filteredRestaurants[index];
                  return GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This restaurant is not available for details.')),
                      );
                    },
                    child: Card(
                      color: const Color(0xffeceff1),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(restaurant.imagePath),
                        ),
                        title: Text(
                          restaurant.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.price,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16.0),
                                const SizedBox(width: 4.0),
                                Text(
                                  '${restaurant.rating} (${restaurant.reviews} reviews)',
                                  style: const TextStyle(fontSize: 14, color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
                  : Container(), // Fallback widget if none of the conditions are met
            )

          ],
        ),
      ),
    );
  }
}

class Guide {
  final String name;
  final String price;
  final String imagePath;
  final double rating;
  final int reviews;

  Guide(this.name, this.price, this.imagePath, this.rating, this.reviews);
}