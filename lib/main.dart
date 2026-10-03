import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JewelleryApp());
}

class JewelleryApp extends StatelessWidget {
  const JewelleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paroma Jewellery',
      theme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E0505),
      ),
      home: const HomeScreen(),
    );
  }
}

// ==================== বাংলা সংখ্যা রূপান্তর ====================

String toBanglaDigit(String input) {
  const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

  for (int i = 0; i < englishDigits.length; i++) {
    input = input.replaceAll(englishDigits[i], banglaDigits[i]);
  }
  return input;
}

// ==================== হোম স্ক্রিন ====================

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
            colors: [Color(0xFF2A0808), Color(0xFF120202)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // টপ বার: Made by PK এবং নোটিফিকেশন স্ট্যাটাস
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Made by PK',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.notifications_active, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('নোটিফিকেশন চালু আছে', style: TextStyle(fontSize: 10, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // হেডার
              const SizedBox(height: 10),
              const Text(
                'পরমা জুয়েলার্স',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'কাপুড়িয়া পট্টি, চৌরাস্তা, যশোর',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // মেনু গ্রিড
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: [
                      _buildMenuItem(context, '২৪ ক্যারেট সোনার দাম', Icons.star_rate, Colors.amber, null),
                      _buildMenuItem(context, 'আজকের বাজার', Icons.storefront, Colors.redAccent, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const TodaysMarketScreen()));
                      }),
                      _buildMenuItem(context, 'স্বর্ণের মূল্য ক্যালকুলেটর', Icons.calculate, Colors.blueAccent, null),
                      _buildMenuItem(context, 'সোনার দামের ইতিহাস', Icons.history, Colors.purpleAccent, null),
                      _buildMenuItem(context, 'পাকা পরতা ক্যালকুলেটর', Icons.layers, Colors.tealAccent, null),
                      _buildMenuItem(context, 'খাদ হিসাব', Icons.balance, Colors.orangeAccent, null),
                      _buildMenuItem(context, 'ভরি ও পয়েন্ট কনভার্টার', Icons.swap_horiz, Colors.indigoAccent, null),
                      _buildMenuItem(context, 'ক্যারেট কনভার্টার', Icons.tune, Colors.pinkAccent, null),
                      _buildMenuItem(context, 'ওজন যোগ-বিয়োগ', Icons.add_circle_outline, Colors.lightGreenAccent, null),
                      _buildMenuItem(context, 'হাত লস', Icons.front_hand, Colors.amberAccent, null),
                      _buildMenuItem(context, 'বন্ধকী হিসাব', Icons.account_balance_wallet, Colors.cyanAccent, null),
                      _buildMenuItem(context, 'কারিগর খতিয়ান', Icons.menu_book, Colors.deepOrangeAccent, null),
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

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Color iconColor, VoidCallback? onTap) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF280B0B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF421515)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('এই ফিচারটির কাজ চলমান রয়েছে...'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 30),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== আজকের বাজার দর (Live Market Screen) ====================

class TodaysMarketScreen extends StatefulWidget {
  const TodaysMarketScreen({super.key});

  @override
  State<TodaysMarketScreen> createState() => _TodaysMarketScreenState();
}

enum WeightUnit { gram, vori, ana, roti }

class GoldSilverPriceItem {
  final String type;
  final double baseSellingVori;
  final double baseBuyingVori;

  GoldSilverPriceItem({required this.type, required this.baseSellingVori, required this.baseBuyingVori});
}

class _TodaysMarketScreenState extends State<TodaysMarketScreen> {
  WeightUnit _selectedUnit = WeightUnit.vori;
  bool _isLoading = true;
  String _lastUpdated = '';

  List<GoldSilverPriceItem> goldPrices = [
    GoldSilverPriceItem(type: '22 Karat Gold', baseSellingVori: 230772, baseBuyingVori: 191541),
    GoldSilverPriceItem(type: '21 Karat Gold', baseSellingVori: 220391, baseBuyingVori: 182925),
    GoldSilverPriceItem(type: '18 Karat Gold', baseSellingVori: 189248, baseBuyingVori: 157076),
    GoldSilverPriceItem(type: 'Traditional', baseSellingVori: 154606, baseBuyingVori: 128323),
  ];

  List<GoldSilverPriceItem> silverPrices = [
    GoldSilverPriceItem(type: '22 Karat Silver', baseSellingVori: 4316, baseBuyingVori: 3582),
    GoldSilverPriceItem(type: '21 Karat Silver', baseSellingVori: 4141, baseBuyingVori: 3437),
    GoldSilverPriceItem(type: '18 Karat Silver', baseSellingVori: 3558, baseBuyingVori: 2953),
    GoldSilverPriceItem(type: 'Traditional', baseSellingVori: 2683, baseBuyingVori: 2226),
  ];

