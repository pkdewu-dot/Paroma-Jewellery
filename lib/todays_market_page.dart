import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({Key? key}) : super(key: key);

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  String selectedUnit = 'Vori'; // ডিফল্ট একক: Vori (ভরি)
  bool isLoading = true;
  bool hasError = false;

  // সোনা ও রূপার রেটের ডেটা রাখার ম্যাপ
  Map<String, Map<String, String>> goldPrices = {};
  Map<String, Map<String, String>> silverPrices = {};
  String lastUpdated = '';

  @override
  void initState() {
    super.initState();
    fetchMarketData();
  }

  // goldr.org থেকে ডেটা স্ক্র্যাপ করার ফাংশন
  Future<void> fetchMarketData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(Uri.parse('https://goldr.org'));

      if (response.statusCode == 200) {
        var document = parser.parse(response.body);

        // এখানে ওয়েবসাইট থেকে প্রয়োজনীয় টেবিল ও ডেটা পার্স করার লজিক
        // প্রাথমিক অবস্থায় ডামি/টেস্ট ডেটা দিয়ে গঠন দেখানো হলো
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0), // আপনার অ্যাপের ব্যাকগ্রাউন্ড থিম
      appBar: AppBar(
        title: const Text('আজকের বাজার', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8B0000), // আপনার অ্যাপের প্রধান মেরুন কালার
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchMarketData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B0000)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // একক পরিবর্তনের ট্যাব (Gram, Vori, Ana, Rati)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildUnitButton('Gram', 'গ্রাম'),
                        _buildUnitButton('Vori', 'ভরি'),
                        _buildUnitButton('Ana', 'আনা'),
                        _buildUnitButton('Rati', 'রতি'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // স্বর্ণের দামের কার্ড
                  _buildPriceCard(
                    title: 'প্রতি $selectedUnit স্বর্ণের দাম (BAJUS)',
                    icon: Icons.monetization_on,
                    items: [
                      {'type': '২২ ক্যারেট সোনা', 'buy': '৳ ২,৩০,৭৭২', 'sell': '৳ ১,৮৮,৩২৩'},
                      {'type': '২১ ক্যারেট সোনা', 'buy': '৳ ২,২০,৩৯১', 'sell': '৳ ১,৪৭0.১৮'},
                      {'type': '১৮ ক্যারেট সোনা', 'buy': '৳ ১,৮৯,২৪৮', 'sell': '৳ ১,২৬২.৪৩'},
                      {'type': 'সনাতন সোনা', 'buy': '৳ ১,৫৪,৬০৬', 'sell': '৳ ১,০৩১.৩৪'},
                    ],
                  ),
                  const SizedBox(height: 16),

                  // রূপার দামের কার্ড
                  _buildPriceCard(
                    title: 'প্রতি $selectedUnit রূপার দাম',
                    icon: Icons.stars,
                    items: [
                      {'type': '২২ ক্যারেট রূপা', 'buy': '৳ ৪,৬১৬', 'sell': '৳ ৩৫.১১'},
                      {'type': '২১ ক্যারেট রূপা', 'buy': '৳ ৪,১৪১', 'sell': '৳ ৩৩.৬৯'},
                      {'type': '১৮ ক্যারেট রূপা', 'buy': '৳ ৩,৫৫৪', 'sell': '৳ ২৮.৯৪'},
                      {'type': 'সনাতন রূপা', 'buy': '৳ ২,৬৮২', 'sell': '৳ ২১.৮২'},
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // একক বাটন উইজেট
  Widget _buildUnitButton(String key, String label) {
    bool isSelected = selectedUnit == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedUnit = key;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B0000) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // প্রাইস কার্ড উইজেট
  Widget _buildPriceCard({required String title, required IconData icon, required List<Map<String, String>> items}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF8B0000)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8B0000)),
                ),
              ],
            ),
            const Divider(),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['type']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        item['buy']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
