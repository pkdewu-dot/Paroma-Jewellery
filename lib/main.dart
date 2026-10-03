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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
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
                    style: TextStyle(color: Color(0xFFFFD700), fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('কাপুড়িয়া পট্টি, চৌরাস্তা, যশোর', style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.85,
              children: [
                _buildCard(context, '২৪ ক্যারেট সোনার দাম', Icons.star_border, Colors.amber[700]!, const TodaysMarketPage()),
                _buildCard(context, 'আজকের বাজার', Icons.storefront, Colors.pink[400]!, const TodaysMarketPage()),
                _buildCard(context, 'স্বর্ণের মূল্য ক্যালকুলেটর', Icons.calculate_outlined, Colors.blue[600]!, const PriceCalculatorPage()),
                _buildCard(context, 'সোনার দামের ইতিহাস', Icons.access_time, Colors.purple[400]!, const TodaysMarketPage()),
                _buildCard(context, 'পাকা পরতা ক্যালকুলেটর', Icons.layers_outlined, Colors.teal[600]!, const PakaPortaPage()),
                _buildCard(context, 'খাদ হিসাব', Icons.pie_chart_outline, Colors.blue[900]!, const KhadPage()),
                _buildCard(context, 'ভরি ও পয়েন্ট কনভার্টার', Icons.swap_horiz, Colors.deepOrange[400]!, const UnitConverterPage()),
                _buildCard(context, 'ক্যারেট কনভার্টার', Icons.tune, Colors.red[600]!, const CaratConverterPage()),
                _buildCard(context, 'ওজন যোগ-বিয়োগ', Icons.add, Colors.green[600]!, const WeightAddSubtractPage()),
                _buildCard(context, 'হাত লস', Icons.pan_tool_outlined, Colors.brown[600]!, const HatLossPage()),
                _buildCard(context, 'বন্ধকী হিসাব', Icons.account_balance_wallet_outlined, Colors.purple[700]!, const BondhokiPage()),
                _buildCard(context, 'কারিগর খতিয়ান', Icons.menu_book, Colors.orange[800]!, const KarigorPage()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Color color, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 6),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// 1. স্বর্ণের মূল্য ক্যালকুলেটর
class PriceCalculatorPage extends StatefulWidget {
  const PriceCalculatorPage({super.key});
  @override
  State<PriceCalculatorPage> createState() => _PriceCalculatorPageState();
}
class _PriceCalculatorPageState extends State<PriceCalculatorPage> {
  final voriC = TextEditingController(), anaC = TextEditingController(), ratiC = TextEditingController(), rateC = TextEditingController();
  double total = 0;
  void calc() {
    double v = double.tryParse(voriC.text) ?? 0;
    double a = double.tryParse(anaC.text) ?? 0;
    double r = double.tryParse(ratiC.text) ?? 0;
    double rate = double.tryParse(rateC.text) ?? 0;
    double totalVori = v + (a / 16) + (r / 96);
    setState(() => total = totalVori * rate);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('স্বর্ণের মূল্য ক্যালকুলেটর')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: TextField(controller: voriC, decoration: const InputDecoration(labelText: 'ভরি'), keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: anaC, decoration: const InputDecoration(labelText: 'আনা'), keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: ratiC, decoration: const InputDecoration(labelText: 'রতি'), keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 12),
            TextField(controller: rateC, decoration: const InputDecoration(labelText: 'প্রতি ভরির দাম (টাকা)'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: calc, child: const Text('হিসাব করুন')),
            const SizedBox(height: 20),
            Text('মোট মূল্য: ৳ ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}

// 2. ভরি ও পয়েন্ট কনভার্টার
class UnitConverterPage extends StatefulWidget {
  const UnitConverterPage({super.key});
  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}
class _UnitConverterPageState extends State<UnitConverterPage> {
  final inputC = TextEditingController();
  double gram = 0, ana = 0, rati = 0;
  void convert(String val) {
    double v = double.tryParse(val) ?? 0;
    setState(() {
      gram = v * 11.664;
      ana = v * 16;
      rati = v * 96;
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
            TextField(controller: inputC, decoration: const InputDecoration(labelText: 'ভরির পরিমাণ লিখুন'), keyboardType: TextInputType.number, onChanged: convert),
            const SizedBox(height: 20),
            Card(child: ListTile(title: const Text('গ্রাম'), trailing: Text('${gram.toStringAsFixed(3)} গ্রাম'))),
            Card(child: ListTile(title: const Text('আনা'), trailing: Text('${ana.toStringAsFixed(2)} আনা'))),
            Card(child: ListTile(title: const Text('রতি'), trailing: Text('${rati.toStringAsFixed(2)} রতি'))),
          ],
        ),
      ),
    );
  }
}

// 3. হাত লস
class HatLossPage extends StatefulWidget {
  const HatLossPage({super.key});
  @override
  State<HatLossPage> createState() => _HatLossPageState();
}
class _HatLossPageState extends State<HatLossPage> {
  final weightC = TextEditingController(), lossPercentC = TextEditingController();
  double totalLoss = 0;
  void calc() {
    double w = double.tryParse(weightC.text) ?? 0;
    double p = double.tryParse(lossPercentC.text) ?? 0;
    setState(() => totalLoss = w * (p / 100));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('হাত লস হিসাব')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: weightC, decoration: const InputDecoration(labelText: 'মোট ওজন (গ্রাম/ভরি)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: lossPercentC, decoration: const InputDecoration(labelText: 'হাত লস (%)'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: calc, child: const Text('লসের পরিমাণ বের করুন')),
            const SizedBox(height: 20),
            Text('মোট হাত লস: ${totalLoss.toStringAsFixed(3)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

// 4. ওজন যোগ-বিয়োগ
class WeightAddSubtractPage extends StatefulWidget {
  const WeightAddSubtractPage({super.key});
  @override
  State<WeightAddSubtractPage> createState() => _WeightAddSubtractPageState();
}
class _WeightAddSubtractPageState extends State<WeightAddSubtractPage> {
  final v1 = TextEditingController(), a1 = TextEditingController();
  final v2 = TextEditingController(), a2 = TextEditingController();
  double resVori = 0, resAna = 0;
  void add() {
    double totAna = ((double.tryParse(v1.text) ?? 0) * 16 + (double.tryParse(a1.text) ?? 0)) +
                    ((double.tryParse(v2.text) ?? 0) * 16 + (double.tryParse(a2.text) ?? 0));
    setState(() {
      resVori = (totAna / 16).floorToDouble();
      resAna = totAna % 16;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ওজন যোগ-বিয়োগ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: TextField(controller: v1, decoration: const InputDecoration(labelText: '১ম ভরি'), keyboardType: TextInputType.number)),
              Expanded(child: TextField(controller: a1, decoration: const InputDecoration(labelText: '১ম আনা'), keyboardType: TextInputType.number)),
            ]),
            Row(children: [
              Expanded(child: TextField(controller: v2, decoration: const InputDecoration(labelText: '২য় ভরি'), keyboardType: TextInputType.number)),
              Expanded(child: TextField(controller: a2, decoration: const InputDecoration(labelText: '২য় আনা'), keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: add, child: const Text('যোগ করুন')),
            const SizedBox(height: 20),
            Text('ফলাফল: ${resVori.toInt()} ভরি ${resAna.toStringAsFixed(1)} আনা', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// 5. পাকা পরতা
class PakaPortaPage extends StatelessWidget {
  const PakaPortaPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('পাকা পরতা ক্যালকুলেটর')),
      body: const Center(child: Text('পাকা পরতা গণনার ইনপুট ফিল্ড', style: TextStyle(fontSize: 16))),
    );
  }
}

// 6. খাদ হিসাব
class KhadPage extends StatelessWidget {
  const KhadPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('খাদ হিসাব')),
      body: const Center(child: Text('২২/২১ ক্যারেট খাদ অনুপাত ক্যালকুলেটর', style: TextStyle(fontSize: 16))),
    );
  }
}

// 7. ক্যারেট কনভার্টার
class CaratConverterPage extends StatelessWidget {
  const CaratConverterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ক্যারেট কনভার্টার')),
      body: const Center(child: Text('২৪, ২২, ২১ ও ১৮ ক্যারেট কনভার্সন', style: TextStyle(fontSize: 16))),
    );
  }
}

// 8. বন্ধকী হিসাব
class BondhokiPage extends StatelessWidget {
  const BondhokiPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('বন্ধকী হিসাব')),
      body: const Center(child: Text('বন্ধকী ঋণের সুদ ও হিসেব খাতা', style: TextStyle(fontSize: 16))),
    );
  }
}

// 9. কারিগর খতিয়ান
class KarigorPage extends StatelessWidget {
  const KarigorPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('কারিগর খতিয়ান')),
      body: const Center(child: Text('কারিগর জমা ও মজুরি রেজিস্টার', style: TextStyle(fontSize: 16))),
    );
  }
}
