import 'package:flutter/material.dart';

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
      title: 'Made by PK',
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.red,
      ),
      home: const HomeScreen(),
    );
  }
}

// ==================== হেল্পার ফাংশন (সংখ্যা রূপান্তর) ====================

String toBanglaDigit(String input) {
  const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

  for (int i = 0; i < englishDigits.length; i++) {
    input = input.replaceAll(englishDigits[i], banglaDigits[i]);
  }
  return input;
}

String formatNumberWithCommas(double number, {bool isCurrency = false}) {
  String numStr = isCurrency ? number.toStringAsFixed(2) : number.toStringAsFixed(1);
  List<String> parts = numStr.split('.');
  String integerPart = parts[0];
  String decimalPart = parts.length > 1 ? parts[1] : '';

  if (integerPart.length > 3) {
    String lastThree = integerPart.substring(integerPart.length - 3);
    String remaining = integerPart.substring(0, integerPart.length - 3);

    RegExp regExp = RegExp(r'(\d{1,2})(?=(\d{2})+(?!\d))');
    String formattedRemaining = remaining.replaceAllMapped(regExp, (Match m) => '${m[1]},');

    integerPart = '$formattedRemaining,$lastThree';
  }

  if (isCurrency) {
    return toBanglaDigit('$integerPart.$decimalPart');
  } else {
    return decimalPart == '0' ? toBanglaDigit(integerPart) : toBanglaDigit('$integerPart.$decimalPart');
  }
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
            colors: [
              Color(0xFF880E4F),
              Color(0xFF311B92),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // অ্যাপ বার / নোটিফিকেশন বার
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white.withValues(alpha: 0.15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Paroma Jewellery',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.notifications_active, color: Colors.amber),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // গ্রিড আইটেম তালিকা
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildMenuCard(
                        context,
                        title: 'ক্যারট পরিবর্তন',
                        icon: Icons.published_with_changes,
                        color: Colors.orange,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CaratConverterScreen()),
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'খাদ ক্যালকুলেটর',
                        icon: Icons.calculate,
                        color: Colors.teal,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const KhadCalculatorScreen()),
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'ওজন যোগ/বিয়োগ',
                        icon: Icons.add_circle_outline,
                        color: Colors.blue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WeightAddSubtractScreen()),
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'বন্ধকী হিসাব',
                        icon: Icons.account_balance,
                        color: Colors.purple,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BondhokiCalculatorScreen()),
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'হাতে ঘাটতি হিসাব',
                        icon: Icons.trending_down,
                        color: Colors.brown,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HatLossCalculatorScreen()),
                        ),
                      ),
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

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ১. ক্যারট কনভার্টার স্ক্রিন ====================

class CaratConverterScreen extends StatefulWidget {
  const CaratConverterScreen({super.key});

  @override
  State<CaratConverterScreen> createState() => _CaratConverterScreenState();
}

class _CaratConverterScreenState extends State<CaratConverterScreen> {
  final TextEditingController _voriController = TextEditingController();
  final TextEditingController _anaController = TextEditingController();
  final TextEditingController _rotiController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();

  int _fromCarat = 22;
  int _toCarat = 21;

  double _convertedVori = 0;
  double _convertedAna = 0;
  double _convertedRoti = 0;
  double _convertedPoint = 0;

  @override
  void dispose() {
    _voriController.dispose();
    _anaController.dispose();
    _rotiController.dispose();
    _pointController.dispose();
    super.dispose();
  }

