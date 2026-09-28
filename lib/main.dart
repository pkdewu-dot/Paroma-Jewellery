import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const PoromaJewellersApp());
}

class PoromaJewellersApp extends StatelessWidget {
  const PoromaJewellersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Poroma Jewellers',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFFD700),
        cardColor: const Color(0xFF1E1E1E),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        centerTitle: true,
        elevation: 3,
        toolbarHeight: 70,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'পরমা জুয়েলার্স',
              style: TextStyle(
                color: Color(0xFFFFD700), // হলুদ কালি
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Made by Pk',
              style: TextStyle(
                color: Colors.red, // লাল কালি
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // ৯টি প্রধান ফিচার গ্রিড
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildGridItem(Icons.trending_up, '১. বাজারের আপডেট\n(বিশ্ব ও দেশীয়)', Colors.teal, () => _openScreen(context, const MarketTrendScreen())),
                _buildGridItem(Icons.workspace_premium, '২. পাকার বাজার', Colors.amber.shade700, () => _openScreen(context, const RawGoldScreen())),
                _buildGridItem(Icons.currency_lira, '৩. আজকের বাজার\n(সোনা ও রূপা)', Colors.amber, () => _openScreen(context, const MarketRatesScreen())),
                _buildGridItem(Icons.calculate, '৪. স্বর্ণের মূল্য\nক্যালকুলেটর', Colors.green, () => _openScreen(context, const GoldCalculatorScreen())),
                _buildGridItem(Icons.add_circle_outline, '৫. ওজন যোগ-বিয়োগ', Colors.lightGreen, () => _openScreen(context, const JewelryAddSubScreen())),
                _buildGridItem(Icons.cleaning_services, '৬. পাকা পরতা\nক্যালকুলেটর', Colors.purple, () => _openScreen(context, const FineGoldCalculatorScreen())),
                _buildGridItem(Icons.import_export, '৭. ক্যারেট কনভার্টার', Colors.redAccent, () => _openScreen(context, const KaratConverterScreen())),
                _buildGridItem(Icons.swap_horiz, '৮. ভরি ও পয়েন্ট\nকনভার্টার', Colors.cyan, () => _openScreen(context, const UnitConverterScreen())),
                _buildGridItem(Icons.account_balance, '৯. বন্ধকি হিসাব', Colors.orange, () => _openScreen(context, const MortgageCalculatorScreen())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String title, Color borderColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}

// ---------------------------------------------------------
// ১. বাজারের আপডেট (বিশ্ব ও দেশীয়)
// ---------------------------------------------------------
class MarketTrendScreen extends StatelessWidget {
  const MarketTrendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('বাজারের আপডেট (বিশ্ব ও দেশীয়)'), backgroundColor: const Color(0xFF1A1A1A)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.green.shade900.withOpacity(0.4),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.greenAccent, size: 36),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('দেশীয় বাজার: ঊর্ধ্বমুখী 📈', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                          SizedBox(height: 4),
                          Text('Goldr.org ও বাজুস সোর্স অনুযায়ী স্থানীয় বাজারে সোনার চাহিদা ও মূল্য ঊর্ধ্বমুখী।', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.blueGrey.shade900,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.public, color: Colors.lightBlueAccent, size: 36),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('বিশ্ব বাজার: স্থিতিশীল 🌐', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent)),
                          SizedBox(height: 4),
                          Text('আন্তর্জাতিক বাজারে গোল্ড স্পট দর স্থিতিশীল অবস্থায় ট্রেড করছে।', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// ২. পাকার বাজার (Raw Gold Rates) - লাইভ এপিআই ডাটা
// ---------------------------------------------------------
class RawGoldScreen extends StatefulWidget {
  const RawGoldScreen({super.key});

  @override
  State<RawGoldScreen> createState() => _RawGoldScreenState();
}

class _RawGoldScreenState extends State<RawGoldScreen> {
  bool _isLoading = true;
  double _voriPrice = 204720.79;
  double _pakaIdea = 199470.79;
  double _noVatPrice = 189970.21;

  @override
  void initState() {
    super.initState();
    _fetchLiveRates();
  }

  Future<void> _fetchLiveRates() async {
    setState(() => _isLoading = true);
    try {
      // স্পট গোল্ড রেট এপিআই
      final response = await http.get(Uri.parse('https://api.gold-api.com/price/XAU'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double goldOunceUSD = (data['price'] as num).toDouble();
        
        // ১ আউন্স = ২.৬৮৬৪ ভরি, USD/BDT রেট ~ ১২০
        double usdToBdt = 121.5;
        double gramPriceBDT = (goldOunceUSD * usdToBdt) / 31.1034768;
        
        double liveVori = gramPriceBDT * 11.664;
        
        setState(() {
          _voriPrice = liveVori;
          _pakaIdea = liveVori * 0.9743; // স্পট গোল্ডের লাইভ হিসাব
          _noVatPrice = liveVori * 0.9279;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('পাকার বাজার (Raw Gold)'), 
        backgroundColor: const Color(0xFF1A1A1A),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            onPressed: _fetchLiveRates,
            tooltip: 'রিফ্রেশ করুন',
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '২৪ ক্যারেট লাইভ স্বর্ণের দাম:', 
                    style: TextStyle(fontSize: 16, color: Colors.amber, fontWeight: FontWeight.bold)
                  ),
                  OutlinedButton.icon(
                    onPressed: _fetchLiveRates,
                    icon: const Icon(Icons.sync, size: 16, color: Colors.amber),
                    label: const Text('রিফ্রেশ করুন', style: TextStyle(color: Colors.amber, fontSize: 12)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.amber)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // ১. প্রতি ভরি (১১.৬৬৪ গ্রাম)
              _buildPakaCard('প্রতি ভরি (১১.৬৬৪ গ্রাম)', '৳ ${_voriPrice.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              
              // ২. পাকা আইডিয়া
              _buildPakaCard('পাকা আইডিয়া', '৳ ${_pakaIdea.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              
              // ৩. VAT ও শুল্ক ছাড়া
              _buildPakaCard('VAT ও শুল্ক ছাড়া', '৳ ${_noVatPrice.toStringAsFixed(2)}'),
            ],
          ),
    );
  }

  Widget _buildPakaCard(String title, String price) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title, 
                style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500)
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4)
                ),
                child: const Text('LIVE', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            price, 
            style: const TextStyle(fontSize: 24, color: Colors.amber, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// ৩. আজকের বাজার (সোনা এবং রূপা - ২২, ২১, ১৮ ক্যারেট)
// ---------------------------------------------------------
class MarketRatesScreen extends StatelessWidget {
  const MarketRatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('আজকের সোনা ও রূপার দর'), backgroundColor: const Color(0xFF1A1A1A)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('আজকের সোনার দর (প্রতি ভরি):', style: TextStyle(fontSize: 16, color: Colors.amber, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildRateCard('২২ ক্যারেট সোনা', '৳ ২,৩০,৭৭২', '৳ ১৯,৭৮৫ / গ্রাম'),
          _buildRateCard('২১ ক্যারেট সোনা', '৳ ২,২০,৩৯১', '৳ ১৮,৮৯৫ / গ্রাম'),
          _buildRateCard('১৮ ক্যারেট সোনা', '৳ ১,৮৯,২৪৮', '৳ ১৬,২২৫ / গ্রাম'),
          _buildRateCard('সনাতন পদ্ধতি', '৳ ১,৫৪,২৫৬', '৳ ১৩,২২৫ / গ্রাম'),
          const Divider(height: 25, color: Colors.grey),
          const Text('আজকের রূপার দর (প্রতি ভরি):', style: TextStyle(fontSize: 16, color: Colors.cyan, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildRateCard('২২ ক্যারেট রূপা', '৳ ৪,৪৯১', '৳ ৩৮৫ / গ্রাম'),
          _buildRateCard('২১ ক্যারেট রূপা', '৳ ৪,৩১৬', '৳ ৩৭০ / গ্রাম'),
          _buildRateCard('১৮ ক্যারেট রূপা', '৳ ৩,৭৩২', '৳ ৩২০ / গ্রাম'),
        ],
      ),
    );
  }

  Widget _buildRateCard(String title, String voriRate, String gramRate) {
    return Card(
      color: const Color(0xFF252525),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text('গ্রাম: $gramRate', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Text(voriRate, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
}

// ---------------------------------------------------------
// ৪. স্বর্ণের মূল্য ক্যালকুলেটর
// ---------------------------------------------------------
class GoldCalculatorScreen extends StatefulWidget {
  const GoldCalculatorScreen({super.key});

  @override
  State<GoldCalculatorScreen> createState() => _GoldCalculatorScreenState();
}

class _GoldCalculatorScreenState extends State<GoldCalculatorScreen> {
  final _v = TextEditingController(), _a = TextEditingController(), _r = TextEditingController(), _rate = TextEditingController(text: '230772'), _making = TextEditingController(text: '3500');
  double _total = 0;

  void _calc() {
    double vori = double.tryParse(_v.text) ?? 0;
    double ana = double.tryParse(_a.text) ?? 0;
    double roti = double.tryParse(_r.text) ?? 0;
    double rate = double.tryParse(_rate.text) ?? 0;
    double m = double.tryParse(_making.text) ?? 0;

    double totalVori = vori + (ana / 16) + (roti / 96);
    double price = (totalVori * rate) + (totalVori * m);
    setState(() => _total = price + (price * 0.05));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('স্বর্ণের মূল্য ক্যালকুলেটর')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(children: [
                Expanded(child: _buildInput(_v, 'ভরি')),
                Expanded(child: _buildInput(_a, 'আনা')),
                Expanded(child: _buildInput(_r, 'রতি/পয়েন্ট')),
              ]),
              const SizedBox(height: 10),
              _buildInput(_rate, 'প্রতি ভরি দাম (৳)'),
              const SizedBox(height: 10),
              _buildInput(_making, 'মেকিং চার্জ (প্রতি ভরি)'),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _calc,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size.fromHeight(45)),
                child: const Text('হিসাব করুন', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 15),
              _buildResultCard('সর্বমোট মূল্য (৫% ভ্যাটসহ):\n৳ ${_total.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// ৫. ওজন যোগ-বিয়োগ
// ---------------------------------------------------------
class JewelryAddSubScreen extends StatefulWidget {
  const JewelryAddSubScreen({super.key});

  @override
  State<JewelryAddSubScreen> createState() => _JewelryAddSubScreenState();
}

class _JewelryAddSubScreenState extends State<JewelryAddSubScreen> {
  final _v1 = TextEditingController(), _a1 = TextEditingController(), _r1 = TextEditingController(), _p1 = TextEditingController();
  final _v2 = TextEditingController(), _a2 = TextEditingController(), _r2 = TextEditingController(), _p2 = TextEditingController();

  String _addResult = '০ ভরি, ০ আনা, ০ রতি, ০ পয়েন্ট';
  String _subResult = '০ ভরি, ০ আনা, ০ রতি, ০ পয়েন্ট';

  double _toPoints(TextEditingController v, TextEditingController a, TextEditingController r, TextEditingController p) {
    double vori = double.tryParse(v.text) ?? 0;
    double ana = double.tryParse(a.text) ?? 0;
    double rati = double.tryParse(r.text) ?? 0;
    double point = double.tryParse(p.text) ?? 0;
    return (vori * 960) + (ana * 60) + (rati * 10) + point;
  }

  String _pointsToTraditional(double pts) {
    if (pts < 0) pts = 0;
    int vori = (pts / 960).floor();
    pts %= 960;
    int ana = (pts / 60).floor();
    pts %= 60;
    int rati = (pts / 10).floor();
    double point = pts % 10;
    return '$vori ভরি, $ana আনা, $rati রতি, ${point.toStringAsFixed(1)} পয়েন্ট';
  }

  void _calculate() {
    double p1 = _toPoints(_v1, _a1, _r1, _p1);
    double p2 = _toPoints(_v2, _a2, _r2, _p2);

    setState(() {
      _addResult = _pointsToTraditional(p1 + p2);
      _subResult = _pointsToTraditional(p1 - p2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ওজন যোগ-বিয়োগ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('প্রথম ওজন:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
            Row(children: [Expanded(child: _buildInput(_v1, 'ভরি')), Expanded(child: _buildInput(_a1, 'আনা')), Expanded(child: _buildInput(_r1, 'রতি')), Expanded(child: _buildInput(_p1, 'পয়েন্ট'))]),
            const SizedBox(height: 10),
            const Text('দ্বিতীয় ওজন:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
            Row(children: [Expanded(child: _buildInput(_v2, 'ভরি')), Expanded(child: _buildInput(_a2, 'আনা')), Expanded(child: _buildInput(_r2, 'রতি')), Expanded(child: _buildInput(_p2, 'পয়েন্ট'))]),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size.fromHeight(45)),
              child: const Text('হিসাব করুন', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            _buildResultCard('যোগফল: $_addResult\nবিয়োগফল: $_subResult'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// ৬. পাকা পরতা ক্যালকুলেটর
// ---------------------------------------------------------
class FineGoldCalculatorScreen extends StatefulWidget {
  const FineGoldCalculatorScreen({super.key});

  @override
  State<FineGoldCalculatorScreen> createState() => _FineGoldCalculatorScreenState();
}

class _FineGoldCalculatorScreenState extends State<FineGoldCalculatorScreen> {
  final _weight = TextEditingController();
  final _purity = TextEditingController(text: '91.6');
  double _fineGold = 0;

  void _calc() {
    double w = double.tryParse(_weight.text) ?? 0;
    double p = double.tryParse(_purity.text) ?? 0;
    setState(() => _fineGold = (w * p) / 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('পাকা পরতা ক্যালকুলেটর')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInput(_weight, 'পুরাতন সোনার ওজন (গ্রাম)'),
            const SizedBox(height: 10),
            _buildInput(_purity, 'খাদ/বিশুদ্ধতা পার্সেন্টেজ (%)'),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _calc,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size.fromHeight(45)),
              child: const Text('পাকা সোনা বের করুন', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            _buildResultCard('বিশুদ্ধ পাকা সোনা: ${_fineGold.toStringAsFixed(3)} গ্রাম'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// ৭. ক্যারেট কনভার্টার
// ---------------------------------------------------------
class KaratConverterScreen extends StatefulWidget {
  const KaratConverterScreen({super.key});

  @override
  State<KaratConverterScreen> createState() => _KaratConverterScreenState();
}

class _KaratConverterScreenState extends State<KaratConverterScreen> {
  final _weight = TextEditingController(text: '10');
  double _fromK = 22;
  double _toK = 24;
  double _result = 0;

  void _calc() {
    double w = double.tryParse(_weight.text) ?? 0;
    setState(() => _result = (w * _fromK) / _toK);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ক্যারেট কনভার্টার')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInput(_weight, 'ওজন (গ্রাম)'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<double>(
                    value: _fromK,
                    items: const [
                      DropdownMenuItem(value: 22, child: Text('22K')),
                      DropdownMenuItem(value: 21, child: Text('21K')),
                      DropdownMenuItem(value: 18, child: Text('18K')),
                    ],
                    onChanged: (v) => setState(() => _fromK = v!),
                    decoration: const InputDecoration(labelText: 'থেকে', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<double>(
                    value: _toK,
                    items: const [
                      DropdownMenuItem(value: 24, child: Text('24K (Pure)')),
                      DropdownMenuItem(value: 22, child: Text('22K')),
                      DropdownMenuItem(value: 21, child: Text('21K')),
                    ],
                    onChanged: (v) => setState(() => _toK = v!),
                    decoration: const InputDecoration(labelText: 'তে', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _calc,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size.fromHeight(45)),
              child: const Text('কনভার্ট করুন', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            _buildResultCard('সমপরিমাণ ওজন: ${_result.toStringAsFixed(3)} গ্রাম'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// ৮. ভরি ও পয়েন্ট কনভার্টার
// ---------------------------------------------------------
class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  final _gram = TextEditingController();
  String _res = 'ভরি: ০ | আনা: ০ | রতি: ০ | পয়েন্ট: ০';

  void _convert() {
    double g = double.tryParse(_gram.text) ?? 0;
    double totalVori = g / 11.664;
    int vori = totalVori.floor();
    double remAna = (totalVori - vori) * 16;
    int ana = remAna.floor();
    double remRoti = (remAna - ana) * 6;
    int roti = remRoti.floor();
    double point = (remRoti - roti) * 10;

    setState(() {
      _res = 'ভরি: $vori | আনা: $ana | রতি: $roti | পয়েন্ট: ${point.toStringAsFixed(1)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ভরি ও পয়েন্ট কনভার্টার')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInput(_gram, 'গ্রাম (Gram) ইনপুট দিন'),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _convert,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size.fromHeight(45)),
              child: const Text('রূপান্তর করুন', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            _buildResultCard(_res),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// ৯. বন্ধকি হিসাব
// ---------------------------------------------------------
class MortgageCalculatorScreen extends StatefulWidget {
  const MortgageCalculatorScreen({super.key});

  @override
  State<MortgageCalculatorScreen> createState() => _MortgageCalculatorScreenState();
}

class _MortgageCalculatorScreenState extends State<MortgageCalculatorScreen> {
  final _amount = TextEditingController();
  final _rate = TextEditingController(text: '2');
  final _months = TextEditingController(text: '1');
  double _interest = 0;
  double _total = 0;

  void _calc() {
    double p = double.tryParse(_amount.text) ?? 0;
    double r = double.tryParse(_rate.text) ?? 0;
    double m = double.tryParse(_months.text) ?? 0;

    double interest = (p * r * m) / 100;
    setState(() {
      _interest = interest;
      _total = p + interest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('বন্ধকি হিসাব')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInput(_amount, 'ঋণ / বন্ধকি টাকা (৳)'),
            const SizedBox(height: 10),
            _buildInput(_rate, 'মাসিক সুদের হার (%)'),
            const SizedBox(height: 10),
            _buildInput(_months, 'সময়কাল (মাস)'),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _calc,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size.fromHeight(45)),
              child: const Text('হিসাব করুন', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            _buildResultCard('মোট সুদ: ৳ ${_interest.toStringAsFixed(2)}\nসর্বমোট পরিশোধযোগ্য: ৳ ${_total.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

Widget _buildInput(TextEditingController controller, String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        contentPadding: const EdgeInsets.all(10),
      ),
    ),
  );
}

Widget _buildResultCard(String text) {
  return Card(
    color: const Color(0xFF2C2C2C),
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amber)),
    ),
  );
}
