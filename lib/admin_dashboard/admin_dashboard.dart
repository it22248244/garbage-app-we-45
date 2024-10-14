import "package:drivers_app/admin_dashboard/resturants.dart";
import "package:drivers_app/admin_dashboard/sites.dart";
import "package:drivers_app/admin_dashboard/tour_guide.dart";
import "package:drivers_app/admin_dashboard/transportation.dart";
import "package:flutter/material.dart";

class AdminDashboard extends StatefulWidget {
  final String userName;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const AdminDashboard({
    Key? key,
    required this.userName,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  }) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
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
          TourGuide(userName: widget.userName,
            userId: widget.userId,
            firstName: widget.firstName,
            lastName: widget.lastName,
            email: widget.email,
            phone: widget.phone,),
          Sites(userName: widget.userName,
          userId: widget.userId,
             firstName: widget.firstName,
             lastName: widget.lastName,
            email: widget.email,
             phone: widget.phone,),
          Restaurants(userName: widget.userName,
            userId: widget.userId,
            firstName: widget.firstName,
            lastName: widget.lastName,
            email: widget.email,
            phone: widget.phone,),
          Transportation(userName: widget.userName,
            userId: widget.userId,
            firstName: widget.firstName,
            lastName: widget.lastName,
            email: widget.email,
            phone: widget.phone,),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Bins",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: "Areas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree),
            label: "Collectors",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Vehicles",
          ),
        ],
        currentIndex: indexSelected,
        unselectedItemColor: Colors.white,
        selectedItemColor: Color(0xff75103b),
        backgroundColor: Color(0xff149777),
        showSelectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onBarItemClicked,
      ),
    );
  }
}
