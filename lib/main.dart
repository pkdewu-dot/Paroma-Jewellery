import 'package:flutter/material.dart';

void main() {
  runApp(const PoromaJewellersApp());
}

class PoromaJewellersApp extends StatelessWidget {
  const PoromaJewellersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'পরমা জুয়েলার্স',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFFFFFBF0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD4AF37),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  final List<Map<String, String>> _historyList = [];

  void addHistory(String title, String details) {
    setState(() {
      _historyList.insert(0, {
        'title': title,
        'details': details,
        'date': DateTime.now().toString().substring(0, 16),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      AIPredictionTab(historyList: _historyList),
      FineGoldTab(onSave: addHistory),
      InterestTab(onSave: addHistory),
      JewelryMathTab(onSave: addHistory),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('পরমা জুয়েলার্স', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('Made by Pk', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: const Color(0xFFB8860B),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'AI পূর্বাভাস'),
              BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'পাকা সোনা'),
              BottomNavigationBarItem(icon: Icon(Icons.percent), label: 'সুদ হিসাব'),
              BottomNavigationBarItem(icon: Icon(Icons.exposure), label: 'যোগ-বিয়োগ'),
            ],
          ),
          Container(
            color: const Color(0xFFD4AF37),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: const Text(
              'পরমা জুয়েলার্স • Made by Pk',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}

class AIPredictionTab extends StatelessWidget {
  final List<Map<String, String>> historyList;
  const AIPredictionTab({super.key, required: this.historyList});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          color: const Color(0xFFFFF8DC),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: const Padding(
            padding: EdgeInsets.all(12),
            children: [
              Text('📈 আজকের বাজার ও AI পূর্বাভাস (goldr.org)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF8B6508))),
              SizedBox(height: 6),
              Text('• আন্তর্জাতিক ও স্থানীয় বাজারের পূর্বাভাস অনুযায়ী আজ সোনার দাম স্থিতিশীল থাকার সম্ভাবনা রয়েছে।'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text('সংরক্ষিত হিসাবসমূহ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        historyList.isEmpty
            ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('এখনো কোনো হিসাব সেভ করা হয়নি।')))
            : Column(
                children: historyList.map((item) => Card(
                  child: ListTile(
                    title: Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['details'] ?? ''),
                    trailing: Text(item['date'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ),
                )).toList(),
              ),
      ],
    );
  }
}

class FineGoldTab extends StatefulWidget {
  final Function(String, String) onSave;
  const FineGoldTab({super.key, required: this.onSave});

  @override
  State<FineGoldTab> createState() => _FineGoldTabState();
}

class _FineGoldTabState extends State<FineGoldTab> {
  String _karat = '22';
  final _v = TextEditingController();
  final _a = TextEditingController();
  final _r = TextEditingController();
  final _p = TextEditingController();
  final _rate = TextEditingController();
  String _result = '';

  void _calculate() {
    double v = double.tryParse(_v.text) ?? 0;
    double a = double.tryParse(_a.text) ?? 0;
    double r = double.tryParse(_r.text) ?? 0;
    double p = double.tryParse(_p.text) ?? 0;
    double rate = double.tryParse(_rate.text) ?? 0;

    double totalVori = v + (a / 16) + (r / 96) + (p / 960);
    double wastageRate = _karat == '22' ? 0.09 : (_karat == '21' ? 0.13 : 0.26);
    double fineVori = totalVori * (1 - wastageRate);
    double fineGram = fineVori * 11.664;
    double totalPrice = totalVori * rate;

    setState(() {
      _result = 'মোট ওজন: ${totalVori.toStringAsFixed(3)} ভরি\nপাকা সোনা: ${fineVori.toStringAsFixed(3)} ভরি (${fineGram.toStringAsFixed(2)} গ্রাম)\nমোট দাম: ৳${totalPrice.toStringAsFixed(2)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: ['22', '21', '18'].map((k) => Expanded(
            child: RadioListTile(
              title: Text('$k K'),
              value: k,
              groupValue: _karat,
              onChanged: (val) => setState(() => _karat = val.toString()),
            ),
          )).toList(),
        ),
        Row(children: [_box(_v, 'ভরি'), _box(_a, 'আনা'), _box(_r, 'রতি'), _box(_p, 'পয়েন্ট')]),
        const SizedBox(height: 10),
        TextField(controller: _rate, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'প্রতি ভরি পাকা সোনার দাম (৳)', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
          onPressed: () {
            _calculate();
            if (_result.isNotEmpty) widget.onSave('পাকা সোনা ($_karat K)', _result);
          },
          child: const Text('হিসাব করুন ও সেভ করুন', style: TextStyle(color: Colors.white)),
        ),
        if (_result.isNotEmpty) _resultCard([_result]),
      ],
    );
  }
}

class InterestTab extends StatefulWidget {
  final Function(String, String) onSave;
  const InterestTab({super.key, required: this.onSave});

  @override
  State<InterestTab> createState() => _InterestTabState();
}

class _InterestTabState extends State<InterestTab> {
  DateTime? _startDate;
  final _amount = TextEditingController();
  final _rate = TextEditingController();
  String _result = '';

  void _calculate() {
    if (_startDate == null) return;
    double amount = double.tryParse(_amount.text) ?? 0;
    double rate = double.tryParse(_rate.text) ?? 0;

    DateTime now = DateTime.now();
    int days = now.difference(_startDate!).inDays;
    int months = days ~/ 30;
    int remDays = days % 30;

    double effectiveMonths = months.toDouble();
    if (remDays >= 1 && remDays <= 15) effectiveMonths += 0.5;
    if (remDays >= 16) effectiveMonths += 1.0;

    double interest = (amount * rate / 100) * effectiveMonths;
    double total = amount + interest;

    setState(() {
      _result = 'সময়কাল: $months মাস $remDays দিন (কার্যকর মাস: $effectiveMonths)\nমোট সুদ: ৳${interest.toStringAsFixed(2)}\nসুদসহ মোট: ৳${total.toStringAsFixed(2)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ListTile(
          title: Text(_startDate == null ? 'শুরুর তারিখ নির্বাচন করুন' : 'তারিখ: ${_startDate.toString().substring(0, 10)}'),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            DateTime? d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
            if (d != null) setState(() => _startDate = d);
          },
        ),
        TextField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'মূল টাকা (৳)', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: _rate, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'মাসিক সুদের হার (%)', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
          onPressed: () {
            _calculate();
            if (_result.isNotEmpty) widget.onSave('সুদ হিসাব', _result);
          },
          child: const Text('হিসাব করুন ও সেভ করুন', style: TextStyle(color: Colors.white)),
        ),
        if (_result.isNotEmpty) _resultCard([_result]),
      ],
    );
  }
}

