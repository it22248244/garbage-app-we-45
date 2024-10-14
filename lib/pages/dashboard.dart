import "package:drivers_app/pages/earnings_page.dart";
import "package:drivers_app/pages/home_page.dart";
import "package:drivers_app/pages/profile_page.dart";
import "package:drivers_app/pages/trips_page.dart";
import "package:drivers_app/pages/help_desk.dart";
import "package:flutter/material.dart";

class Dashboard extends StatefulWidget {
  final String userName; // Add userName parameter to the Dashboard
  final String userId; // Add userId parameter

  const Dashboard({super.key, required this.userName, required this.userId}); // Update constructor

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  TabController? controller;
  int indexSelected = 0;

  void onBarItemClicked(int i) {
    setState(() {
      indexSelected = i;
      controller!.index = indexSelected;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: [
          EarningsPage(userName: widget.userName, userId: widget.userId),
          HomePage(),// Pass userName to EarningsPage
          ProfilePage(userId: widget.userId),
          const HelpDesk(), // Use the HelpDesk page here
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: "Route",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: "Help",
          ),
        ],
        currentIndex: indexSelected,
        unselectedItemColor: Color(0xffffffff), // Color of unselected items
        selectedItemColor: Color(0xff75103b), // Color of selected items
        backgroundColor: Color(0xff149777), // Set the background color to green
        showSelectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onBarItemClicked,
      ),
    );
  }
}
