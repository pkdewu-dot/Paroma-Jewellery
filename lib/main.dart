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
      title: 'Paroma Jewellery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFF4B4B),
        scaffoldBackgroundColor: const Color(0xFFFF6B6B),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3B3B),
        elevation: 0,
        title: const Text(
          'Made by Pk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue[800],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'LIVE\nPRICE',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
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
                color: const Color(0xFF500000),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text(
                    'পরমা জুয়েলার্স',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'কাপুড়িয়া পট্টি, চৌরাস্তা, যশোর',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Live Update Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8E8E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'লাইভ আপডেট পেতে',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF50C878),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'নোটিফিকেশন চালু আছে',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Grid Items (All 12 Features from screenshot)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.85,
              children: [
                _buildGridCard(
                  context,
                  title: '২৪ ক্যারেট সোনার দাম',
                  icon: Icons.star_border,
                  iconColor: Colors.amber[700]!,
                  onTap: () {},
                ),
                _buildGridCard(
                  context,
                  title: 'আজকের বাজার',
                  icon: Icons.storefront,
                  iconColor: Colors.pink[400]!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TodaysMarketPage()),
                    );
                  },
                ),
                _buildGridCard(
                  context,
                  title: 'স্বর্ণের মূল্য ক্যালকুলেটর',
                  icon: Icons.calculate_outlined,
                  iconColor: Colors.blue[600]!,
                  onTap: () {},
                ),
                _buildGridCard(
                  context,
                  title: 'সোনার দামের ইতিহাস',
                  icon: Icons.access_time,
                  iconColor: Colors.purple[400]!,
                  onTap: () {},
                ),
                _buildGridCard(
                  context,
                  title: 'পাকা পরতা ক্যালকুলেটর',
                  icon: Icons.layers_outlined,
                  iconColor: Colors.teal[600]!,
                  onTap: () {},
                ),
                _buildGridCard(
                  context,
                  title: 'খাদ হিসাব',
                  icon: Icons.pie_chart_outline,
                  iconColor: Colors.blue[900]!,
                  onTap: () {},
                ),
                _buildGridCard(
                  context,
                  title: 'ভরি ও পয়েন্ট কনভার্টার',
                  icon: Icons.swap_horiz,
                  iconColor: Colors.deepOrange[400]!,
                  onTap: () {},
                ),
                _buildGridCard(
                  context,
                  title: 'ক্যারেট কনভার্টার',
                  icon: Icons.tune,
                  iconColor: Colors.red[600]!,
                  onTap: () {},
                ),
                _buildGridCard(
                  context,
                  title: 'ওজন যোগ-বিয়োগ',
                  icon: Icons.add,
                  iconColor: Colors.green[600]!,
                  onTap: () {},
                ),
                _buildGridCard(
                  context,
                  title: 'হাত লস',
                  icon: Icons.pan_tool_outlined,
                  iconColor: Colors.brown[600]!,
                  onTap: () {},
                ),
                _buildGridCard(
                  context,
                  title: 'বন্ধকী হিসাব',
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: Colors.purple[700]!,
                  onTap: () {},
                ),
                _buildGridCard(
                  context,
                  title: 'কারিগর খতিয়ান',
                  icon: Icons.menu_book,
                  iconColor: Colors.orange[800]!,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: iconColor),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
