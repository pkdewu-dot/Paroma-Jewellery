import 'package:flutter/material.dart';

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({super.key});

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আজকের বাজার'),
        backgroundColor: const Color(0xFF800000),
      ),
      body: const Center(
        child: Text('আজকের বাজার পেজ তৈরি হচ্ছে...'),
      ),
    );
  }
}
