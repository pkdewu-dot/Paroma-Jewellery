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
        primarySwatch: Colors.red,
      ),
      home: const HomeScreen(),
    );
  }
}

// ================= হেল্পার ফাংশন: বাংলা ডিজিট ও কমা ফরম্যাটিং =================

/// ইংরেজি সংখ্যাকে বাংলা ডিজিটে (০-৯) রূপান্তর করার ফাংশন
String toBanglaDigit(String input) {
  const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

  for (int i = 0; i < englishDigits.length; i++) {
    input = input.replaceAll(englishDigits[i], banglaDigits[i]);
  }
  return input;
}

/// সংখ্যানুসারে বাংলাদেশি কমা (১,০০,০০০ / ১০,০০,০০০) ফরম্যাট করার ফাংশন
String formatNumberWithCommas(double number, {bool isCurrency = false}) {
  String numStr = isCurrency ? number.toStringAsFixed(2) : number.toStringAsFixed(1);
  List<String> parts = numStr.split('.');
  String integerPart = parts[0];
  String decimalPart = parts.length > 1 ? parts[1] : '';

  if (integerPart.length > 3) {
    String lastThree = integerPart.substring(integerPart.length - 3);
    String remaining = integerPart.substring(0, integerPart.length - 3);

    RegExp regExp = RegExp(r'\d{1,2}(?=(\d{2})+(?!\d))');
    String formattedRemaining = remaining.replaceAllMapped(regExp, (Match m) => '${m[0]},');

    integerPart = '$formattedRemaining,$lastThree';
  }

  if (isCurrency) {
    return toBanglaDigit('$integerPart.$decimalPart');
  } else {
    return decimalPart == '0' ? toBanglaDigit(integerPart) : toBanglaDigit('$integerPart.$decimalPart');
  }
}

