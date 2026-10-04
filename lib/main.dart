import 'package:flutter/material.dart';
import 'todays_market_page.dart';

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

/// সংখ্যানুসারে বাংলাদেশি কমা ফরম্যাট করার ফাংশন
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
                              targetScreen: const TodaysMarketPage(),
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
                              targetScreen: const GoldCalculatorScreen(),
                            ),
                            _buildWhiteCard(
                              context: context,
                              title: 'খাদ হিসাব',
                              icon: Icons.pie_chart_outline,
                              iconColor: Colors.indigo,
                              targetScreen: const KhadCalculatorScreen(),
                            ),
                            _buildWhiteCard(
                              context: context,
                              title: 'ভরি ও পয়েন্ট\nকনভার্টার',
                              icon: Icons.swap_horiz,
                              iconColor: Colors.deepOrange,
                              targetScreen: const VoriPointConverterScreen(),
                            ),
                            _buildWhiteCard(
                              context: context,
                              title: 'ক্যারেট কনভার্টার',
                              icon: Icons.tune,
                              iconColor: Colors.red,
                              targetScreen: const CaratConverterScreen(),
                            ),
                            _buildWhiteCard(
                              context: context,
                              title: 'ওজন যোগ-বিয়োগ',
                              icon: Icons.add,
                              iconColor: Colors.green,
                              targetScreen: const WeightAddSubtractScreen(),
                            ),
                            _buildWhiteCard(
                              context: context,
                              title: 'হাত লস',
                              icon: Icons.back_hand_outlined,
                              iconColor: Colors.brown,
                              targetScreen: const HatLossCalculatorScreen(),
                            ),
                            _buildWhiteCard(
                              context: context,
                              title: 'বন্ধকী হিসাব',
                              icon: Icons.account_balance_wallet_outlined,
                              iconColor: Colors.deepPurple,
                              targetScreen: const BondhokiCalculatorScreen(),
                            ),
                            _buildWhiteCard(
                              context: context,
                              title: 'কারিগর খতিয়ান',
                              icon: Icons.menu_book_outlined,
                              iconColor: Colors.amber.shade900,
                              targetScreen: const KarigorKhotiyanScreen(),
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

// ========== কারিগর খতিয়ান স্ক্রিন ==========
class KarigorKhotiyanScreen extends StatefulWidget {
  const KarigorKhotiyanScreen({super.key});

  @override
  State<KarigorKhotiyanScreen> createState() => _KarigorKhotiyanScreenState();
}

class _KarigorKhotiyanScreenState extends State<KarigorKhotiyanScreen> {
  final TextEditingController _prodanVori = TextEditingController();
  final TextEditingController _prodanAna = TextEditingController();
  final TextEditingController _prodanRoti = TextEditingController();
  final TextEditingController _prodanPoint = TextEditingController();

  final TextEditingController _gohonaVori = TextEditingController();
  final TextEditingController _gohonaAna = TextEditingController();
  final TextEditingController _gohonaRoti = TextEditingController();
  final TextEditingController _gohonaPoint = TextEditingController();

  final TextEditingController _bakiVori = TextEditingController();
  final TextEditingController _bakiAna = TextEditingController();
  final TextEditingController _bakiRoti = TextEditingController();
  final TextEditingController _bakiPoint = TextEditingController();

  final TextEditingController _hatLossVori = TextEditingController();
  final TextEditingController _hatLossAna = TextEditingController();
  final TextEditingController _hatLossRoti = TextEditingController();
  final TextEditingController _hatLossPoint = TextEditingController();

  final TextEditingController _onnannoVori = TextEditingController();
  final TextEditingController _onnannoAna = TextEditingController();
  final TextEditingController _onnannoRoti = TextEditingController();
  final TextEditingController _onnannoPoint = TextEditingController();

  final TextEditingController _praptiVori = TextEditingController();
  final TextEditingController _praptiAna = TextEditingController();
  final TextEditingController _praptiRoti = TextEditingController();
  final TextEditingController _praptiPoint = TextEditingController();

  String _resultText = '';
  Color _resultColor = Colors.black;

  double _convertToPoints(String v, String a, String r, String p) {
    double vori = double.tryParse(v) ?? 0;
    double ana = double.tryParse(a) ?? 0;
    double roti = double.tryParse(r) ?? 0;
    double point = double.tryParse(p) ?? 0;

    return (vori * 960) + (ana * 60) + (roti * 10) + point;
  }

  Map<String, double> _convertFromPoints(double totalPoints) {
    double temp = totalPoints.abs();

    int vori = temp ~/ 960;
    temp = temp % 960;

    int ana = temp ~/ 60;
    temp = temp % 60;

    int roti = temp ~/ 10;
    double point = temp % 10;

    return {
      'vori': vori.toDouble(),
      'ana': ana.toDouble(),
      'roti': roti.toDouble(),
      'point': double.parse(point.toStringAsFixed(1)),
    };
  }

  void _calculateAll() {
    setState(() {
      double prodanPoints = _convertToPoints(_prodanVori.text, _prodanAna.text, _prodanRoti.text, _prodanPoint.text);
      double gohonaPoints = _convertToPoints(_gohonaVori.text, _gohonaAna.text, _gohonaRoti.text, _gohonaPoint.text);
      double bakiPoints = _convertToPoints(_bakiVori.text, _bakiAna.text, _bakiRoti.text, _bakiPoint.text);
      double onnannoPoints = _convertToPoints(_onnannoVori.text, _onnannoAna.text, _onnannoRoti.text, _onnannoPoint.text);

      double calculatedLossPoints = (gohonaPoints * 80.0) / 960.0;
      var lossFormatted = _convertFromPoints(calculatedLossPoints);

      _hatLossVori.text = lossFormatted['vori']!.toInt().toString();
      _hatLossAna.text = lossFormatted['ana']!.toInt().toString();
      _hatLossRoti.text = lossFormatted['roti']!.toInt().toString();
      _hatLossPoint.text = lossFormatted['point']!.toString();

      double totalPraptiPoints = gohonaPoints + bakiPoints + calculatedLossPoints + onnannoPoints;
      var praptiFormatted = _convertFromPoints(totalPraptiPoints);

      _praptiVori.text = praptiFormatted['vori']!.toInt().toString();
      _praptiAna.text = praptiFormatted['ana']!.toInt().toString();
      _praptiRoti.text = praptiFormatted['roti']!.toInt().toString();
      _praptiPoint.text = praptiFormatted['point']!.toString();

      double diffPoints = prodanPoints - totalPraptiPoints;
      var diffFormatted = _convertFromPoints(diffPoints);

      String resStr = toBanglaDigit("${diffFormatted['vori']!.toInt()} ভরি ${diffFormatted['ana']!.toInt()} আনা ${diffFormatted['roti']!.toInt()} রতি ${diffFormatted['point']} পয়েন্ট");

      if (diffPoints.abs() < 0.1) {
        _resultText = "হিসাব সমান (০ গোলমাল)";
        _resultColor = Colors.green.shade800;
      } else if (diffPoints > 0) {
        _resultText = "কারিগর থেকে পাওনা বাকি: $resStr";
        _resultColor = Colors.red.shade800;
      } else {
        _resultText = "কারিগর বেশি জমা দিয়েছে: $resStr";
        _resultColor = Colors.blue.shade800;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('কারিগর খতিয়ান', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              _buildSectionHeader("কারিগর কে প্রদান"),
              _buildFourInputBoxes(
                v: _prodanVori, a: _prodanAna, r: _prodanRoti, p: _prodanPoint,
                onChanged: (_) => _calculateAll(),
              ),
              const Divider(height: 28, thickness: 1.5),

              _buildSectionHeader("কারিগর থেকে বুজ"),
              
              _buildSubHeader("গহনার ওজন"),
              _buildFourInputBoxes(
                v: _gohonaVori, a: _gohonaAna, r: _gohonaRoti, p: _gohonaPoint,
                onChanged: (_) => _calculateAll(),
              ),
              const SizedBox(height: 10),

              _buildSubHeader("বাকি সোনার ওজন"),
              _buildFourInputBoxes(
                v: _bakiVori, a: _bakiAna, r: _bakiRoti, p: _bakiPoint,
                onChanged: (_) => _calculateAll(),
              ),
              const SizedBox(height: 10),

              _buildSubHeader("হাত লস (প্রতি ভরি ১ আনা ২ রতি)"),
              _buildFourInputBoxes(
                v: _hatLossVori, a: _hatLossAna, r: _hatLossRoti, p: _hatLossPoint,
                readOnly: true,
              ),
              const SizedBox(height: 10),

              _buildSubHeader("অন্যান্য"),
              _buildFourInputBoxes(
                v: _onnannoVori, a: _onnannoAna, r: _onnannoRoti, p: _onnannoPoint,
                onChanged: (_) => _calculateAll(),
              ),
              const Divider(height: 28, thickness: 1.5),

              _buildSectionHeader("কারিগর থেকে মোট প্রাপ্তি"),
              _buildFourInputBoxes(
                v: _praptiVori, a: _praptiAna, r: _praptiRoti, p: _praptiPoint,
                readOnly: true,
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _resultColor, width: 1.5),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Column(
                  children: [
                    const Text("ফলাফল (প্রদান - মোট প্রাপ্তি)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text(
                      _resultText.isEmpty ? "উপরে ইনপুট দিন" : _resultText,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _resultColor),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF6B0000)),
      ),
    );
  }

  Widget _buildSubHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildFourInputBoxes({
    required TextEditingController v,
    required TextEditingController a,
    required TextEditingController r,
    required TextEditingController p,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return Row(
      children: [
        Expanded(child: _buildSingleBox("ভরি", v, readOnly, onChanged)),
        const SizedBox(width: 6),
        Expanded(child: _buildSingleBox("আনা", a, readOnly, onChanged)),
        const SizedBox(width: 6),
        Expanded(child: _buildSingleBox("রতি", r, readOnly, onChanged)),
        const SizedBox(width: 6),
        Expanded(child: _buildSingleBox("পয়েন্ট", p, readOnly, onChanged)),
      ],
    );
  }

  Widget _buildSingleBox(String label, TextEditingController controller, bool readOnly, Function(String)? onChanged) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        isDense: true,
        filled: true,
        fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      ),
    );
  }
}

// ========== ২. খাদ হিসাব স্ক্রিন ==========
class KhadCalculatorScreen extends StatefulWidget {
  const KhadCalculatorScreen({super.key});

  @override
  State<KhadCalculatorScreen> createState() => _KhadCalculatorScreenState();
}

class _KhadCalculatorScreenState extends State<KhadCalculatorScreen> {
  int _selectedCarat = 22;

  final TextEditingController _voriController = TextEditingController();
  final TextEditingController _anaController = TextEditingController();
  final TextEditingController _rotiController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();

  String _resultKhad = "";
  String _resultPaka = "";

  double _getKhadRatio(int carat) {
    if (carat == 22) return (1 * 60 + 2 * 10) / 960.0; 
    if (carat == 21) return (2 * 60) / 960.0;          
    if (carat == 18) return (4 * 60) / 960.0;          
    return 0.0;
  }

  String _getPerVoriKhadText(int carat) {
    if (carat == 22) return "১ আনা ২ রতি ০ পয়েন্ট (৮.৩৩%)";
    if (carat == 21) return "২ আনা ০ রতি ০ পয়েন্ট (১২.৫%)";
    if (carat == 18) return "৪ আনা ০ রতি ০ পয়েন্ট (২৫%)";
    return "";
  }

  String _getPerVoriPakaText(int carat) {
    if (carat == 22) return "১৪ আনা ৪ রতি ০ পয়েন্ট";
    if (carat == 21) return "১৪ আনা ০ রতি ০ পয়েন্ট";
    if (carat == 18) return "১২ আনা ০ রতি ০ পয়েন্ট";
    return "";
  }

  void _calculateKhadAndPaka() {
    FocusScope.of(context).unfocus();

    double vori = double.tryParse(_voriController.text) ?? 0;
    double ana = double.tryParse(_anaController.text) ?? 0;
    double roti = double.tryParse(_rotiController.text) ?? 0;
    double point = double.tryParse(_pointController.text) ?? 0;

    double totalInputPoints = (vori * 960) + (ana * 60) + (roti * 10) + point;

    if (totalInputPoints <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে সঠিক গহনার ওজন দিন')),
      );
      return;
    }

    double khadRatio = _getKhadRatio(_selectedCarat);
    double totalKhadPoints = totalInputPoints * khadRatio;
    double totalPakaPoints = totalInputPoints - totalKhadPoints;

    setState(() {
      _resultKhad = _formatPointsToKhadUnit(totalKhadPoints);
      _resultPaka = _formatPointsToPakaUnit(totalPakaPoints);
    });
  }

  String _formatPointsToKhadUnit(double totalPoints) {
    int totalPts = totalPoints.round();
    int ana = totalPts ~/ 60;
    int rem = totalPts % 60;
    int roti = rem ~/ 10;
    double point = rem % 10 + (totalPoints - totalPoints.floor());

    return toBanglaDigit("$ana আনা $roti রতি ${point.toStringAsFixed(1).replaceAll('.0', '')} পয়েন্ট");
  }

  String _formatPointsToPakaUnit(double totalPoints) {
    int totalPts = totalPoints.round();
    int vori = totalPts ~/ 960;
    int rem1 = totalPts % 960;
    int ana = rem1 ~/ 60;
    int rem2 = rem1 % 60;
    int roti = rem2 ~/ 10;
    double point = rem2 % 10 + (totalPoints - totalPoints.floor());

    String res = "";
    if (vori > 0) res += "$vori ভরি ";
    res += "$ana আনা $roti রতি ${point.toStringAsFixed(1).replaceAll('.0', '')} পয়েন্ট";

    return toBanglaDigit(res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('খাদ হিসাব', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF3B30),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ক্যারেট সিলেক্ট করুন',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade700, width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedCarat,
                  isExpanded: true,
                  style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                  items: const [
                    DropdownMenuItem(value: 22, child: Text('২২ ক্যারেট')),
                    DropdownMenuItem(value: 21, child: Text('২১ ক্যারেট')),
                    DropdownMenuItem(value: 18, child: Text('১৮ ক্যারেট')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCarat = val;
                        _resultKhad = "";
                        _resultPaka = "";
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoDisplayBox(
              title: "ভরি প্রতি খাদ:",
              value: toBanglaDigit(_getPerVoriKhadText(_selectedCarat)),
              valueColor: Colors.red.shade700,
            ),
            const SizedBox(height: 12),
            _buildInfoDisplayBox(
              title: "ভরি প্রতি পাকা:",
              value: toBanglaDigit(_getPerVoriPakaText(_selectedCarat)),
              valueColor: Colors.green.shade700,
            ),
            const SizedBox(height: 20),
            const Text(
              'গহনার ওজন ইনপুট দেন',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildWeightInput(_voriController, 'ভরি')),
                const SizedBox(width: 8),
                Expanded(child: _buildWeightInput(_anaController, 'আনা')),
                const SizedBox(width: 8),
                Expanded(child: _buildWeightInput(_rotiController, 'রতি')),
                const SizedBox(width: 8),
                Expanded(child: _buildWeightInput(_pointController, 'পয়েন্ট')),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 3,
                ),
                onPressed: _calculateKhadAndPaka,
                child: const Text(
                  'হিসাব করুন',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_resultKhad.isNotEmpty && _resultPaka.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ফলাফল:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
                    const Divider(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('মোট খাদ: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            _resultKhad,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('মোট পাকা: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            _resultPaka,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoDisplayBox({required String title, required String value, required Color valueColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInput(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

// ========== ৩. বন্ধকী হিসাব ক্যালকুলেটর পেজ ==========
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

// ========== ৪. হাত লস ক্যালকুলেটর পেজ ==========
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

// ========== ৫. ওজন যোগ-বিয়োগ স্ক্রিন ==========
class WeightAddSubtractScreen extends StatefulWidget {
  const WeightAddSubtractScreen({super.key});

  @override
  State<WeightAddSubtractScreen> createState() => _WeightAddSubtractScreenState();
}

class _WeightAddSubtractScreenState extends State<WeightAddSubtractScreen> {
  String _displayExpression = ""; 
  String _currentNumberInput = ""; 
  
  final List<double> _weightPointsList = []; 
  final List<String> _operatorsList = [];

  double _currentVori = 0;
  double _currentAna = 0;
  double _currentRoti = 0;
  double _currentPoint = 0;

  void _onDigitPress(String digit) {
    setState(() {
      _currentNumberInput += digit;
      _displayExpression += toBanglaDigit(digit);
    });
  }

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

// ========== ৬. ক্যারেট কনভার্টার স্ক্রিন ==========
class CaratConverterScreen extends StatefulWidget {
  const CaratConverterScreen({super.key});

  @override
  State<CaratConverterScreen> createState() => _CaratConverterScreenState();
}

class _CaratConverterScreenState extends State<CaratConverterScreen> {
  String selectedCalculationType = 'ক্যারেট থেকে খাঁটি ও খাদ বের করা';
  int targetCarat = 24; 
  int currentCarat = 18;

  final TextEditingController _voriController = TextEditingController();
  final TextEditingController _anaController = TextEditingController();
  final TextEditingController _rotiController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();

  String? resultTotalWeight;
  String? resultPureGold;
  String? resultAlloy;
  String? resultMessage;

  double _inputsToTotalPoints() {
    double vori = double.tryParse(_voriController.text) ?? 0;
    double ana = double.tryParse(_anaController.text) ?? 0;
    double roti = double.tryParse(_rotiController.text) ?? 0;
    double point = double.tryParse(_pointController.text) ?? 0;

    return (vori * 960) + (ana * 60) + (roti * 10) + point;
  }

  String _pointsToTraditionalUnit(double totalPoints) {
    if (totalPoints <= 0) return "০ ভরি ০ আনা ০ রতি ০ পয়েন্ট";

    int pts = totalPoints.round();

    int vori = pts ~/ 960;
    int rem1 = pts % 960;

    int ana = rem1 ~/ 60;
    int rem2 = rem1 % 60;

    int roti = rem2 ~/ 10;
    double point = (rem2 % 10) + (totalPoints - totalPoints.floor());

    String voriStr = toBanglaDigit(vori.toString());
    String anaStr = toBanglaDigit(ana.toString());
    String rotiStr = toBanglaDigit(roti.toString());
    String pointStr = toBanglaDigit(point.toStringAsFixed(1).replaceAll('.0', ''));

    return "$voriStr ভরি $anaStr আনা $rotiStr রতি $pointStr পয়েন্ট";
  }

  void _calculate() {
    double inputPoints = _inputsToTotalPoints();

    if (inputPoints <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে সঠিক ওজন ইনপুট দিন')),
      );
      return;
    }

    setState(() {
      if (selectedCalculationType == 'ক্যারেট থেকে খাঁটি ও খাদ বের করা') {
        double pureGoldPoints = inputPoints * (targetCarat / 24.0);
        double alloyPoints = inputPoints - pureGoldPoints;

        resultTotalWeight = _pointsToTraditionalUnit(inputPoints);
        resultPureGold = _pointsToTraditionalUnit(pureGoldPoints);
        resultAlloy = _pointsToTraditionalUnit(alloyPoints);
        resultMessage = null;
      } else {
        if (targetCarat >= currentCarat && targetCarat != 24) {
          resultTotalWeight = null;
          resultPureGold = null;
          resultAlloy = null;
          resultMessage = "টার্গেট ক্যারেট অবশ্যই বর্তমান ক্যারেট থেকে কম হতে হবে (যেমন: ২১ ক্যারেট তৈরি করতে আপনার কাছে ২২ ক্যারেটের সোনা থাকতে হবে)।";
          return;
        }

        double pureGoldInInput = inputPoints * (currentCarat / 24.0);
        double requiredTotalPoints = pureGoldInInput / (targetCarat / 24.0);
        double alloyNeededPoints = requiredTotalPoints - inputPoints;

        resultMessage = "আপনার কাছে ${toBanglaDigit(currentCarat.toString())} ক্যারেটের ${_pointsToTraditionalUnit(inputPoints)} সোনা আছে।";
        resultAlloy = _pointsToTraditionalUnit(alloyNeededPoints);
        resultTotalWeight = _pointsToTraditionalUnit(requiredTotalPoints);
        resultPureGold = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ক্যারেট কনভার্টার', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF3B30),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("অপশন সিলেক্ট করুন", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.amber),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedCalculationType,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'ক্যারেট থেকে খাঁটি ও খাদ বের করা',
                                        child: Text('ক্যারেট থেকে খাঁটি ও খাদ বের করা', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                      DropdownMenuItem(
                                        value: 'খাদ দিয়ে ক্যারেট তৈরি করা',
                                        child: Text('খাদ দিয়ে ক্যারেট তৈরি করা', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          selectedCalculationType = val;
                                          resultTotalWeight = null;
                                          resultMessage = null;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("টার্গেট ক্যারেট", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.amber),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    value: targetCarat,
                                    items: const [
                                      DropdownMenuItem(value: 24, child: Text('২৪ ক্যারেট')),
                                      DropdownMenuItem(value: 22, child: Text('২২ ক্যারেট')),
                                      DropdownMenuItem(value: 21, child: Text('২১ ক্যারেট')),
                                      DropdownMenuItem(value: 18, child: Text('১৮ ক্যারেট')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          targetCarat = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (selectedCalculationType == 'খাদ দিয়ে ক্যারেট তৈরি করা') ...[
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("আপনার কাছে থাকা সোনার ক্যারেট", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.amber),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: currentCarat,
                                items: const [
                                  DropdownMenuItem(value: 22, child: Text('২২ ক্যারেট')),
                                  DropdownMenuItem(value: 21, child: Text('২১ ক্যারেট')),
                                  DropdownMenuItem(value: 18, child: Text('১৮ ক্যারেট')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      currentCarat = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("ওজন ইনপুট দিন:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInputField(_voriController, "ভরি"),
                const SizedBox(width: 6),
                _buildInputField(_anaController, "আনা"),
                const SizedBox(width: 6),
                _buildInputField(_rotiController, "রতি"),
                const SizedBox(width: 6),
                _buildInputField(_pointController, "পয়েন্ট"),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "হিসাব করুন",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            if (resultMessage != null || resultTotalWeight != null)
              Card(
                color: Colors.amber[50],
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ফলাফল:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
                      ),
                      const Divider(),
                      if (resultMessage != null) ...[
                        Text(resultMessage!, style: TextStyle(fontSize: 15, color: resultTotalWeight == null ? Colors.red : Colors.black, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                      ],
                      if (selectedCalculationType == 'ক্যারেট থেকে খাঁটি ও খাদ বের করা' && resultTotalWeight != null) ...[
                        Text("মোট ওজন: $resultTotalWeight", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Text("খাঁটি সোনা থাকবে: $resultPureGold", style: const TextStyle(fontSize: 15, color: Colors.green, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text("খাদ থাকবে: $resultAlloy", style: const TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                      if (selectedCalculationType == 'খাদ দিয়ে ক্যারেট তৈরি করা' && resultAlloy != null) ...[
                        Text("খাদ দিতে হবে: $resultAlloy", style: const TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text("মোট ওজন (সোনা + খাদ): $resultTotalWeight", style: const TextStyle(fontSize: 15, color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

// ========== ৭. ভরি ও পয়েন্ট কনভার্টার স্ক্রিন ==========
class VoriPointConverterScreen extends StatefulWidget {
  const VoriPointConverterScreen({super.key});

  @override
  State<VoriPointConverterScreen> createState() => _VoriPointConverterScreenState();
}

class _VoriPointConverterScreenState extends State<VoriPointConverterScreen> {
  String _selectedMode = 'VoriToPoint';

  final TextEditingController _voriController = TextEditingController();
  final TextEditingController _anaController = TextEditingController();
  final TextEditingController _rotiController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();

  final TextEditingController _singlePointController = TextEditingController();

  String _resultText = '';

  void _calculate() {
    FocusScope.of(context).unfocus();

    if (_selectedMode == 'VoriToPoint') {
      double vori = double.tryParse(_voriController.text) ?? 0;
      double ana = double.tryParse(_anaController.text) ?? 0;
      double roti = double.tryParse(_rotiController.text) ?? 0;
      double point = double.tryParse(_pointController.text) ?? 0;

      double totalPoints = (vori * 960) + (ana * 60) + (roti * 10) + point;

      setState(() {
        _resultText = 'মোট পয়েন্ট: ${toBanglaDigit(totalPoints.toStringAsFixed(2))} পয়েন্ট';
      });
    } else {
      double totalPoints = double.tryParse(_singlePointController.text) ?? 0;

      if (totalPoints <= 0) {
        setState(() {
          _resultText = 'দয়া করে সঠিক পয়েন্ট ইনপুট দিন';
        });
        return;
      }

      int vori = (totalPoints / 960).floor();
      double remainingAfterVori = totalPoints % 960;

      int ana = (remainingAfterVori / 60).floor();
      double remainingAfterAna = remainingAfterVori % 60;

      int roti = (remainingAfterAna / 10).floor();
      double point = remainingAfterAna % 10;

      String formattedResult =
          '${toBanglaDigit(vori.toString())} ভরি, ${toBanglaDigit(ana.toString())} আনা, ${toBanglaDigit(roti.toString())} রতি, ${toBanglaDigit(point.toStringAsFixed(2))} পয়েন্ট';

      setState(() {
        _resultText = 'ফলাফল:\n$formattedResult';
      });
    }
  }

  @override
  void dispose() {
    _voriController.dispose();
    _anaController.dispose();
    _rotiController.dispose();
    _pointController.dispose();
    _singlePointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ভরি ও পয়েন্ট কনভার্টার', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF3B30),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'কনভার্শন মোড',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedMode,
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'VoriToPoint',
                              child: Text('ভরি থেকে পয়েন্ট'),
                            ),
                            DropdownMenuItem(
                              value: 'PointToVori',
                              child: Text('পয়েন্ট থেকে ভরি'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedMode = value;
                                _resultText = '';
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_selectedMode == 'VoriToPoint') ...[
                      const Text(
                        'ওজন অনুযায়ী ইনপুট দিন:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildInputField(_voriController, 'ভরি')),
                          const SizedBox(width: 8),
                          Expanded(child: _buildInputField(_anaController, 'আনা')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildInputField(_rotiController, 'রতি')),
                          const SizedBox(width: 8),
                          Expanded(child: _buildInputField(_pointController, 'পয়েন্ট')),
                        ],
                      ),
                    ] else ...[
                      const Text(
                        'পয়েন্ট ইনপুট করেন',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildInputField(_singlePointController, 'পয়েন্ট লিখুন'),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                        onPressed: _calculate,
                        child: const Text(
                          'কনভার্ট করুন',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (_resultText.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          border: Border.all(color: Colors.amber.shade400, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _resultText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

// ========== ৮. পাকা পরতা ক্যালকুলেটর স্ক্রিন ==========
class GoldCalculatorScreen extends StatefulWidget {
  const GoldCalculatorScreen({super.key});

  @override
  State<GoldCalculatorScreen> createState() => _GoldCalculatorScreenState();
}

class _GoldCalculatorScreenState extends State<GoldCalculatorScreen> {
  final TextEditingController _rate24Controller = TextEditingController(text: '200000');
  final TextEditingController _targetKaratController = TextEditingController(text: '22');
  
  final TextEditingController _voriController = TextEditingController();
  final TextEditingController _anaController = TextEditingController();
  final TextEditingController _rotiController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();

  double _perVoriPrice = 0.0;
  double _totalPrice = 0.0;
  double _calculatedKarat = 0.0;
  bool _hasCalculated = false;

  void _calculatePrice() {
    FocusScope.of(context).unfocus();

    final double rate24 = double.tryParse(_rate24Controller.text) ?? 0.0;
    final double targetKarat = double.tryParse(_targetKaratController.text) ?? 0.0;

    final double vori = double.tryParse(_voriController.text) ?? 0.0;
    final double ana = double.tryParse(_anaController.text) ?? 0.0;
    final double roti = double.tryParse(_rotiController.text) ?? 0.0;
    final double point = double.tryParse(_pointController.text) ?? 0.0;

    if (rate24 <= 0 || targetKarat <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে সঠিক ২৪ ক্যারেটের দাম ও টার্গেট ক্যারেট দিন')),
      );
      return;
    }

    // ১. টার্গেট ক্যারেটের প্রতি ভরির দাম নির্ধারণ
    double calculatedRatePerVori = 0.0;

    if (targetKarat == 22) {
      calculatedRatePerVori = rate24 * (1 - 0.08333333);
    } else if (targetKarat == 21) {
      calculatedRatePerVori = rate24 * (1 - 0.125);
    } else if (targetKarat == 18) {
      calculatedRatePerVori = rate24 * (1 - 0.25);
    } else {
      calculatedRatePerVori = rate24 * (targetKarat / 24);
    }

    // ২. মোট ওজন ভরিতে রূপান্তর (১ ভরি = ১৬ আনা, ১ আনা = ৬ রতি, ১ রতি = ১০ পয়েন্ট)
    final double totalVori = vori + (ana / 16) + (roti / 96) + (point / 960);

    // ৩. মোট দাম
    final double calculatedTotalPrice = totalVori * calculatedRatePerVori;

    setState(() {
      _perVoriPrice = calculatedRatePerVori;
      _totalPrice = calculatedTotalPrice;
      _calculatedKarat = targetKarat;
      _hasCalculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('পাকা পরতা ক্যালকুলেটর', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF3B30),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'রেট কনফিগারেশন',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 12),

                    const Text(
                      '২৪ ক্যা: সোনার দাম (১ ভরি)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _rate24Controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'সোনার দাম লিখুন',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'টার্গেট ক্যারেট (যেমন: ২২, ২১, ১৮)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _targetKaratController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'টার্গেট ক্যারেট লিখুন',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'সোনার ওজন ইনপুট দিন',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildWeightField(_voriController, 'ভরি'),
                const SizedBox(width: 6),
                _buildWeightField(_anaController, 'আনা'),
                const SizedBox(width: 6),
                _buildWeightField(_rotiController, 'রতি'),
                const SizedBox(width: 6),
                _buildWeightField(_pointController, 'পয়েন্ট'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                onPressed: _calculatePrice,
                child: const Text(
                  'হিসাব করুন',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_hasCalculated)
              Card(
                elevation: 3,
                color: Colors.amber.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ফলাফল (${toBanglaDigit(_calculatedKarat.toStringAsFixed(0))} ক্যারেট):',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
                      ),
                      const Divider(thickness: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('প্রতি ভরির রেট:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          Text(
                            '৳ ${formatNumberWithCommas(_perVoriPrice, isCurrency: true)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('মোট আনুমানিক মূল্য:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            '৳ ${formatNumberWithCommas(_totalPrice, isCurrency: true)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
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

  Widget _buildWeightField(TextEditingController controller, String label) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
