import 'package:flutter/material.dart';

class DriversPage extends StatelessWidget {
  const DriversPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drivers Page'),
      ),
      body: Center(
        child: const Text('Welcome to the Drivers Page!'),
      ),
    );
  }
}
