import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({Key? key}) : super(key: key);

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  double? goldPriceBDT;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchGoldPrice();
  }

  Future<void> fetchGoldPrice() async {
    final url = Uri.parse('https://www.goldapi.io/api/XAU/BDT');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['price'] != null) {
          setState(() {
            goldPriceBDT = (data['price'] as num).toDouble();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'সোনার দামের তথ্য পাওয়া যায়নি।';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage =
              'ডাটা লোড করতে সমস্যা হয়েছে (${response.statusCode})';
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
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              errorMessage = '';
                            });

                            fetchGoldPrice();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('আবার চেষ্টা করুন'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        size: 80,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'লাইভ গোল্ড প্রাইস (BDT)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
