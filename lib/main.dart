import 'package:flutter/material.dart';

void main() {
  runApp(const JewelleryApp());
}

class JewelleryApp extends StatelessWidget {
  const JewelleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'জুয়েলারি হিসাব ও খতিয়ান',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          elevation: 2,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ==========================================
// ১. হোম স্ক্রিন (মেনু)
// ==========================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('জুয়েলারি ম্যানেজমেন্ট', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(
              context,
              title: 'ভরি / আনা / রতি ক্যালকুলেটর',
              icon: Icons.calculate,
              color: Colors.amber.shade900,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GoldCalculatorScreen()),
                );
              },
            ),
            _buildMenuCard(
              context,
              title: 'কারিগর খতিয়ান',
              icon: Icons.assignment_outlined,
              color: Colors.teal.shade800,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KarigorKhotiyanScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 35, color: color),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ২. সোনা ক্যালকুলেটর
// ==========================================
class GoldCalculatorScreen extends StatefulWidget {
  const GoldCalculatorScreen({super.key});

  @override
  State<GoldCalculatorScreen> createState() => _GoldCalculatorScreenState();
}

class _GoldCalculatorScreenState extends State<GoldCalculatorScreen> {
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _voriController = TextEditingController();
  final TextEditingController _anaController = TextEditingController();
  final TextEditingController _rotiController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();

  double _totalPrice = 0.0;
  double _totalGram = 0.0;

