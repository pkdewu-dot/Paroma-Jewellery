import 'package:flutter/material.dart';

void main() {
  runApp(const JewelleryApp());
}

class JewelleryApp extends StatelessWidget {
  const JewelleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Made by Pk',
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF5252),
              Color(0xFFFF7A59),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ১. কাস্টম অ্যাপ বার (Jewellery Calculator এর জায়গায় Made by Pk)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: const Color(0xFFFF3B30),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Made by Pk',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade900,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'LIVE\nPRICE',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.calculate, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    const Icon(Icons.facebook, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    const Icon(Icons.more_vert, color: Colors.white, size: 24),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // ২. উপরের ফাঁকা অংশে দোকানের নাম ও ঠিকানা সংবলিত সুন্দর ব্যানার
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B0000), // গাঢ় মেরুন/লাল ব্যাকগ্রাউন্ড
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'পরমা জুয়েলার্স',
                              style: TextStyle(
                                color: Color(0xFFFFD700), // সোনালী কালার
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'কাপুড়িয়া পট্টি, চৌরাস্তা, যশোর',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ৩. নোটিফিকেশন মেসেজ বার
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white54),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'লাইভ আপডেট পেতে  ',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check, color: Colors.white, size: 16),
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

                      const SizedBox(height: 12),

                      // ৪. গ্রিড বাটনসমূহ (১১ টি অপশন)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.9,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildWhiteCard(
                              title: '২৪ ক্যারেট সোনার\nদাম',
                              icon: Icons.star_border,
                              iconColor: Colors.amber,
                            ),
                            _buildWhiteCard(
                              title: 'আজকের বাজার',
                              icon: Icons.storefront_outlined,
                              iconColor: Colors.pink,
                            ),
                            _buildWhiteCard(
                              title: 'স্বর্ণের মূল্য\nক্যালকুলেটর',
                              icon: Icons.calculate_outlined,
                              iconColor: Colors.blue,
                            ),
                            _buildWhiteCard(
                              title: 'সোনার দামের\nইতিহাস',
                              icon: Icons.access_time,
                              iconColor: Colors.purple,
                            ),
                            _buildWhiteCard(
                              title: 'পাকা পরতা\nক্যালকুলেটর',
                              icon: Icons.layers_outlined,
                              iconColor: Colors.teal,
                            ),
                            _buildWhiteCard(
                              title: 'খাদ হিসাব',
                              icon: Icons.pie_chart_outline,
                              iconColor: Colors.indigo,
                            ),
                            _buildWhiteCard(
                              title: 'ভরি ও পয়েন্ট\nকনভার্টার',
                              icon: Icons.swap_horiz,
                              iconColor: Colors.deepOrange,
                            ),
                            _buildWhiteCard(
                              title: 'ক্যারেট কনভার্টার',
                              icon: Icons.tune,
                              iconColor: Colors.red,
                            ),
                            _buildWhiteCard(
                              title: 'ওজন যোগ-বিয়োগ',
                              icon: Icons.add,
                              iconColor: Colors.green,
                            ),
                            _buildWhiteCard(
                              title: 'হাত লস',
                              icon: Icons.back_hand_outlined,
                              iconColor: Colors.brown,
                            ),
                            _buildWhiteCard(
                              title: 'বন্ধকী হিসাব',
                              icon: Icons.account_balance_wallet_outlined,
                              iconColor: Colors.deepPurple,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteCard({
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 32),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