// ================= ১. হোম স্ক্রিন =================
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
              // কাস্টম অ্যাপ বার
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

                      // দোকানের নাম ও ঠিকানা সংবলিত ব্যানার
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B0000),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'পরমা জুয়েলার্স',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              toBanglaDigit('কাপুড়িয়া পট্টি, চৌরাস্তা, যশোর'),
                              style: const TextStyle(
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

                      // নোটিফিকেশন বার
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

                      // গ্রিড বাটনসমূহ
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
                              context: context,
                              title: toBanglaDigit('২৪ ক্যারেট সোনার\nদাম'),
                              icon: Icons.star_border,
                              iconColor: Colors.amber,
                            ),
                            _buildWhiteCard(
                              context: context,
                              title: 'আজকের বাজার',
                              icon: Icons.storefront_outlined,
                              iconColor: Colors.pink,
                            ),
                            _buildWhiteCard(
                              context: context,
                              title: 'স্বর্ণের মূল্য\nক্যালকুলেটর',
                              icon: Icons.calculate_outlined,
                              iconColor: Colors.blue,
                            ),
                            _buildWhiteCard(
                              context: context,
                              title: 'সোনার দামের\nইতিহাস',
                              icon: Icons.access_time,
                              iconColor: Colors.purple,
                            ),
                            _buildWhiteCard(
                              context: context,
                              title: 'পাকা পরতা\nক্যালকুলেটর',
                              icon: Icons.layers_outlined,
                              iconColor: Colors.teal,
                            ),
                            _buildWhiteCard(
                              context: context,
                              title: 'খাদ হিসাব',
                              icon: Icons.pie_chart_outline,
                              iconColor: Colors.indigo,
                            ),
                            _buildWhiteCard(
                              context: context,
                              title: 'ভরি ও পয়েন্ট\nকনভার্টার',
                              icon: Icons.swap_horiz,
                              iconColor: Colors.deepOrange,
                            ),
                            _buildWhiteCard(
                              context: context,
                              title: 'ক্যারেট কনভার্টার',
                              icon: Icons.tune,
                              iconColor: Colors.red,
                            ),
                            // ওজন যোগ-বিয়োগ (এক্টিভ অপশন)
                            _buildWhiteCard(
                              context: context,
                              title: 'ওজন যোগ-বিয়োগ',
                              icon: Icons.add,
                              iconColor: Colors.green,
                              targetScreen: const WeightAddSubtractScreen(),
                            ),
                            // হাত লস (এক্টিভ অপশন)
                            _buildWhiteCard(
                              context: context,
                              title: 'হাত লস',
                              icon: Icons.back_hand_outlined,
                              iconColor: Colors.brown,
                              targetScreen: const HatLossCalculatorScreen(),
                            ),
                            // বন্ধকী হিসাব (এক্টিভ অপশন)
                            _buildWhiteCard(
                              context: context,
                              title: 'বন্ধকী হিসাব',
                              icon: Icons.account_balance_wallet_outlined,
                              iconColor: Colors.deepPurple,
                              targetScreen: const BondhokiCalculatorScreen(),
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
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    Widget? targetScreen,
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
          onTap: () {
            if (targetScreen != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => targetScreen),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title - অপশনটি নিয়ে কাজ চলছে...'),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
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

// ========== ২. বন্ধকী হিসাব ক্যালকুলেটর পেজ ==========
class BondhokiCalculatorScreen extends StatefulWidget {
  const BondhokiCalculatorScreen({super.key});

  @override
  State<BondhokiCalculatorScreen> createState() => _BondhokiCalculatorScreenState();
}

class _BondhokiCalculatorScreenState extends State<BondhokiCalculatorScreen> {
  final TextEditingController _asolController = TextEditingController();
  final TextEditingController _rateController = TextEditingController(text: "2.0");

  DateTime? _takenDate;
  DateTime _todayDate = DateTime.now();

  double _totalInterest = 0.0;
  double _totalAmount = 0.0;
  double _calculatedInterestRate = 0.0;

  int _years = 0;
  int _months = 0;
  int _days = 0;

  Future<void> _selectTakenDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _takenDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _takenDate) {
      setState(() {
        _takenDate = picked;
        _calculateInterest();
      });
    }
  }

  Future<void> _selectTodayDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _todayDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _todayDate) {
      setState(() {
        _todayDate = picked;
        _calculateInterest();
      });
    }
  }

  void _calculateInterest() {
    double asol = double.tryParse(_asolController.text) ?? 0.0;
    double monthlyRate = double.tryParse(_rateController.text) ?? 2.0;

    if (asol > 0 && _takenDate != null) {
      DateTime start = _takenDate!;
      DateTime end = _todayDate;

      if (end.isBefore(start)) {
        setState(() {
          _years = 0;
          _months = 0;
          _days = 0;
          _totalInterest = 0.0;
          _totalAmount = asol;
          _calculatedInterestRate = 0.0;
        });
        return;
      }

      int y = end.year - start.year;
      int m = end.month - start.month;
      int d = end.day - start.day;

      if (d < 0) {
        m--;
        DateTime prevMonth = DateTime(end.year, end.month, 0);
        d += prevMonth.day;
      }
      if (m < 0) {
        y--;
        m += 12;
      }

      _years = y;
      _months = m;
      _days = d;

      int totalFullMonths = m + (y * 12);
      double effectiveMonths = totalFullMonths.toDouble();

      if (d >= 1 && d <= 15) {
        effectiveMonths += 0.5;
      } else if (d >= 16) {
        effectiveMonths += 1.0;
      }

      _calculatedInterestRate = effectiveMonths * monthlyRate;
      _totalInterest = (asol * _calculatedInterestRate) / 100;
      _totalAmount = asol + _totalInterest;
    } else {
      _totalInterest = 0.0;
      _totalAmount = asol;
      _calculatedInterestRate = 0.0;
    }
    setState(() {});
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "তারিখ নির্বাচন করুন";
    String formatted = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    return toBanglaDigit(formatted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('বন্ধকী হিসাব', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF3B30),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputCard(
                title: "আসল (টাকা)",
                child: TextField(
                  controller: _asolController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: toBanglaDigit('যেমন: ১০,০০০ বা ১,০০,০০০'),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (val) => _calculateInterest(),
                ),
              ),

              const SizedBox(height: 12),

              _buildInputCard(
                title: "নেওয়ার তারিখ (দিন/মাস/বছর)",
                child: InkWell(
                  onTap: () => _selectTakenDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDate(_takenDate), style: const TextStyle(fontSize: 16)),
                        const Icon(Icons.calendar_today, color: Colors.redAccent),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _buildInputCard(
                title: "আজকের তারিখ (দিন/মাস/বছর)",
                child: InkWell(
                  onTap: () => _selectTodayDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDate(_todayDate), style: const TextStyle(fontSize: 16)),
                        const Icon(Icons.calendar_today, color: Colors.redAccent),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("মোট সময় হয়েছে:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 4),
                    Text(
                      toBanglaDigit("$_years বছর, $_months মাস, $_days দিন"),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _buildInputCard(
                title: "সুদের হার (% প্রতি মাস)",
                child: TextField(
                  controller: _rateController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: toBanglaDigit('২.০'),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (val) => _calculateInterest(),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("মোট সুদের হার:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        Text(
                          "${formatNumberWithCommas(_calculatedInterestRate)}%",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("মোট সুদ:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Text(
                          "৳ ${formatNumberWithCommas(_totalInterest, isCurrency: true)}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("সুদাসল (মোট টাকা):", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          "৳ ${formatNumberWithCommas(_totalAmount, isCurrency: true)}",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ========== ৩. হাত লস ক্যালকুলেটর পেজ ==========
class HatLossCalculatorScreen extends StatefulWidget {
  const HatLossCalculatorScreen({super.key});

  @override
  State<HatLossCalculatorScreen> createState() => _HatLossCalculatorScreenState();
}

class _HatLossCalculatorScreenState extends State<HatLossCalculatorScreen> {
  final TextEditingController _lossRateController = TextEditingController(text: "80");

  final TextEditingController _voriController = TextEditingController();
  final TextEditingController _anaController = TextEditingController();
  final TextEditingController _rotiController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();

  double _totalLossPoints = 0.0;
  int _resultAna = 0;
  int _resultRoti = 0;
  double _resultPoint = 0.0;

  void _calculateHatLoss() {
    double lossRatePerVoriPoints = double.tryParse(_lossRateController.text) ?? 80.0;

    double vori = double.tryParse(_voriController.text) ?? 0.0;
    double ana = double.tryParse(_anaController.text) ?? 0.0;
    double roti = double.tryParse(_rotiController.text) ?? 0.0;
    double point = double.tryParse(_pointController.text) ?? 0.0;

    double totalJewelleryPoints = (vori * 960) + (ana * 60) + (roti * 10) + point;

    if (totalJewelleryPoints > 0 && lossRatePerVoriPoints > 0) {
      _totalLossPoints = (totalJewelleryPoints * lossRatePerVoriPoints) / 960.0;

      int totalAna = (_totalLossPoints / 60).floor();
      double remPointsAfterAna = _totalLossPoints % 60;

      int rotiCount = (remPointsAfterAna / 10).floor();
      double finalPoints = remPointsAfterAna % 10;

      _resultAna = totalAna;
      _resultRoti = rotiCount;
      _resultPoint = finalPoints;
    } else {
      _totalLossPoints = 0.0;
      _resultAna = 0;
      _resultRoti = 0;
      _resultPoint = 0.0;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('হাত লস হিসাব', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF3B30),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard(
                title: "ভরি প্রতি লসের হার (পয়েন্টে)",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _lossRateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: toBanglaDigit('৮০'),
                        suffixText: 'পয়েন্ট',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onChanged: (val) => _calculateHatLoss(),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      toBanglaDigit('* বাই ডিফল্ট: ৮০ পয়েন্ট (১ আনা ২ রতি) সেট করা আছে'),
                      style: const TextStyle(fontSize: 12, color: Colors.brown, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _buildCard(
                title: "গহনার ওজন লিখুন",
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildWeightInputField(
                            label: "ভরি",
                            controller: _voriController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildWeightInputField(
                            label: "আনা",
                            controller: _anaController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildWeightInputField(
                            label: "রতি",
                            controller: _rotiController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildWeightInputField(
                            label: "পয়েন্ট",
                            controller: _pointController,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                  border: Border.all(color: Colors.brown.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      "মোট হাত লস",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLossResultText("$_resultAna", "আনা"),
                        const SizedBox(width: 12),
                        _buildLossResultText("$_resultRoti", "রতি"),
                        const SizedBox(width: 12),
                        _buildLossResultText(_resultPoint.toStringAsFixed(1), "পয়েন্ট"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        toBanglaDigit("মোট লস: ${_totalLossPoints.toStringAsFixed(2)} পয়েন্ট"),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLossResultText(String value, String unit) {
    return Column(
      children: [
        Text(
          toBanglaDigit(value),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
        ),
        Text(
          unit,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildWeightInputField({required String label, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      onChanged: (val) => _calculateHatLoss(),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ========== ৪. ওজন যোগ-বিয়োগ স্ক্রিন (নতুন সংযোজন) ==========
class WeightAddSubtractScreen extends StatefulWidget {
  const WeightAddSubtractScreen({super.key});

  @override
  State<WeightAddSubtractScreen> createState() => _WeightAddSubtractScreenState();
}

class _WeightAddSubtractScreenState extends State<WeightAddSubtractScreen> {
  String _displayExpression = ""; 
  String _currentNumberInput = ""; 
  
  List<double> _weightPointsList = []; 
  List<String> _operatorsList = [];

  double _currentVori = 0;
  double _currentAna = 0;
  double _currentRoti = 0;
  double _currentPoint = 0;

  // ডিজিট ইনপুট
  void _onDigitPress(String digit) {
    setState(() {
      _currentNumberInput += digit;
      _displayExpression += toBanglaDigit(digit);
    });
  }

  // ভরি, আনা, রতি, পয়েন্ট বাটনের লজিক
  void _onUnitPress(String unit) {
    if (_currentNumberInput.isEmpty) return;

    double val = double.tryParse(_currentNumberInput) ?? 0;
    if (unit == 'ভরি') _currentVori = val;
    if (unit == 'আনা') _currentAna = val;
    if (unit == 'রতি') _currentRoti = val;
    if (unit == 'পয়েন্ট') _currentPoint = val;

    setState(() {
      _displayExpression += " $unit ";
      _currentNumberInput = "";
    });
  }

  // অপরেটর (+ / -) বাটনের লজিক
  void _onOperatorPress(String op) {
    _pushCurrentWeightToPoints();

    setState(() {
      _operatorsList.add(op);
      _displayExpression += " $op ";
    });
  }

  void _pushCurrentWeightToPoints() {
    double totalPts = (_currentVori * 960) + (_currentAna * 60) + (_currentRoti * 10) + _currentPoint;
    _weightPointsList.add(totalPts);

    _currentVori = 0;
    _currentAna = 0;
    _currentRoti = 0;
    _currentPoint = 0;
    _currentNumberInput = "";
  }

  // '=' বাটন লজিক
  void _onEqualPress() {
    if (_currentNumberInput.isNotEmpty || _currentVori > 0 || _currentAna > 0 || _currentRoti > 0 || _currentPoint > 0) {
      _pushCurrentWeightToPoints();
    }

    if (_weightPointsList.isEmpty) return;

    double resultPts = _weightPointsList[0];

    for (int i = 0; i < _operatorsList.length; i++) {
      if (i + 1 < _weightPointsList.length) {
        if (_operatorsList[i] == '+') {
          resultPts += _weightPointsList[i + 1];
        } else if (_operatorsList[i] == '-') {
          resultPts -= _weightPointsList[i + 1];
        }
      }
    }

    // ফলাফলকে পুনরায় ভরি, আনা, রতি ও পয়েন্টে পরিবর্তন
    bool isNegative = resultPts < 0;
    double absPts = resultPts.abs();

    int vori = (absPts / 960).floor();
    double rem1 = absPts % 960;

    int ana = (rem1 / 60).floor();
    double rem2 = rem1 % 60;

    int roti = (rem2 / 10).floor();
    double point = rem2 % 10;

    String resStr = "";
    if (vori > 0) resStr += "$vori ভরি ";
    if (ana > 0) resStr += "$ana আনা ";
    if (roti > 0) resStr += "$roti রতি ";
    if (point > 0 || resStr.isEmpty) resStr += "${point.toStringAsFixed(1)} পয়েন্ট";

    if (isNegative) resStr = "- $resStr";

    setState(() {
      _displayExpression = toBanglaDigit(resStr);
      _clearCalculationData();
    });
  }

  void _clearCalculationData() {
    _currentNumberInput = "";
    _weightPointsList.clear();
    _operatorsList.clear();
    _currentVori = 0;
    _currentAna = 0;
    _currentRoti = 0;
    _currentPoint = 0;
  }

  void _onACPress() {
    setState(() {
      _displayExpression = "";
      _clearCalculationData();
    });
  }

  void _onDelPress() {
    if (_displayExpression.isNotEmpty) {
      setState(() {
        _displayExpression = _displayExpression.substring(0, _displayExpression.length - 1);
        if (_currentNumberInput.isNotEmpty) {
          _currentNumberInput = _currentNumberInput.substring(0, _currentNumberInput.length - 1);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ওজন যোগ-বিয়োগ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF3B30),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // ১. ক্যালকুলেটরের বড় ডিসপ্লে স্ক্রিন
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.black87,
              alignment: Alignment.bottomRight,
              child: SingleChildScrollView(
                reverse: true,
                child: Text(
                  _displayExpression.isEmpty ? '০' : _displayExpression,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ),

          // ২. ৪টি অরেঞ্জ হাইলাইটেড বাটন (ভরি, আনা, রতি, পয়েন্ট)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                _buildUnitButton('ভরি'),
                const SizedBox(width: 6),
                _buildUnitButton('আনা'),
                const SizedBox(width: 6),
                _buildUnitButton('রতি'),
                const SizedBox(width: 6),
                _buildUnitButton('পয়েন্ট'),
              ],
            ),
          ),

          // ৩. ক্যালকুলেটর কিপ্যাড (১-০, AC, Del, +, -, =)
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _buildCalcButton('AC', color: Colors.redAccent, textColor: Colors.white, onTap: _onACPress),
                        _buildCalcButton('Del', color: Colors.orange.shade800, textColor: Colors.white, onTap: _onDelPress),
                        _buildCalcButton('-', color: Colors.amber.shade700, textColor: Colors.white, onTap: () => _onOperatorPress('-')),
                        _buildCalcButton('+', color: Colors.amber.shade700, textColor: Colors.white, onTap: () => _onOperatorPress('+')),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        _buildCalcButton('7', onTap: () => _onDigitPress('7')),
                        _buildCalcButton('8', onTap: () => _onDigitPress('8')),
                        _buildCalcButton('9', onTap: () => _onDigitPress('9')),
                        _buildCalcButton('=', color: Colors.green, textColor: Colors.white, isEqual: true, onTap: _onEqualPress),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        _buildCalcButton('4', onTap: () => _onDigitPress('4')),
                        _buildCalcButton('5', onTap: () => _onDigitPress('5')),
                        _buildCalcButton('6', onTap: () => _onDigitPress('6')),
                        const Expanded(child: SizedBox()), 
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        _buildCalcButton('1', onTap: () => _onDigitPress('1')),
                        _buildCalcButton('2', onTap: () => _onDigitPress('2')),
                        _buildCalcButton('3', onTap: () => _onDigitPress('3')),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        _buildCalcButton('0', flex: 2, onTap: () => _onDigitPress('0')),
                        _buildCalcButton('.', onTap: () => _onDigitPress('.')),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // অরেঞ্জ কালারের ভরি, আনা, রতি, পয়েন্ট বাটন তৈরির উইজেট
  Widget _buildUnitButton(String label) {
    return Expanded(
      child: Material(
        color: Colors.deepOrange,
        borderRadius: BorderRadius.circular(8),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _onUnitPress(label),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ক্যালকুলেটর কিপ্যাড বাটন তৈরির উইজেট
  Widget _buildCalcButton(
    String label, {
    Color color = Colors.white,
    Color textColor = Colors.black87,
    int flex = 1,
    bool isEqual = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(8),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Center(
              child: Text(
                toBanglaDigit(label),
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
