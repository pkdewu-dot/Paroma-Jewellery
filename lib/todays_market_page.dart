import 'package:flutter/material.dart';

class TodaysMarketPage extends StatelessWidget {
  const TodaysMarketPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আজকের বাজার'),
        backgroundColor: Colors.amber[800],
      ),
      body: const Center(
        child: Text(
          'আজকের বাজার পেজ',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
