import 'package:drivers_app/packages/tour_package1.dart';
import 'package:drivers_app/packages/tour_package2.dart';
import 'package:drivers_app/packages/tour_package3.dart';
import 'package:drivers_app/packages/tour_package4.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const EarningsPage(userName: 'User', userId: ' ',), // Pass user name here
    );
  }
}
String? userId = FirebaseAuth.instance.currentUser?.uid;

class EarningsPage extends StatefulWidget {
  final String userName;
  final String userId;// Added parameter for the user's name

  const EarningsPage({super.key, required this.userName, required this.userId});


  @override
  _EarningsPageState createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _tourPackages = [];
  List<Map<String, dynamic>> _filteredTourPackages = [];
  List<Map<String, dynamic>> _sites = [];
  List<Map<String, dynamic>> _filteredSites = [];
  List<Map<String, dynamic>> _restaurants = [];
  List<Map<String, dynamic>> _filteredRestaurants = [];
  List<Map<String, dynamic>> _taxis = [];
  List<Map<String, dynamic>> _filteredTaxis = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = ''; // Search query for filtering

  @override
  void initState() {
    super.initState();
    _fetchTourPackages(); // Fetch tour packages on initialization
    _fetchSites(); // Fetch sites on initialization
    _fetchRestaurants(); // Fetch restaurants on initialization
    _fetchTaxis(); // Fetch taxis on initialization
  }

  void _fetchTourPackages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DatabaseEvent event = await _database.child('tour_packages').once();
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<dynamic, dynamic> packages = snapshot.value as Map<dynamic, dynamic>;