  void _calculate() {
    double rate = double.tryParse(_rateController.text) ?? 0;
    double vori = double.tryParse(_voriController.text) ?? 0;
    double ana = double.tryParse(_anaController.text) ?? 0;
    double roti = double.tryParse(_rotiController.text) ?? 0;
    double point = double.tryParse(_pointController.text) ?? 0;

    // ১ ভরি = ৯৬০ পয়েন্ট, ১ আনা = ৬০ পয়েন্ট, ১ রতি = ১০ পয়েন্ট
    double totalPoints = (vori * 960) + (ana * 60) + (roti * 10) + point;
    double totalGram = totalPoints * (11.664 / 960);
    double totalPrice = (totalPoints / 960) * rate;

    setState(() {
      _totalGram = totalGram;
      _totalPrice = totalPrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('সোনা ক্যালকুলেটর')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("প্রতি ভরি সোনার দাম (টাকা):", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _rateController,
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculate(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'যেমন: ১২০০০০',
              ),
            ),
            const SizedBox(height: 20),
            const Text("সোনার পরিমাপ:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildInputBox("ভরি", _voriController)),
                const SizedBox(width: 8),
                Expanded(child: _buildInputBox("আনা", _anaController)),
                const SizedBox(width: 8),
                Expanded(child: _buildInputBox("রতি", _rotiController)),
                const SizedBox(width: 8),
                Expanded(child: _buildInputBox("পয়েন্ট", _pointController)),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade700),
              ),
              child: Column(
                children: [
                  Text("মোট গ্রাম: ${_totalGram.toStringAsFixed(3)} গ্রাম", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("মোট দাম: ${_totalPrice.toStringAsFixed(2)} টাকা", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => _calculate(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
    );
  }
}

// ==========================================
// ৩. কারিগর খতিয়ান স্ক্রিন
// ==========================================
class KarigorKhotiyanScreen extends StatefulWidget {
  const KarigorKhotiyanScreen({super.key});

  @override
  State<KarigorKhotiyanScreen> createState() => _KarigorKhotiyanScreenState();
}

class _KarigorKhotiyanScreenState extends State<KarigorKhotiyanScreen> {
  // ১. কারিগর কে প্রদান
  final TextEditingController _prodanVori = TextEditingController();
  final TextEditingController _prodanAna = TextEditingController();
  final TextEditingController _prodanRoti = TextEditingController();
  final TextEditingController _prodanPoint = TextEditingController();

  // ২. কারিগর থেকে বুজ -> গহনার ওজন
  final TextEditingController _gohonaVori = TextEditingController();
  final TextEditingController _gohonaAna = TextEditingController();
  final TextEditingController _gohonaRoti = TextEditingController();
  final TextEditingController _gohonaPoint = TextEditingController();

  // ৩. কারিগর থেকে বুজ -> বাকি সোনার ওজন
  final TextEditingController _bakiVori = TextEditingController();
  final TextEditingController _bakiAna = TextEditingController();
  final TextEditingController _bakiRoti = TextEditingController();
  final TextEditingController _bakiPoint = TextEditingController();

  // ৪. কারিগরের হাত লস প্রতি ভরি (১ ভরি = ১ আনা ২ রতি = ৮০ পয়েন্ট)
  final TextEditingController _rateVori = TextEditingController(text: '0');
  final TextEditingController _rateAna = TextEditingController(text: '1');
  final TextEditingController _rateRoti = TextEditingController(text: '2');
  final TextEditingController _ratePoint = TextEditingController(text: '0');

  // ৫. অন্যান্য
  final TextEditingController _onnannoVori = TextEditingController();
  final TextEditingController _onnannoAna = TextEditingController();
  final TextEditingController _onnannoRoti = TextEditingController();
  final TextEditingController _onnannoPoint = TextEditingController();

  // স্বয়ংক্রিয় আউটপুট ফিল্ডসমূহ
  final TextEditingController _calculatedHatLossVori = TextEditingController();
  final TextEditingController _calculatedHatLossAna = TextEditingController();
  final TextEditingController _calculatedHatLossRoti = TextEditingController();
  final TextEditingController _calculatedHatLossPoint = TextEditingController();

  final TextEditingController _totalPraptiVori = TextEditingController();
  final TextEditingController _totalPraptiAna = TextEditingController();
  final TextEditingController _totalPraptiRoti = TextEditingController();
  final TextEditingController _totalPraptiPoint = TextEditingController();

  String _resultText = '';
  Color _resultColor = Colors.black;

  void _clearAll() {
    setState(() {
      _prodanVori.clear(); _prodanAna.clear(); _prodanRoti.clear(); _prodanPoint.clear();
      _gohonaVori.clear(); _gohonaAna.clear(); _gohonaRoti.clear(); _gohonaPoint.clear();
      _bakiVori.clear(); _bakiAna.clear(); _bakiRoti.clear(); _bakiPoint.clear();
      _rateVori.text = '0'; _rateAna.text = '1'; _rateRoti.text = '2'; _ratePoint.text = '0';
      _onnannoVori.clear(); _onnannoAna.clear(); _onnannoRoti.clear(); _onnannoPoint.clear();
      _calculatedHatLossVori.clear(); _calculatedHatLossAna.clear(); _calculatedHatLossRoti.clear(); _calculatedHatLossPoint.clear();
      _totalPraptiVori.clear(); _totalPraptiAna.clear(); _totalPraptiRoti.clear(); _totalPraptiPoint.clear();
      _resultText = '';
    });
  }

  // ১ রতি = ১০ পয়েন্ট, ১ আনা = ৬০ পয়েন্ট, ১ ভরি = ৯৬০ পয়েন্ট
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
      'point': double.parse(point.toStringAsFixed(2)),
    };
  }

  void _calculate() {
    setState(() {
      double prodanPoints = _convertToPoints(_prodanVori.text, _prodanAna.text, _prodanRoti.text, _prodanPoint.text);
      double gohonaPoints = _convertToPoints(_gohonaVori.text, _gohonaAna.text, _gohonaRoti.text, _gohonaPoint.text);
      double bakiPoints = _convertToPoints(_bakiVori.text, _bakiAna.text, _bakiRoti.text, _bakiPoint.text);
      double lossRatePoints = _convertToPoints(_rateVori.text, _rateAna.text, _rateRoti.text, _ratePoint.text);
      double onnannoPoints = _convertToPoints(_onnannoVori.text, _onnannoAna.text, _onnannoRoti.text, _onnannoPoint.text);

      // ঐকিক নিয়মে হাত লস হিসাব = (গহনার পয়েন্ট * প্রতি ভরি লসের পয়েন্ট) / ৯৬০
      double calculatedLossPoints = (gohonaPoints * lossRatePoints) / 960.0;
      var lossFormatted = _convertFromPoints(calculatedLossPoints);

      _calculatedHatLossVori.text = lossFormatted['vori']!.toInt().toString();
      _calculatedHatLossAna.text = lossFormatted['ana']!.toInt().toString();
      _calculatedHatLossRoti.text = lossFormatted['roti']!.toInt().toString();
      _calculatedHatLossPoint.text = lossFormatted['point']!.toString();

      // কারিগর থেকে মোট প্রাপ্তি = গহনার ওজন + বাকি সোনার ওজন + হিসাবকৃত হাত লস + অন্যান্য
      double totalPraptiPoints = gohonaPoints + bakiPoints + calculatedLossPoints + onnannoPoints;
      var totalPraptiFormatted = _convertFromPoints(totalPraptiPoints);

      _totalPraptiVori.text = totalPraptiFormatted['vori']!.toInt().toString();
      _totalPraptiAna.text = totalPraptiFormatted['ana']!.toInt().toString();
      _totalPraptiRoti.text = totalPraptiFormatted['roti']!.toInt().toString();
      _totalPraptiPoint.text = totalPraptiFormatted['point']!.toString();

      // পার্থক্য = প্রদান - মোট প্রাপ্তি
      double diffPoints = prodanPoints - totalPraptiPoints;
      var diffFormatted = _convertFromPoints(diffPoints);

      String resStr = "${diffFormatted['vori']!.toInt()} ভরি, ${diffFormatted['ana']!.toInt()} আনা, ${diffFormatted['roti']!.toInt()} রতি, ${diffFormatted['point']} পয়েন্ট";

      if (diffPoints.abs() < 0.01) {
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
        title: const Text('কারিগর খতিয়ান'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'রিসেট করুন',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('রিসেট করবেন?'),
                  content: const Text('সকল ইনপুট ডাটা মুছে যাবে।'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('না')),
                    TextButton(
                      onPressed: () {
                        _clearAll();
                        Navigator.pop(context);
                      },
                      child: const Text('হ্যাঁ'),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ১. কারিগর কে প্রদান
            _buildSectionHeader("কারিগর কে প্রদান", Colors.amber.shade900),
            _buildVoriAnaRotiRow(
              v: _prodanVori, a: _prodanAna, r: _prodanRoti, p: _prodanPoint,
              onChanged: (_) => _calculate(),
            ),
            const Divider(height: 30, thickness: 1.5),

            // ২. কারিগর থেকে বুজ
            _buildSectionHeader("কারিগর থেকে বুজ", Colors.teal.shade900),
            
            const Text("• গহনার ওজন", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            _buildVoriAnaRotiRow(
              v: _gohonaVori, a: _gohonaAna, r: _gohonaRoti, p: _gohonaPoint,
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 10),

            const Text("• বাকি সোনার ওজন", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            _buildVoriAnaRotiRow(
              v: _bakiVori, a: _bakiAna, r: _bakiRoti, p: _bakiPoint,
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 10),

            const Text("• কারিগরের হাত লস (প্রতি ভরি)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            _buildVoriAnaRotiRow(
              v: _rateVori, a: _rateAna, r: _rateRoti, p: _ratePoint,
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 10),

            const Text("• হিসাবকৃত হাত লস (ঐকিক নিয়মে স্বয়ংক্রিয়)", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
            _buildVoriAnaRotiRow(
              v: _calculatedHatLossVori, a: _calculatedHatLossAna, r: _calculatedHatLossRoti, p: _calculatedHatLossPoint,
              readOnly: true,
            ),
            const SizedBox(height: 10),

            const Text("• অন্যান্য", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            _buildVoriAnaRotiRow(
              v: _onnannoVori, a: _onnannoAna, r: _onnannoRoti, p: _onnannoPoint,
              onChanged: (_) => _calculate(),
            ),
            const Divider(height: 30, thickness: 1.5),

            // ৩. কারিগর থেকে মোট প্রাপ্তি
            _buildSectionHeader("কারিগর থেকে মোট প্রাপ্তি", Colors.blue.shade900),
            _buildVoriAnaRotiRow(
              v: _totalPraptiVori, a: _totalPraptiAna, r: _totalPraptiRoti, p: _totalPraptiPoint,
              readOnly: true,
            ),
            const SizedBox(height: 25),

            // ৪. ফলাফল বক্স
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _resultColor.withOpacity(0.1),
                border: Border.all(color: _resultColor, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text("চূড়ান্ত ফলাফল (প্রদান - মোট প্রাপ্তি)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    _resultText.isEmpty ? "উপরে তথ্য ইনপুট দিন" : _resultText,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _resultColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildVoriAnaRotiRow({
    required TextEditingController v,
    required TextEditingController a,
    required TextEditingController r,
    required TextEditingController p,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return Row(
      children: [
        Expanded(child: _buildInputBox("ভরি", v, readOnly, onChanged)),
        const SizedBox(width: 8),
        Expanded(child: _buildInputBox("আনা", a, readOnly, onChanged)),
        const SizedBox(width: 8),
        Expanded(child: _buildInputBox("রতি", r, readOnly, onChanged)),
        const SizedBox(width: 8),
        Expanded(child: _buildInputBox("পয়েন্ট", p, readOnly, onChanged)),
      ],
    );
  }

  Widget _buildInputBox(String label, TextEditingController controller, bool readOnly, Function(String)? onChanged) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
    );
  }
}
