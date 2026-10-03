import 'package:flutter/material.dart';
import 'todays_market_page.dart';

void main() {
  runApp(const ParomaJewelleryApp());
}

class ParomaJewelleryApp extends StatelessWidget {
  const ParomaJewelleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'পরমা জুয়েলার্স',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFFF6F61),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': '২৪ ক্যারেট সোনার দাম', 'icon': Icons.star_border, 'page': null},
      {'title': 'আজকের বাজার', 'icon': Icons.store, 'page': const TodaysMarketPage()},
      {'title': 'স্বর্ণের মূল্য ক্যালকুলেটর', 'icon': Icons.calculate_outlined, 'page': null},
      {'title': 'সোনার দামের ইতিহাস', 'icon': Icons.access_time, 'page': null},
      {'title': 'পাকা পরতা ক্যালকুলেটর', 'icon': Icons.layers_outlined, 'page': null},
      {'title': 'খাদ হিসাব', 'icon': Icons.pie_chart_outline, 'page': null},
      {'title': 'ভরি ও পয়েন্ট কনভার্টার', 'icon': Icons.compare_arrows, 'page': null},
      {'title': 'ক্যারেট কনভার্টার', 'icon': Icons.tune, 'page': null},
      {'title': 'ওজন যোগ-বিয়োগ', 'icon': Icons.add, 'page': null},
      {'title': 'ঘাট লস', 'icon': Icons.back_hand_outlined, 'page': null},
      {'title': 'বন্ধকী হিসাব', 'icon': Icons.account_balance_wallet_outlined, 'page': null},
      {'title': 'কারিগর খতিয়ান', 'icon': Icons.menu_book, 'page': null},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3B30),
        elevation: 0,
        title: const Text(
          'Made by Pk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'LIVE\nPRICE',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calculate, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.facebook, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF4A0000),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    'পরমা জুয়েলার্স',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'কাপুড়িয়া পট্টি, চৌরাস্তা, যশোর',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Live Update Notification Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE55345),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'লাইভ আপডেট পেতে',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'নোটিফিকেশন চালু আছে',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Grid Menu Items
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menuItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return InkWell(
                  onTap: () {
                    if (item['page'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => item['page']),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'],
                          size: 36,
                          color: Colors.purple.shade700,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            item['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
