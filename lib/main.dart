import 'package:flutter/material.dart';

void main() {
  runApp(const GoldConverterApp());
}

class GoldConverterApp extends StatelessWidget {
  const GoldConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'গোল্ড কনভার্টার',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFFA5D6A7), // হালকা সবুজ ব্যাকগ্রাউন্ড
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ০ = প্রধান মেনু, ১ = ভরি ও পয়েন্ট কনভার্টার
  int _selectedOption = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedOption == 0 ? 'হোম পেজ' : 'ভরি ও পয়েন্ট কনভার্টার',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
        elevation: 2,
      ),
      body: _selectedOption == 0
          ? _buildMainMenu()
          : _buildVoriPointConverter(),
    );
  }

  // প্রধান মেনু পেজ
  Widget _buildMainMenu() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildMenuCard(
            title: 'ভরি ও পয়েন্ট কনভার্টার',
            icon: Icons.sync_alt,
            onTap: () {
              setState(() {
                _selectedOption = 1;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.amber,
          child: Icon(icon, color: Colors.black),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }

  // ভরি ও পয়েন্ট কনভার্টার স্ক্রিন
  Widget _buildVoriPointConverter() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  _selectedOption = 0;
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text(
                'প্রধান মেনুতে ফিরে যান',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            const ConverterWidget(),
          ],
        ),
      ),
    );
  }
}

class ConverterWidget extends StatefulWidget {
  const ConverterWidget({super.key});

  @override
  State<ConverterWidget> createState() => _ConverterWidgetState();
}

class _ConverterWidgetState extends State<ConverterWidget> {
  // ড্রপডাউনের জন্য ভ্যারিয়েবল (ডিফল্ট: 'VoriToPoint')
  String _selectedMode = 'VoriToPoint';

  // অপশন ১-এর জন্য টেক্সট কন্ট্রোলার (৪টি বক্স)
  final TextEditingController _voriController = TextEditingController();
  final TextEditingController _anaController = TextEditingController();
  final TextEditingController _rotiController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();

  // অপশন ২-এর জন্য টেক্সট কন্ট্রোলার (১টি বক্স)
  final TextEditingController _singlePointController = TextEditingController();

  // ফলাফল টেক্সট
  String _resultText = '';

  // কনভার্ট হিসেব করার লজিক
  void _calculate() {
    FocusScope.of(context).unfocus(); // হিসাবের সময় কীবোর্ড হাইড করার জন্য

    if (_selectedMode == 'VoriToPoint') {
      double vori = double.tryParse(_voriController.text) ?? 0;
      double ana = double.tryParse(_anaController.text) ?? 0;
      double roti = double.tryParse(_rotiController.text) ?? 0;
      double point = double.tryParse(_pointController.text) ?? 0;

      // ১ ভরি = ৯৬০ পয়েন্ট
      // ১ আনা = ৬০ পয়েন্ট
      // ১ রতি = ১০ পয়েন্ট
      double totalPoints = (vori * 960) + (ana * 60) + (roti * 10) + point;

      setState(() {
        _resultText = 'মোট পয়েন্ট: ${totalPoints.toStringAsFixed(2)} পয়েন্ট';
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

      setState(() {
        _resultText =
            'ফলাফল:\n$vori ভরি, $ana আনা, $roti রতি, ${point.toStringAsFixed(2)} পয়েন্ট';
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
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ১. হেডলাইন
            const Text(
              'কনভারশন মোড',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // ২. ড্রপ ডাউন মেনু
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
                        _resultText = ''; // অপশন পরিবর্তন করলে ফলাফল ক্লিয়ার হবে
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ৩. অপশন অনুযায়ী ইনপুট বক্স ফিল্ড
            if (_selectedMode == 'VoriToPoint') ...[
              const Text(
                'ওজন অনুযায়ী ইনপুট দিন:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(_voriController, 'ভরি'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInputField(_anaController, 'আনা'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(_rotiController, 'রতি'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInputField(_pointController, 'পয়েন্ট'),
                  ),
                ],
              ),
            ] else ...[
              // অপশন ২: পয়েন্ট থেকে ভরি
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

            // ৪. হলুদ রঙের বড় বাটন (কালো বোল্ড টেক্সট)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700), // উজ্জ্বল হলুদ রং
                  foregroundColor: Colors.black, // কালো বোল্ড ফন্ট
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

            // ৫. ফলাফলের সেকশন
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
    );
  }

  // ইনপুট ফিল্ড তৈরির হেলপার মেথড
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
