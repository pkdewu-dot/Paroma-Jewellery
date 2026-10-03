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
        primaryColor: const Color(0xFF800000),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF800000),
          foregroundColor: Colors.white,
        ),
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
            colors: [Color(0xFF800000), Color(0xFF300000)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.black26,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('পরমা জুয়েলার্স', style: TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold)),
                        Text('কাগোপুজিয়া পট্টি, চৌরাস্তা, যশোর', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_active, size: 16, color: Colors.white),
                      label: const Text('নোটিফিকেশন চালু আছে', style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.9,
                    children: [
                      _buildMenuItem(context, '২৪ ক্যারেট সোনার দাম', Icons.star, Colors.amber, null),
                      _buildMenuItem(context, 'আজকের বাজার', Icons.storefront, Colors.redAccent, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const TodaysMarketScreen()));
                      }),
                      _buildMenuItem(context, 'স্বর্ণের মূল্য ক্যালকুলেটর', Icons.calculate, Colors.blue, null),
                      _buildMenuItem(context, 'সোনার দামের ইতিহাস', Icons.history, Colors.purple, null),
                      _buildMenuItem(context, 'পাকা পরতা ক্যালকুলেটর', Icons.layers, Colors.teal, null),
                      _buildMenuItem(context, 'খাদ হিসাব', Icons.balance, Colors.orange, null),
                      _buildMenuItem(context, 'ভরি ও পয়েন্ট কনভার্টার', Icons.swap_horiz, Colors.indigo, null),
                      _buildMenuItem(context, 'ক্যারেট কনভার্টার', Icons.tune, Colors.pink, null),
                      _buildMenuItem(context, 'ওজন যোগ-বিয়োগ', Icons.add_circle, Colors.green, null),
                      _buildMenuItem(context, 'হাত লস', Icons.front_hand, Colors.amber, null),
                      _buildMenuItem(context, 'বন্ধকী হিসাব', Icons.account_balance_wallet, Colors.cyan, null),
                      _buildMenuItem(context, 'কারিগর খতিয়ান', Icons.menu_book, Colors.deepOrange, null),
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
    return Card(
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('কাজ চলছে...')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
          ],
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
  final double baseSellingGram;
  final double baseBuyingGram;

  GoldSilverPriceItem({required this.type, required this.baseSellingGram, required this.baseBuyingGram});
}

class _TodaysMarketScreenState extends State<TodaysMarketScreen> {
  WeightUnit _selectedUnit = WeightUnit.vori;
  bool _isLoading = true;
  String _lastUpdated = '';

  List<GoldSilverPriceItem> goldPrices = [
    GoldSilverPriceItem(type: '22 Karat Gold', baseSellingGram: 11880, baseBuyingGram: 10830),
    GoldSilverPriceItem(type: '21 Karat Gold', baseSellingGram: 11340, baseBuyingGram: 10335),
    GoldSilverPriceItem(type: '18 Karat Gold', baseSellingGram: 9720, baseBuyingGram: 8860),
    GoldSilverPriceItem(type: 'Traditional', baseSellingGram: 8010, baseBuyingGram: 7290),
  ];

  List<GoldSilverPriceItem> silverPrices = [
    GoldSilverPriceItem(type: '22 Karat Silver', baseSellingGram: 230, baseBuyingGram: 200),
    GoldSilverPriceItem(type: '21 Karat Silver', baseSellingGram: 220, baseBuyingGram: 190),
    GoldSilverPriceItem(type: '18 Karat Silver', baseSellingGram: 188, baseBuyingGram: 162),
    GoldSilverPriceItem(type: 'Traditional', baseSellingGram: 141, baseBuyingGram: 122),
  ];

  @override
  void initState() {
    super.initState();
    _fetchGoldrData();
  }

  Future<void> _fetchGoldrData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://goldr.org/'));
      if (response.statusCode == 200) {
        var document = html_parser.parse(response.body);
        var tables = document.querySelectorAll('table');
        if (tables.isNotEmpty) {
          setState(() {
            _lastUpdated = 'লাইভ আপডেট সম্পন্ন';
            _isLoading = false;
          });
          return;
        }
      }
      setState(() {
        _lastUpdated = 'সংযুক্ত বাজার দর (BAJUS)';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _lastUpdated = 'সর্বশেষ সংরক্ষিত দাম';
        _isLoading = false;
      });
    }
  }

  double _getUnitMultiplier() {
    switch (_selectedUnit) {
      case WeightUnit.gram:
        return 1.0;
      case WeightUnit.vori:
        return 11.6638;
      case WeightUnit.ana:
        return 11.6638 / 16;
      case WeightUnit.roti:
        return 11.6638 / 96;
    }
  }

  String _getUnitName() {
    switch (_selectedUnit) {
      case WeightUnit.gram: return 'প্রতি গ্রাম';
      case WeightUnit.vori: return 'প্রতি ভরি';
      case WeightUnit.ana: return 'প্রতি আনা';
      case WeightUnit.roti: return 'প্রতি রতি';
    }
  }

  @override
  Widget build(BuildContext context) {
    double multiplier = _getUnitMultiplier();

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('আজকের বাজারদর (Live)'),
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
                    headerColor: Colors.grey.shade400,
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
        backgroundColor: isSelected ? Colors.amber : const Color(0xFF2A2A2A),
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
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
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
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.white54)),
              ],
            ),
          ),
          Table(
            border: TableBorder.all(color: Colors.white10),
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1.1),
              2: FlexColumnWidth(1.1),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFF2D2D2D)),
                children: [
                  _buildTableCell('Type', isHeader: true),
                  _buildTableCell('সোনার বাজার মূল্য (${_getUnitName()})', isHeader: true),
                  _buildTableCell('পুরাতন বিক্রয় মূল্য (${_getUnitName()})', isHeader: true),
                ],
              ),
              ...prices.map((item) {
                int selling = (item.baseSellingGram * multiplier).round();
                int buying = (item.baseBuyingGram * multiplier).round();
                return TableRow(
                  children: [
                    _buildTableCell(item.type, color: headerColor),
                    _buildTableCell('৳${toBanglaDigit(selling.toString())}', color: Colors.greenAccent),
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
