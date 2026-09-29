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
                        child: const Column(
                          children: [
                            Text(
                              'পরমা জুয়েলার্স',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
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
                              title: '২৪ ক্যারেট সোনার\nদাম',
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
                            _buildWhiteCard(
                              context: context,
                              title: 'ওজন যোগ-বিয়োগ',
                              icon: Icons.add,
                              iconColor: Colors.green,
                            ),
                            _buildWhiteCard(
                              context: context,
                              title: 'হাত লস',
                              icon: Icons.back_hand_outlined,
                              iconColor: Colors.brown,
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

// ========== ২. বন্ধকী হিসাব ক্যালকুলেটর পেজ (নতুন সুদের লজিক সহ) ==========
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
  double _calculatedInterestRate = 0.0; // মোট কত পার্সেন্ট সুদ হলো

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

  // ================= আপনার নতুন সুদের কাস্টম লজিক =================
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

      // মোট পূর্ণ মাস বের করা
      int totalFullMonths = m + (y * 12);
      double effectiveMonths = totalFullMonths.toDouble();

      // ১-১৫ দিন = ০.৫ মাস (হাফ সুদ), ১৬-৩১ দিন = ১ পূর্ণ মাস (ফুল সুদ)
      if (d >= 1 && d <= 15) {
        effectiveMonths += 0.5;
      } else if (d >= 16) {
        effectiveMonths += 1.0;
      }

      // মোট সুদের শতকরা হার (%)
      _calculatedInterestRate = effectiveMonths * monthlyRate;

      // মোট সুদের টাকা
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
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
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
                  decoration: const InputDecoration(
                    hintText: 'যেমন: ১০০০০',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      "$_years বছর, $_months মাস, $_days দিন",
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
                  decoration: const InputDecoration(
                    hintText: '২.০',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          "${_calculatedInterestRate.toStringAsFixed(1)}%",
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
                          "৳ ${_totalInterest.toStringAsFixed(2)}",
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
                          "৳ ${_totalAmount.toStringAsFixed(2)}",
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
