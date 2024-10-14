import 'package:flutter/material.dart';
import 'package:drivers_app/packages/tour_package1.dart';

class EarningsPage extends StatefulWidget {
  final String userName; // Added parameter for the user's name

  const EarningsPage({super.key, required this.userName}); // Updated constructor

  @override
  _EarningsPageState createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  final TextEditingController _searchController = TextEditingController();

  // Sample data for each section
  List<Guide> _guides = [
    Guide('Jethawanaramaya Temple', 'Rs. 12500 / Day', 'assets/images/site1.jpg', 4.5, "2 days"),
    Guide('Sigiriya', 'Rs. 13500 / Day', 'assets/images/site2.webp', 4.8, "3 days"),
    Guide('Japahuwa', 'Rs. 13800 / Day', 'assets/images/site3.jpg', 4.7, "7 days"),
    Guide('Temple of tooth relic', 'Rs. 14200 / Day', 'assets/images/site4.jpeg', 4.6, "5 days"),
  ];

  List<Guide> _hotels = [
    Guide('Hotel Sunshine', 'Rs. 8000 / Night', 'assets/images/hotel1.jpg', 4.2, "1200"),
    Guide('The Grand Hotel', 'Rs. 12000 / Night', 'assets/images/hotel2.webp', 4.6, "950"),
    Guide('Cozy Inn', 'Rs. 6000 / Night', 'assets/images/hotel3.webp', 4.0, "500"),
    Guide('Luxury Stay', 'Rs. 15000 / Night', 'assets/images/hotel4.jpg', 4.8, "700"),
  ];

  List<Guide> _taxiDrivers = [
    Guide('Malaka hewawitharana', 'Rs. 500 / Ride', 'assets/images/taxi1.jpg', 4.7, "300"),
    Guide('Lochana Sanderuth', 'Rs. 600 / Ride', 'assets/images/taxi2.jpeg', 4.5, "250"),
    Guide('Raveesh Gunathilake', 'Rs. 550 / Ride', 'assets/images/taxi3.jpg', 4.6, "150"),
    Guide('Danuka alvis', 'Rs. 650 / Ride', 'assets/images/taxi4.jpeg', 4.4, "180"),
  ];

  List<Guide> _restaurants = [
    Guide('Spicy House', 'Rs. 500 / Meal', 'assets/images/resturant1.jpg', 4.9, "800"),
    Guide('Food Palace', 'Rs. 700 / Meal', 'assets/images/resturant2.jpg', 4.3, "650"),
    Guide('Dine & Wine', 'Rs. 900 / Meal', 'assets/images/resturant3.jpg', 4.5, "400"),
    Guide('The Food Station', 'Rs. 800 / Meal', 'assets/images/resturant4.jpg', 4.6, "520"),
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
        backgroundColor: Color(0xff149777),
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
                  Icon(Icons.search, color: Color(0xff149777)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search',
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
                    backgroundColor: _showGuides ? Color(0xff149777) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Tour Guide',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateSection(false, true, false, false); // Show Hotels
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showHotels ? Color(0xff149777) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Hotels',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateSection(false, false, true, false); // Show Taxi Drivers
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showTaxiDrivers ? Color(0xff149777) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Taxi Drivers',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateSection(false, false, false, true); // Show Restaurants
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showRestaurants ? Color(0xff149777) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Restaurants',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Displaying the selected section
            // Displaying the selected section
            Expanded(
              child: _showGuides
                  ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two columns
                  childAspectRatio: 0.75, // Aspect ratio for cards
                  crossAxisSpacing: 10, // Spacing between columns
                  mainAxisSpacing: 10, // Spacing between rows
                ),
                itemCount: _filteredGuides.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Replace 'exampleUserName' and 'exampleUserId' with actual values.
                      String userName = widget.userName; // Use the dynamic user name
                      String userId = 'exampleUserId';
                      String tourName = _filteredGuides[index].name;
                      String tourPrice = _filteredGuides[index].price;
                      String tourDuration = _filteredGuides[index].reviews;
                      String image = _filteredGuides[index].imagePath;// Get this value dynamically

                      if (index == 0) { // Check if it is the first card
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TourPackage1(userName: userName, userId: userId, tourName: tourName, tourDuration: tourDuration, tourPrice:tourPrice, image: image), // Pass userName to TourPackage1
                          ),
                        );
                      } else if (index == 1) { // Check if it is the second card
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TourPackage1(userName: userName, userId: userId, tourName: tourName, tourDuration: tourDuration, tourPrice:tourPrice, image: image), // Pass userName to TourPackage1
                          ),
                        );
                      }else if (index == 2) { // Check if it is the second card
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TourPackage1(userName: userName, userId: userId, tourName: tourName, tourDuration: tourDuration, tourPrice:tourPrice, image: image), // Pass userName to TourPackage1
                          ),
                        );
                      }else if (index == 3) { // Check if it is the second card
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TourPackage1(userName: userName, userId: userId, tourName: tourName, tourDuration: tourDuration, tourPrice:tourPrice, image: image), // Pass userName to TourPackage1
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('This hotel is not available for details.')),
                        );
                      }
                    },

                    child: _buildGuideItem(_filteredGuides[index]),
                    // Your card-building function
                  );
                },
              )

                  : _showHotels
                  ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _filteredHotels.length,
                itemBuilder: (context, index) {
                  return _buildGuideItem(_filteredHotels[index]);
                },
              )
                  : _showTaxiDrivers
                  ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _filteredTaxiDrivers.length,
                itemBuilder: (context, index) {
                  return _buildGuideItem(_filteredTaxiDrivers[index]);
                },
              )
                  : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _filteredRestaurants.length,
                itemBuilder: (context, index) {
                  return _buildGuideItem(_filteredRestaurants[index]);
                },
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(Guide guide) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Displaying image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              guide.imagePath,
              height: 350,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              guide.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              guide.price,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text('${guide.rating}', style: const TextStyle(fontSize: 14, color: Colors.black)),
                const SizedBox(width: 8),
                Text('(${guide.reviews} reviews)', style: const TextStyle(fontSize: 14, color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sample Guide model
class Guide {
  final String name;
  final String price;
  final String imagePath;
  final double rating;
  final String reviews;

  Guide(this.name, this.price, this.imagePath, this.rating, this.reviews);
}