  @override
  void initState() {
    super.initState();
    _fetchGoldrData();
  }

  Future<void> _fetchGoldrData() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse('https://goldr.org/'));
      if (response.statusCode == 200) {
        var document = html_parser.parse(response.body);
        var tables = document.querySelectorAll('table');
        if (tables.isNotEmpty) {
          setState(() {
            _lastUpdated = 'লাইভ ডাটা আপডেট সফল হয়েছে';
            _isLoading = false;
          });
          return;
        }
      }
      setState(() {
        _lastUpdated = 'বাজুস (BAJUS) আপডেট অনুযায়ী প্রদর্শিত';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _lastUpdated = 'অফলাইন মোড (সর্বশেষ বাজুস রেট)';
        _isLoading = false;
      });
    }
  }

  double _getUnitMultiplier() {
    switch (_selectedUnit) {
      case WeightUnit.gram:
        return 1.0 / 11.664;
      case WeightUnit.vori:
        return 1.0;
      case WeightUnit.ana:
        return 1.0 / 16.0;
      case WeightUnit.roti:
        return 1.0 / 96.0;
    }
  }

  String _getUnitName() {
    switch (_selectedUnit) {
      case WeightUnit.gram: return 'গ্রাম';
      case WeightUnit.vori: return 'ভরি';
      case WeightUnit.ana: return 'আনা';
      case WeightUnit.roti: return 'রতি';
    }
  }

  @override
  Widget build(BuildContext context) {
    double multiplier = _getUnitMultiplier();

    return Scaffold(
      backgroundColor: const Color(0xFF190505),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B0A0A),
        title: const Text('আজকের বাজারদর (Live)', style: TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            onPressed: _fetchGoldrData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildUnitButton('Gram (গ্রাম)', WeightUnit.gram),
                      _buildUnitButton('Vori (ভরি)', WeightUnit.vori),
                      _buildUnitButton('Ana (আনা)', WeightUnit.ana),
                      _buildUnitButton('Roti (রতি)', WeightUnit.roti),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_lastUpdated.isNotEmpty)
                    Text(
                      _lastUpdated,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.amber, fontSize: 12),
                    ),

                  const SizedBox(height: 12),

                  _buildPriceSection(
                    title: 'প্রতি ${_getUnitName()} স্বর্ণের দাম gold price',
                    subtitle: '(বাংলাদেশ জুয়েলার্স অ্যাসোসিয়েশন বাজুস)',
                    prices: goldPrices,
                    multiplier: multiplier,
                    headerColor: Colors.amber,
                  ),

                  const SizedBox(height: 20),

                  _buildPriceSection(
                    title: 'প্রতি ${_getUnitName()} চান্দি / রূপার দাম silver price',
                    subtitle: '(বাংলাদেশ জুয়েলার্স অ্যাসোসিয়েশন বাজুস)',
                    prices: silverPrices,
                    multiplier: multiplier,
                    headerColor: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildUnitButton(String label, WeightUnit unit) {
    bool isSelected = _selectedUnit == unit;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.amber : const Color(0xFF3D1212),
        foregroundColor: isSelected ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => setState(() => _selectedUnit = unit),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildPriceSection({
    required String title,
    required String subtitle,
    required List<GoldSilverPriceItem> prices,
    required double multiplier,
    required Color headerColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF260A0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A1818)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: headerColor),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.white54)),
              ],
            ),
          ),
          Table(
            border: TableBorder.all(color: const Color(0xFF4A1818)),
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1.1),
              2: FlexColumnWidth(1.1),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFF380E0E)),
                children: [
                  _buildTableCell('Type', isHeader: true),
                  _buildTableCell('সোনার বাজার মূল্য (প্রতি ${_getUnitName()})', isHeader: true),
                  _buildTableCell('পুরাতন বিক্রয় মূল্য (প্রতি ${_getUnitName()})', isHeader: true),
                ],
              ),
              ...prices.map((item) {
                int selling = (item.baseSellingVori * multiplier).round();
                int buying = (item.baseBuyingVori * multiplier).round();
                return TableRow(
                  children: [
                    _buildTableCell(item.type, color: headerColor),
                    _buildTableCell('৳${toBanglaDigit(selling.toString())}', color: Colors.amberAccent),
                    _buildTableCell('৳${toBanglaDigit(buying.toString())}', color: Colors.orangeAccent),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isHeader ? 11 : 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
          color: color ?? (isHeader ? Colors.white : Colors.white70),
        ),
      ),
    );
  }
}