  void _convert() {
    double vori = double.tryParse(_voriController.text) ?? 0;
    double ana = double.tryParse(_anaController.text) ?? 0;
    double roti = double.tryParse(_rotiController.text) ?? 0;
    double point = double.tryParse(_pointController.text) ?? 0;

    double totalPoints = (vori * 16 * 6 * 10) + (ana * 6 * 10) + (roti * 10) + point;
    double convertedPoints = (totalPoints * _fromCarat) / _toCarat;

    setState(() {
      _convertedVori = (convertedPoints / (16 * 6 * 10)).floorToDouble();
      double rem1 = convertedPoints % (16 * 6 * 10);

      _convertedAna = (rem1 / (6 * 10)).floorToDouble();
      double rem2 = rem1 % (6 * 10);

      _convertedRoti = (rem2 / 10).floorToDouble();
      _convertedPoint = rem2 % 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ক্যারট পরিবর্তন'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _fromCarat,
                    decoration: const InputDecoration(labelText: 'বর্তমান ক্যারেট', border: OutlineInputBorder()),
                    items: [24, 22, 21, 18].map((c) => DropdownMenuItem(value: c, child: Text('$c ক্যারেট'))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _fromCarat = val;
                          _convert();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _toCarat,
                    decoration: const InputDecoration(labelText: 'পরিবর্তিত ক্যারেট', border: OutlineInputBorder()),
                    items: [24, 22, 21, 18].map((c) => DropdownMenuItem(value: c, child: Text('$c ক্যারেট'))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _toCarat = val;
                          _convert();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: _voriController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ভরি', border: OutlineInputBorder()), onChanged: (_) => _convert())),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _anaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'আনা', border: OutlineInputBorder()), onChanged: (_) => _convert())),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _rotiController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'রতি', border: OutlineInputBorder()), onChanged: (_) => _convert())),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _pointController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'পয়েন্ট', border: OutlineInputBorder()), onChanged: (_) => _convert())),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('পরিবর্তিত পরিমাণ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(),
                    Text(
                      '${toBanglaDigit(_convertedVori.toInt().toString())} ভরি, ${toBanglaDigit(_convertedAna.toInt().toString())} আনা, ${toBanglaDigit(_convertedRoti.toInt().toString())} রতি, ${toBanglaDigit(_convertedPoint.toStringAsFixed(1))} পয়েন্ট',
                      style: const TextStyle(fontSize: 18, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
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

// ==================== ২. খাদ ক্যালকুলেটর স্ক্রিন ====================

class KhadCalculatorScreen extends StatefulWidget {
  const KhadCalculatorScreen({super.key});

  @override
  State<KhadCalculatorScreen> createState() => _KhadCalculatorScreenState();
}

class _KhadCalculatorScreenState extends State<KhadCalculatorScreen> {
  int _selectedCarat = 22;

  String _getPerVoriPakaText(int carat) {
    if (carat == 22) return "১৪ আনা ৪ রতি ০ পয়েন্ট";
    if (carat == 21) return "১৪ আনা ০ রতি ০ পয়েন্ট";
    if (carat == 18) return "১২ আনা ০ রতি ০ পয়েন্ট";
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('খাদ ক্যালকুলেটর'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: _selectedCarat,
              decoration: const InputDecoration(labelText: 'ক্যারেট নির্বাচন করুন', border: OutlineInputBorder()),
              items: [22, 21, 18].map((c) => DropdownMenuItem(value: c, child: Text('$c ক্যারেট'))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCarat = val);
              },
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('$_selectedCarat ক্যারেট এর প্রতি ভরিতে পাকা সোনা:', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      _getPerVoriPakaText(_selectedCarat),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
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

// ==================== ৩. ওজন যোগ/বিয়োগ স্ক্রিন ====================

class WeightAddSubtractScreen extends StatefulWidget {
  const WeightAddSubtractScreen({super.key});

  @override
  State<WeightAddSubtractScreen> createState() => _WeightAddSubtractScreenState();
}

class _WeightAddSubtractScreenState extends State<WeightAddSubtractScreen> {
  // হিসাবের স্টেট লজিক
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ওজন যোগ/বিয়োগ'), centerTitle: true),
      body: const Center(
        child: Text('ওজন যোগ/বিয়োগ ক্যালকুলেটর চালু আছে', style: TextStyle(fontSize: 16)),
      ),
    );
    }
}

// ==================== ৪. বন্ধকী হিসাব স্ক্রিন ====================

class BondhokiCalculatorScreen extends StatefulWidget {
  const BondhokiCalculatorScreen({super.key});

  @override
  State<BondhokiCalculatorScreen> createState() => _BondhokiCalculatorScreenState();
}

class _BondhokiCalculatorScreenState extends State<BondhokiCalculatorScreen> {
  final TextEditingController _asolController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  int _totalDays = 0;
  double _asol = 0;
  double _rate = 0;
  double _interest = 0;
  double _total = 0;

  @override
  void dispose() {
    _asolController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        _calculateInterest();
      });
    }
  }

  void _calculateInterest() {
    _asol = double.tryParse(_asolController.text) ?? 0;
    _rate = double.tryParse(_rateController.text) ?? 0;

    if (_startDate != null && _endDate != null) {
      _totalDays = _endDate!.difference(_startDate!).inDays;
      if (_totalDays < 0) _totalDays = 0;
    } else {
      _totalDays = 0;
    }

    if (_asol > 0 && _rate > 0 && _totalDays > 0) {
      double yearlyInterest = (_asol * _rate) / 100;
      _interest = (yearlyInterest / 365) * _totalDays;
      _total = _asol + _interest;
    } else {
      _interest = 0;
      _total = 0;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "তারিখ নির্বাচন করুন";
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('বন্ধকী হিসাব'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _asolController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'আসল টাকা (টাকা)', border: OutlineInputBorder()),
              onChanged: (_) => setState(() => _calculateInterest()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'সুদের হার (%) (বার্ষিক)', border: OutlineInputBorder()),
              onChanged: (_) => setState(() => _calculateInterest()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text('শুরু: ${_formatDate(_startDate)}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text('শেষ: ${_formatDate(_endDate)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('মোট দিন: $_totalDays দিন', style: const TextStyle(fontSize: 16)),
                    const Divider(),
                    Text('সুদ: ${_interest.toStringAsFixed(2)} টাকা', style: const TextStyle(fontSize: 18, color: Colors.red)),
                    const SizedBox(height: 8),
                    Text('মোট (আসল + সুদ): ${_total.toStringAsFixed(2)} টাকা', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
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

// ==================== ৫. হাতে ঘাটতি হিসাব স্ক্রিন ====================

class HatLossCalculatorScreen extends StatefulWidget {
  const HatLossCalculatorScreen({super.key});

  @override
  State<HatLossCalculatorScreen> createState() => _HatLossCalculatorScreenState();
}

class _HatLossCalculatorScreenState extends State<HatLossCalculatorScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _lossRateController = TextEditingController();

  double _weight = 0;
  double _lossRate = 0;
  double _totalLoss = 0;
  double _netWeight = 0;

  @override
  void dispose() {
    _weightController.dispose();
    _lossRateController.dispose();
    super.dispose();
  }

  void _calculateLoss() {
    _weight = double.tryParse(_weightController.text) ?? 0;
    _lossRate = double.tryParse(_lossRateController.text) ?? 0;

    if (_weight > 0 && _lossRate > 0) {
      _totalLoss = (_weight * _lossRate) / 100;
      _netWeight = _weight - _totalLoss;
    } else {
      _totalLoss = 0;
      _netWeight = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('হাতে ঘাটতি হিসাব'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'মোট ওজন (গ্রাম বা ভরি)', border: OutlineInputBorder()),
              onChanged: (_) => setState(() => _calculateLoss()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lossRateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'ঘাটতির হার (%)', border: OutlineInputBorder()),
              onChanged: (_) => setState(() => _calculateLoss()),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('মোট ঘাটতি: ${_totalLoss.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Colors.red)),
                    const SizedBox(height: 8),
                    Text('অবশিষ্ট ওজন: ${_netWeight.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
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