class JewelryMathTab extends StatefulWidget {
  final Function(String, String) onSave;
  const JewelryMathTab({super.key, required: this.onSave});

  @override
  State<JewelryMathTab> createState() => _JewelryMathTabState();
}

class _JewelryMathTabState extends State<JewelryMathTab> {
  final _v1 = TextEditingController(), _a1 = TextEditingController(), _r1 = TextEditingController(), _p1 = TextEditingController();
  final _v2 = TextEditingController(), _a2 = TextEditingController(), _r2 = TextEditingController(), _p2 = TextEditingController();
  String _sum = '', _diff = '';

  void _calculate() {
    double pts1 = (double.tryParse(_v1.text) ?? 0) * 960 + (double.tryParse(_a1.text) ?? 0) * 60 + (double.tryParse(_r1.text) ?? 0) * 10 + (double.tryParse(_p1.text) ?? 0);
    double pts2 = (double.tryParse(_v2.text) ?? 0) * 960 + (double.tryParse(_a2.text) ?? 0) * 60 + (double.tryParse(_r2.text) ?? 0) * 10 + (double.tryParse(_p2.text) ?? 0);

    _sum = _formatPts(pts1 + pts2);
    _diff = _formatPts((pts1 - pts2).abs());
    setState(() {});
  }

  String _formatPts(double totalPts) {
    int v = totalPts ~/ 960;
    double rem1 = totalPts % 960;
    int a = rem1 ~/ 60;
    double rem2 = rem1 % 60;
    int r = rem2 ~/ 10;
    double p = rem2 % 10;
    return '$v ভরি $a আনা $r রতি ${p.toStringAsFixed(1)} পয়েন্ট';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('গহনা ১:', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [_box(_v1, 'ভরি'), _box(_a1, 'আনা'), _box(_r1, 'রতি'), _box(_p1, 'পয়েন্ট')]),
        const SizedBox(height: 10),
        const Text('গহনা ২:', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [_box(_v2, 'ভরি'), _box(_a2, 'আনা'), _box(_r2, 'রতি'), _box(_p2, 'পয়েন্ট')]),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
          onPressed: () {
            _calculate();
            if (_sum.isNotEmpty) widget.onSave('গহনা হিসাব', 'যোগফল: $_sum\nবিয়োগফল: $_diff');
          },
          child: const Text('যোগ ও বিয়োগ করুন', style: TextStyle(color: Colors.white)),
        ),
        if (_sum.isNotEmpty) _resultCard(['যোগফল: $_sum', 'বিয়োগফল: $_diff']),
      ],
    );
  }
}

Widget _box(TextEditingController c, String l) => Expanded(
  child: Padding(
    padding: const EdgeInsets.all(2),
    child: TextField(controller: c, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l, border: const OutlineInputBorder())),
  ),
);

Widget _resultCard(List<String> lines) => Card(
  color: const Color(0xFFFFF8DC),
  margin: const EdgeInsets.only(top: 10),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((l) => Text(l, style: const TextStyle(fontWeight: FontWeight.bold))).toList(),
    ),
  ),
);