        packages.forEach((key, value) {
          Map<dynamic, dynamic> packageMap = value['packages'];
          packageMap.forEach((packageKey, packageValue) {
            Map<String, dynamic> packageData = Map<String, dynamic>.from(packageValue);
            _tourPackages.add(packageData);
          });
        });
        _filteredTourPackages = List.from(_tourPackages); // Initialize filtered list
      } else {
        setState(() {
          _errorMessage = 'No tour packages found.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching tour packages: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchSites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DatabaseEvent event = await _database.child('site_list').once();
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<dynamic, dynamic> sitesData = snapshot.value as Map<dynamic, dynamic>;

        sitesData.forEach((key, value) {
          Map<dynamic, dynamic> siteMap = value['sites'];
          siteMap.forEach((siteKey, siteValue) {
            Map<String, dynamic> siteData = Map<String, dynamic>.from(siteValue);
            _sites.add(siteData);
          });
        });
        _filteredSites = List.from(_sites); // Initialize filtered list
      } else {
        setState(() {
          _errorMessage = 'No sites found.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching sites: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchRestaurants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DatabaseEvent event = await _database.child('restaurant_list').once();
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<dynamic, dynamic> restaurantsData = snapshot.value as Map<dynamic, dynamic>;

        restaurantsData.forEach((key, value) {
          Map<dynamic, dynamic> restaurantMap = value['restaurants'];
          restaurantMap.forEach((restaurantKey, restaurantValue) {
            Map<String, dynamic> restaurantData = Map<String, dynamic>.from(restaurantValue);
            _restaurants.add(restaurantData);
          });
        });
        _filteredRestaurants = List.from(_restaurants); // Initialize filtered list
      } else {
        setState(() {
          _errorMessage = 'No restaurants found.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching restaurants: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchTaxis() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DatabaseEvent event = await _database.child('taxi_list').once();
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<dynamic, dynamic> taxiData = snapshot.value as Map<dynamic, dynamic>;

        taxiData.forEach((key, value) {
          Map<dynamic, dynamic> taxiMap = value['taxi'];
          taxiMap.forEach((taxiKey, taxiValue) {
            Map<String, dynamic> taxiInfo = Map<String, dynamic>.from(taxiValue);
            _taxis.add(taxiInfo);
          });
        });
        _filteredTaxis = List.from(_taxis); // Initialize filtered list
      } else {
        setState(() {
          _errorMessage = 'No taxis found.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching taxis: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterTourPackages(String query) {
    if (query.isEmpty) {
      _filteredTourPackages = List.from(_tourPackages);
    } else {
      _filteredTourPackages = _tourPackages.where((package) {
        final packageName = package['package_name'].toString().toLowerCase();
        return packageName.contains(query.toLowerCase());
      }).toList();
    }
    setState(() {
      _searchQuery = query; // Update search query
    });
  }

  void _filterSites(String query) {
    if (query.isEmpty) {
      _filteredSites = List.from(_sites);
    } else {
      _filteredSites = _sites.where((site) {
        final siteName = site['site_name'].toString().toLowerCase();
        return siteName.contains(query.toLowerCase());
      }).toList();
    }
    setState(() {
      _searchQuery = query; // Update search query
    });
  }

  void _filterRestaurants(String query) {
    if (query.isEmpty) {
      _filteredRestaurants = List.from(_restaurants);
    } else {
      _filteredRestaurants = _restaurants.where((restaurant) {
        final restaurantName = restaurant['restaurant_name'].toString().toLowerCase();
        return restaurantName.contains(query.toLowerCase());
      }).toList();
    }
    setState(() {
      _searchQuery = query; // Update search query
    });
  }

  void _filterTaxis(String query) {
    if (query.isEmpty) {
      _filteredTaxis = List.from(_taxis);
    } else {
      _filteredTaxis = _taxis.where((taxi) {
        final taxiModel = taxi['vehicle_model'].toString().toLowerCase();
        return taxiModel.contains(query.toLowerCase());
      }).toList();
    }
    setState(() {
      _searchQuery = query; // Update search query
    });
  }

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          'Hi - ${widget.userName}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // SizedBox to leave space between the AppBar and the buttons
          SizedBox(height: 16), // Adjust the height as needed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff149777), // Green button
                  foregroundColor: Colors.white, // White text
                ),
                child: const Text('Bins'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff149777), // Green button
                  foregroundColor: Colors.white, // White text
                ),
                child: const Text('Areas'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff149777), // Green button
                  foregroundColor: Colors.white, // White text
                ),
                child: const Text('Collectors'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff149777), // Green button
                  foregroundColor: Colors.white, // White text
                ),
                child: const Text('Vehicles'),
              ),
            ],
          ),
          // Display the selected tab content
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildTourPackagesTab();
      case 1:
        return _buildSitesTab();
      case 2:
        return _buildRestaurantsTab();
      case 3:
        return _buildTaxisTab();
      default:
        return Container();
    }
  }

  Widget _buildTourPackagesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: _filterTourPackages, // Filter on text change
            decoration: const InputDecoration(
              labelText: 'Search Bins',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            itemCount: _filteredTourPackages.length,
            itemBuilder: (context, index) {
              final package = _filteredTourPackages[index];
              return Card(
                margin: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Stack( // Use Stack to position the button
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                          child: Image.network(
                            package['thumbnail'],
                            fit: BoxFit.cover,
                            height: 350,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Bin ID: ${package['package_name'] ?? 'No Name'}',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Bin Size: \$${package['package_price'] ?? 'No Price'}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Waste Type: ${package['package_difficulty'] ?? 'Unknown'}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 12.0,
                      bottom: 12.0,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TourPackage1(
                                userName: widget.userName,
                                userId: widget.userId,// Ensure you're using the correct context
                                packageName: package['package_name'] ?? 'No Name',
                                packagePrice: package['package_price']?.toString() ?? 'No Price',
                                packageDuration: package['package_duration'] ?? 'Unknown',
                                packageThumbnail: package['thumbnail'] ?? '',
                                packageLocation: package['package_location']  ?? 'Unknown', // Get location safely
                                packageDescription: package['package_description'] ?? 'No Description', // Get description safely
                                packageDifficulty: package['package_difficulty'] ?? 'Not Specified', // Get difficulty safely
                              ),
                            ),
                          );
                          // Action for "See More" button
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF500B71),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('See More'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }



  Widget _buildSitesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: _filterSites, // Filter on text change
            decoration: const InputDecoration(
              labelText: 'Search Areas',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            itemCount: _filteredSites.length,
            itemBuilder: (context, index) {
              final site = _filteredSites[index];
              return Card(
                margin: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                          child: Image.network(
                            site['thumbnail'] ?? '',
                            fit: BoxFit.cover,
                            height: 350, // Adjusted the height to fit better
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Area Name: ${site['site_name'] ?? 'No Name'}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Location: ${site['site_location'] ?? 'Unknown'}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Time Window: ${site['site_opening_hours'] ?? 'Unknown'}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Waste Types Collected: ${site['site_entrance_fee'] ?? 'Unknown'}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 12.0,
                      bottom: 12.0,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TourPackage2(
                                userName: widget.userName,
                                userId: widget.userId, // Correct context reference
                                siteName: site['site_name'] ?? 'No Name',
                                siteDescription: site['site_description']?.toString() ?? 'No Description',
                                siteLocation: site['site_location'] ?? 'Unknown',
                                siteOpeningHours: site['site_opening_hours'] ?? 'Unknown',
                                siteEntranceFee: site['site_entrance_fee'] ?? 'No Entrance Fee',
                                siteKeyHighlight: site['site_key_highlight'] ?? 'Not Specified',
                                siteFacilities: site['site_facilities'] ?? 'Not Specified',
                                siteThumbnail: site['thumbnail'] ?? '',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF500B71),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('See More'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _buildRestaurantsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: _filterRestaurants, // Filter on text change
            decoration: const InputDecoration(
              labelText: 'Search Collectors',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            itemCount: _filteredRestaurants.length,
            itemBuilder: (context, index) {
              final restaurant = _filteredRestaurants[index];
              return Card(
                margin: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                          child: Image.network(
                            restaurant['thumbnail'] ?? '',
                            fit: BoxFit.cover,
                            height: 350, // Adjust the height to fit better
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Collector Name: ${restaurant['restaurant_name'] ?? 'No Name'}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Collector Area: ${restaurant['restaurant_opening_hours'] ?? 'Unknown'}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 12.0,
                      bottom: 12.0,
                      child: ElevatedButton(
                        onPressed: () {
                          // Corrected push navigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TourPackage3(
                                userName: widget.userName,
                                userId: widget.userId, // Correct context reference
                                restaurantName: restaurant['restaurant_name'] ?? 'No Name',
                                restaurantLocation: restaurant['restaurant_location']?.toString() ?? 'No Location',
                                restaurantCuisine: restaurant['restaurant_cuisine'] ?? 'Unknown',
                                restaurantOpeningHours: restaurant['restaurant_opening_hours'] ?? 'Unknown',
                                restaurantLiquorAvailability: restaurant['restaurant_liquor_availability'] ?? 'Unknown',
                                restaurantSeatingCapacity: restaurant['restaurant_seating'] ?? 'Not Specified',
                                restaurantParkingAvailable: restaurant['restaurant_parking_available'] ?? 'Not Specified',
                                restaurantImage: restaurant['thumbnail'] ?? '',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF500B71),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('See More'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }



  Widget _buildTaxisTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: _filterTaxis, // Filter on text change
            decoration: const InputDecoration(
              labelText: 'Search Garbage Truck',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            itemCount: _filteredTaxis.length,
            itemBuilder: (context, index) {
              final taxi = _filteredTaxis[index];
              return Card(
                margin: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                          child: Image.network(
                            taxi['thumbnail'] ?? '',
                            fit: BoxFit.cover,
                            height: 350, // Adjusted height for better proportion
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Vehicle Type: ${taxi['vehicle_number'] ?? 'No Model'}',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Vehicle ID: ${taxi['vehicle_type']?.toString() ?? 'No Price'}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Vehicle Capacity: ${taxi['vehicle_model']?.toString() ?? 'No Price'}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Driver Name: ${taxi['vehicle_color'] ?? 'Unknown'}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 12.0,
                      bottom: 12.0,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TourPackage4(
                                userName: widget.userName,
                                userId: widget.userId, // Correct context reference
                                taxiType: taxi['vehicle_type'] ?? 'No Name',
                                taxiNumber: taxi['vehicle_number']?.toString() ?? 'No Location',
                                taxiModel: taxi['vehicle_model'] ?? 'Unknown',
                                taxiColor: taxi['vehicle_color'] ?? 'Unknown',
                                taxiSeatingCapacity: taxi['vehicle_seating_capacity'] ?? 'Unknown',
                                taxiLuggageCapacity: taxi['vehicle_luggage_capacity'] ?? 'Not Specified',
                                taxiFeatures: taxi['vehicle_features'] ?? 'Not Specified',
                                taxiPrice: taxi['vehicle_price']?.toString() ?? 'Not Specified',
                                taxiImage: taxi['thumbnail'] ?? '',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF500B71), // Changed to solid color for visibility
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('See More'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

}
