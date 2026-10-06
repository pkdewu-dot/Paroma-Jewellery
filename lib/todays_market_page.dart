import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({Key? key}) : super(key: key);

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  // আপনার দেয়া API Key
  final String apiKey = "01578e7e7dfa3bb8617e40afc0a3848f";
  
  double? goldPriceBDT;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchGoldPrice();
  }

  Future<void> fetchGoldPrice() async {
    // GoldAPI.io তে BDT কারেন্সিতে দাম চাওয়ার জন্য Endpoints
    final url = Uri.parse('https://www.goldapi.io/api/XAU/BDT');

    try {
      final response = await http.get(
        url,
        headers: {
          'x-access-token': apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // 'price' ফিল্ড থেকে প্রতি গ্রাম/আউন্সের BDT রেট নেওয়া হচ্ছে
          goldPriceBDT = (data['price'] as num).toDouble();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'ডাটা লোড করতে সমস্যা হয়েছে (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'নেটওয়ার্ক এরর: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আজকের সোনার বাজার'),
        backgroundColor: Colors.amber[700],
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : errorMessage.isNotEmpty
                ? Text(errorMessage, style: const TextStyle(color: Colors.red))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars_rounded, size: 80, color: Colors.amber),
                      const SizedBox(height: 20),
                      const Text(
                        'লাইভ গোল্ড প্রাইস (BDT)',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '৳ ${goldPriceBDT?.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
