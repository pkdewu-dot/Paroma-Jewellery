import 'package:flutter/material.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.amber,
        primaryColor: Colors.amber[800],
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const GoldCalculatorScreen(),
    const FineGoldCalculatorScreen(),
    const UnitConverterScreen(),
    const AgeInterestCalculatorScreen(),
    const JewelryAdditionSubtractionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.amber[900],
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'ক্যালকুলেটর'),
          BottomNavigationBarItem(icon: Icon(Icons.workspace_premium), label: 'পাকা সোনা'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'কনভার্টার'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'বয়স ও সুদ'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'যোগ-বিয়োগ'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// ১. সোনার দাম, মজুরি ও ভ্যাট ক্যালকুলেটর (Gold Rate & Calculator)
// ---------------------------------------------------------
class GoldCalculatorScreen extends StatefulWidget {
  const GoldCalculatorScreen({super.key});

  @override
  State<GoldCalculatorScreen> createState() => _GoldCalculatorScreenState();
}

class _GoldCalculatorScreenState extends State<GoldCalculatorScreen> {
  String _selectedKarat = '২২K';
  final _vori = TextEditingController();
  final _ana = TextEditingController();
  final _rati = TextEditingController();
  final _point = TextEditingController();
  final _rate = TextEditingController();
  final _makingCharge = TextEditingController();
  final _vatPercent = TextEditingController(text: '5'); // ডিফল্ট ৫% ভ্যাট

  bool _isMakingPercent = false;
  double _total = 0.0;

  void _calculate() {
    double v = double.tryParse(_vori.text) ?? 0;
    double a = double.tryParse(_ana.text) ?? 0;
    double r = double.tryParse(_rati.text) ?? 0;
    double p = double.tryParse(_point.text) ?? 0;
    double ratePerVori = double.tryParse(_rate.text) ?? 0;
    double mc = double.tryParse(_makingCharge.text) ?? 0;
    double vat = double.tryParse(_vatPercent.text) ?? 0;

    double totalVori = v + (a / 16.0) + (r / 96.0) + (p / 960.0);
    double rawGoldPrice = totalVori * ratePerVori;

    double totalMaking = _isMakingPercent ? (rawGoldPrice * mc / 100) : mc;
    double subTotal = rawGoldPrice + totalMaking;
    double totalVat = subTotal * (vat / 100);

    setState(() {
      _total = subTotal + totalVat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('পরমা জুয়েলার্স - দাম ও মজুরি'), backgroundColor: Colors.amber[700]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedKarat,
              items: ['২৪K', '২২K', '২১K', '১৮K'].map((k) => DropdownMenuItem(value: k, child: Text('ক্যারেট: $k'))).toList(),
              onChanged: (v) => setState(() => _selectedKarat = v!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildInput(_vori, 'ভরি')),
                Expanded(child: _buildInput(_ana, 'আনা')),
                Expanded(child: _buildInput(_rati, 'রতি')),
                Expanded(child: _buildInput(_point, 'পয়েন্ট')),
              ],
            ),
            const SizedBox(height: 10),
            _buildInput(_rate, 'প্রতি ভরি সোনার দাম (টাকা)'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildInput(_makingCharge, 'মজুরি')),
                Switch(value: _isMakingPercent, onChanged: (v) => setState(() => _isMakingPercent = v)),
                Text(_isMakingPercent ? '%' : 'টাকা'),
              ],
            ),
            const SizedBox(height: 10),
            _buildInput(_vatPercent, 'ভ্যাট (%)'),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700], minimumSize: const Size.fromHeight(45)),
              child: const Text('মোট হিসাব করুন', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            _buildResultCard('সর্বমোট মূল্য: ৳ ${_total.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// ২. পাকা সোনা (Fine Gold) ক্যালকুলেটর
// ---------------------------------------------------------
class FineGoldCalculatorScreen extends StatefulWidget {
  const FineGoldCalculatorScreen({super.key});

  @override
  State<FineGoldCalculatorScreen> createState() => _FineGoldCalculatorScreenState();
}

class _FineGoldCalculatorScreenState extends State<FineGoldCalculatorScreen> {
  String _karat = '২২K';
  final _vori = TextEditingController();
  final _rate = TextEditingController();

  double _netGoldVori = 0.0;
  double _finalPrice = 0.0;

  void _calculateFineGold() {
    double v = double.tryParse(_vori.text) ?? 0;
    double r = double.tryParse(_rate.text) ?? 0;

    double purePercentage = 100.0;
    if (_karat == '২২K') purePercentage = 91.0; // ৯% খাদ
    if (_karat == '২১K') purePercentage = 87.0; // ১৩% খাদ
    if (_karat == '১৮K') purePercentage = 74.0; // ২৬% খাদ

    double netVori = v * (purePercentage / 100.0);
    setState(() {
      _netGoldVori = netVori;
      _finalPrice = netVori * r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('পাকা সোনা (Fine Gold) হিসাব'), backgroundColor: Colors.amber[700]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _karat,
              items: ['২২K (৯% খাদ)', '২১K (১৩% খাদ)', '১৮K (২৬% খাদ)'].map((e) {
                String k = e.split(' ')[0];
                return DropdownMenuItem(value: k, child: Text(e));
              }).toList(),
              onChanged: (v) => setState(() => _karat = v!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            _buildInput(_vori, 'সোনার ওজন (ভরি)'),
            const SizedBox(height: 10),
            _buildInput(_rate, 'পাকা সোনার রেট (প্রতি ভরি)'),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _calculateFineGold,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700], minimumSize: const Size.fromHeight(45)),
              child: const Text('পাকা সোনার হিসাব করুন', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            _buildResultCard('নিট সোনা: ${_netGoldVori.toStringAsFixed(3)} ভরি\nমোট দাম: ৳ ${_finalPrice.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// ৩. ইউনিট কনভার্টার (Unit Converter)
// ---------------------------------------------------------
class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  final _totalPoints = TextEditingController();
  final _gram = TextEditingController();

  String _traditionalResult = '';
  String _gramResult = '';

  void _convertFromPoints() {
    double p = double.tryParse(_totalPoints.text) ?? 0;
    int vori = (p / 960).floor();
    p %= 960;
    int ana = (p / 60).floor();
    p %= 60;
    int rati = (p / 10).floor();
    double point = p % 10;

    double totalGram = ((vori * 960 + ana * 60 + rati * 10 + point) / 960) * 11.664;

    setState(() {
      _traditionalResult = '$vori ভরি, $ana আনা, $rati রতি, ${point.toStringAsFixed(1)} পয়েন্ট';
      _gramResult = '${totalGram.toStringAsFixed(3)} গ্রাম';
    });
  }

  void _convertFromGram() {
    double g = double.tryParse(_gram.text) ?? 0;
    double totalVori = g / 11.664;
    double totalP = totalVori * 960;

    int vori = (totalP / 960).floor();
    totalP %= 960;
    int ana = (totalP / 60).floor();
    totalP %= 60;
    int rati = (totalP / 10).floor();
    double point = totalP % 10;

    setState(() {
      _traditionalResult = '$vori ভরি, $ana আনা, $rati রতি, ${point.toStringAsFixed(1)} পয়েন্ট';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ইউনিট কনভার্টার'), backgroundColor: Colors.amber[700]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInput(_totalPoints, 'মোট পয়েন্ট ইনপুট দিন'),
            ElevatedButton(onPressed: _convertFromPoints, child: const Text('পয়েন্ট থেকে রূপান্তর')),
            const Divider(height: 30),
            _buildInput(_gram, 'গ্রাম (Gram) ইনপুট দিন'),
            ElevatedButton(onPressed: _convertFromGram, child: const Text('গ্রাম থেকে রূপান্তর')),
            const SizedBox(height: 20),
            _buildResultCard('প্যারামাউন্ট রেজাল্ট:\n$_traditionalResult\n$_gramResult'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// ৪. বয়স ও প্রোপোরশনাল সুদ ক্যালকুলেটর (Rule of 1-15 & 16-31 Days)
// ---------------------------------------------------------
class AgeInterestCalculatorScreen extends StatefulWidget {
  const AgeInterestCalculatorScreen({super.key});

  @override
  State<AgeInterestCalculatorScreen> createState() => _AgeInterestCalculatorScreenState();
}

class _AgeInterestCalculatorScreenState extends State<AgeInterestCalculatorScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 40));
  DateTime _endDate = DateTime.now();

  final _principal = TextEditingController();
  final _monthlyRate = TextEditingController(text: '2');

  String _ageResult = '';
  double _totalInterest = 0;

  void _calculateAgeAndInterest() {
    int days = _endDate.difference(_startDate).inDays;
    int months = days ~/ 30;
    int remainingDays = days % 30;

    double p = double.tryParse(_principal.text) ?? 0;
    double r = double.tryParse(_monthlyRate.text) ?? 0;

    // প্রোপোরশনাল সুদের নিয়ম:
    // ১-১৫ দিন = ০.৫ মাস (হাফ মান্থ)
    // ১৬-৩১ দিন = ১.০ মাস (ফুল মান্থ)
    double dayFactor = 0.0;
    if (remainingDays >= 1 && remainingDays <= 15) {
      dayFactor = 0.5;
    } else if (remainingDays >= 16) {
      dayFactor = 1.0;
    }

    double totalEffectiveMonths = months + dayFactor;
    double interest = p * (r / 100) * totalEffectiveMonths;

    setState(() {
      _ageResult = '$months মাস $remainingDays দিন (কার্যকর মাস: $totalEffectiveMonths)';
      _totalInterest = interest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('বয়স ও সুদ ক্যালকুলেটর'), backgroundColor: Colors.amber[700]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text('শুরুর তারিখ: ${_startDate.toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                if (picked != null) setState(() => _startDate = picked);
              },
            ),
            ListTile(
              title: Text('শেষের তারিখ: ${_endDate.toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(context: context, initialDate: _endDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                if (picked != null) setState(() => _endDate = picked);
              },
            ),
            _buildInput(_principal, 'মূল ধন / টাকা'),
            const SizedBox(height: 10),
            _buildInput(_monthlyRate, 'মাসিক সুদের হার (%)'),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _calculateAgeAndInterest,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
              child: const Text('হিসাব করুন', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 15),
            _buildResultCard('সময়কাল: $_ageResult\nমোট সুদ: ৳ ${_totalInterest.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// ৫. ২ গহনার যোগ-বিয়োগ (Jewelry Addition & Subtraction)
// ---------------------------------------------------------
class JewelryAdditionSubtractionScreen extends StatefulWidget {
  const JewelryAdditionSubtractionScreen({super.key});

  @override
  State<JewelryAdditionSubtractionScreen> createState() => _JewelryAdditionSubtractionScreenState();
}

class _JewelryAdditionSubtractionScreenState extends State<JewelryAdditionSubtractionScreen> {
  final _v1 = TextEditingController(), _a1 = TextEditingController(), _r1 = TextEditingController(), _p1 = TextEditingController();
  final _v2 = TextEditingController(), _a2 = TextEditingController(), _r2 = TextEditingController(), _p2 = TextEditingController();

  String _addResult = '';
  String _subResult = '';

  double _toPoints(TextEditingController v, TextEditingController a, TextEditingController r, TextEditingController p) {
    double vori = double.tryParse(v.text) ?? 0;
    double ana = double.tryParse(a.text) ?? 0;
    double rati = double.tryParse(r.text) ?? 0;
    double point = double.tryParse(p.text) ?? 0;
    return (vori * 960) + (ana * 60) + (rati * 10) + point;
  }

  String _pointsToTraditional(double totalPoints) {
    bool isNegative = totalPoints < 0;
    totalPoints = totalPoints.abs();

    int vori = (totalPoints / 960).floor();
    totalPoints %= 960;
    int ana = (totalPoints / 60).floor();
    totalPoints %= 60;
    int rati = (totalPoints / 10).floor();
    double point = totalPoints % 10;

    String prefix = isNegative ? '-' : '';
    return '$prefix$vori ভরি, $ana আনা, $rati রতি, ${point.toStringAsFixed(1)} পয়েন্ট';
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
      appBar: AppBar(title: const Text('দুই গহনার যোগ-বিয়োগ'), backgroundColor: Colors.amber[700]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('গহনা ১:', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [Expanded(child: _buildInput(_v1, 'ভরি')), Expanded(child: _buildInput(_a1, 'আনা')), Expanded(child: _buildInput(_r1, 'রতি')), Expanded(child: _buildInput(_p1, 'পয়েন্ট'))]),
            const SizedBox(height: 10),
            const Text('গহনা ২:', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [Expanded(child: _buildInput(_v2, 'ভরি')), Expanded(child: _buildInput(_a2, 'আনা')), Expanded(child: _buildInput(_r2, 'রতি')), Expanded(child: _buildInput(_p2, 'পয়েন্ট'))]),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: _calculate, child: const Text('যোগ ও বিয়োগফল বের করুন')),
            const SizedBox(height: 15),
            _buildResultCard('যোগফল: $_addResult\nবিয়োগফল: $_subResult'),
          ],
        ),
      ),
    );
  }
}

// কমন উইজেট
Widget _buildInput(TextEditingController controller, String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.all(8)),
    ),
  );
}

Widget _buildResultCard(String text) {
  return Card(
    color: Colors.amber[50],
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    ),
  );
}
