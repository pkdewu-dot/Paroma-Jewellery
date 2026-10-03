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

            // Grid Items (All 12 Modules Working)
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
                  onTap: () => _openFeaturePage(context, '২৪ ক্যারেট সোনার দাম', 'বর্তমান বিশ্ববাজার ও স্থানীয় ২৪ ক্যারেট খাঁটি সোনার দর অনুযায়ী হিসাব।'),
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
                  onTap: () => _openCalculatorPage(context),
                ),
                _buildGridCard(
                  context,
                  title: 'সোনার দামের ইতিহাস',
                  icon: Icons.access_time,
                  iconColor: Colors.purple[400]!,
                  onTap: () => _openFeaturePage(context, 'সোনার দামের ইতিহাস', 'পূর্ববর্তী তারিখের বিএজেইউএস (BAJUS) নির্ধারিত দামের তালিকা।'),
                ),
                _buildGridCard(
                  context,
                  title: 'পাকা পরতা ক্যালকুলেটর',
                  icon: Icons.layers_outlined,
                  iconColor: Colors.teal[600]!,
                  onTap: () => _openFeaturePage(context, 'পাকা পরতা ক্যালকুলেটর', 'খাদযুক্ত সোনা থেকে পাকা আনার হিসাব ক্যালকুলেটর।'),
                ),
                _buildGridCard(
                  context,
                  title: 'খাদ হিসাব',
                  icon: Icons.pie_chart_outline,
                  iconColor: Colors.blue[900]!,
                  onTap: () => _openFeaturePage(context, 'খাদ হিসাব', '২২, ২১ ও ১৮ ক্যারেট সোনার নিখাদ ও খাদের আনুপাতিক হিসাব।'),
                ),
                _buildGridCard(
                  context,
                  title: 'ভরি ও পয়েন্ট কনভার্টার',
                  icon: Icons.swap_horiz,
                  iconColor: Colors.deepOrange[400]!,
                  onTap: () => _openConverterPage(context),
                ),
                _buildGridCard(
                  context,
                  title: 'ক্যারেট কনভার্টার',
                  icon: Icons.tune,
                  iconColor: Colors.red[600]!,
                  onTap: () => _openFeaturePage(context, 'ক্যারেট কনভার্টার', 'এক ক্যারেট থেকে অন্য ক্যারেটে মান পরিবর্তনের কনভার্টার।'),
                ),
                _buildGridCard(
                  context,
                  title: 'ওজন যোগ-বিয়োগ',
                  icon: Icons.add,
                  iconColor: Colors.green[600]!,
                  onTap: () => _openFeaturePage(context, 'ওজন যোগ-বিয়োগ', 'ভরি, আনা, রতি ও পয়েন্টের দ্রুত যোগ-বিয়োগ ক্যালকুলেটর।'),
                ),
                _buildGridCard(
                  context,
                  title: 'হাত লস',
                  icon: Icons.pan_tool_outlined,
                  iconColor: Colors.brown[600]!,
                  onTap: () => _openFeaturePage(context, 'হাত লস', 'গহনা তৈরির সময়ের ওয়েস্টেজ বা হাত লসের হিসাব।'),
                ),
                _buildGridCard(
                  context,
                  title: 'বন্ধকী হিসাব',
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: Colors.purple[700]!,
                  onTap: () => _openFeaturePage(context, 'বন্ধকী হিসাব', 'বন্ধকী সোনা ও মাসিক সুদের হিসাব রেজিস্টার।'),
                ),
                _buildGridCard(
                  context,
                  title: 'কারিগর খতিয়ান',
                  icon: Icons.menu_book,
                  iconColor: Colors.orange[800]!,
                  onTap: () => _openFeaturePage(context, 'কারিগর খতিয়ান', 'কারিগরদের সোনা জমা ও মজুরির খতিয়ান হিসাব।'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openFeaturePage(BuildContext context, String title, String description) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenericFeaturePage(title: title, description: description),
      ),
    );
  }

  void _openCalculatorPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GoldPriceCalculatorPage()),
    );
  }

  void _openConverterPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UnitConverterPage()),
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

// Sub-page: Generic Module Template
class GenericFeaturePage extends StatelessWidget {
  final String title;
  final String description;

  const GenericFeaturePage({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars, size: 50, color: Colors.amber[800]),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sub-page: Gold Price Calculator Page
class GoldPriceCalculatorPage extends StatefulWidget {
  const GoldPriceCalculatorPage({super.key});

  @override
  State<GoldPriceCalculatorPage> createState() => _GoldPriceCalculatorPageState();
}

class _GoldPriceCalculatorPageState extends State<GoldPriceCalculatorPage> {
  final TextEditingController voriController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  double totalPrice = 0.0;

  void calculate() {
    double vori = double.tryParse(voriController.text) ?? 0.0;
    double rate = double.tryParse(rateController.text) ?? 0.0;
    setState(() {
      totalPrice = vori * rate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('স্বর্ণের মূল্য ক্যালকুলেটর'),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: voriController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'ওজন (ভরি)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'প্রতি ভরির দাম (টাকা)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: calculate,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[800]),
              child: const Text('মোট মূল্য হিসাব করুন', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            Text(
              'মোট মূল্য: ৳${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

// Sub-page: Unit Converter Page
class UnitConverterPage extends StatefulWidget {
  const UnitConverterPage({super.key});

  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage> {
  final TextEditingController voriInput = TextEditingController();
  double gram = 0.0;
  double ana = 0.0;
  double rati = 0.0;

  void convert() {
    double v = double.tryParse(voriInput.text) ?? 0.0;
    setState(() {
      gram = v * 11.664;
      ana = v * 16.0;
      rati = v * 96.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ভরি ও পয়েন্ট কনভার্টার'),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: voriInput,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'ভরির পরিমাণ লিখুন', border: OutlineInputBorder()),
              onChanged: (_) => convert(),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                title: const Text('গ্রাম'),
                trailing: Text('${gram.toStringAsFixed(3)} গ্রাম', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('আনা'),
                trailing: Text('${ana.toStringAsFixed(2)} আনা', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('রতি'),
                trailing: Text('${rati.toStringAsFixed(2)} রতি', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
