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
        useMaterial3: true,
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
  final _voriController = TextEditingController();
  final _anaController = TextEditingController();
  final _ratiController = TextEditingController();
  final _pointController = TextEditingController();
  final _pricePerVoriController = TextEditingController();
  final _makingChargeController = TextEditingController();

  double _totalPrice = 0.0;

  void _calculateTotal() {
    double vori = double.tryParse(_voriController.text) ?? 0.0;
    double ana = double.tryParse(_anaController.text) ?? 0.0;
    double rati = double.tryParse(_ratiController.text) ?? 0.0;
    double point = double.tryParse(_pointController.text) ?? 0.0;
    double pricePerVori = double.tryParse(_pricePerVoriController.text) ?? 0.0;
    double makingCharge = double.tryParse(_makingChargeController.text) ?? 0.0;

    // Convert everything to total Vori equivalent
    // 1 Vori = 16 Ana, 1 Ana = 6 Rati, 1 Rati = 10 Points
    double totalVoriEquivalent = vori + (ana / 16.0) + (rati / 96.0) + (point / 960.0);

    double goldPrice = totalVoriEquivalent * pricePerVori;
    
    setState(() {
      _totalPrice = goldPrice + makingCharge;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('পরমা জুয়েলার্স ক্যালকুলেটর'),
        backgroundColor: Colors.amber[700],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'সোনার পরিমাণ লিখুন:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildInputField(_voriController, 'ভরি')),
                const SizedBox(width: 8),
                Expanded(child: _buildInputField(_anaController, 'আনা')),
                const SizedBox(width: 8),
                Expanded(child: _buildInputField(_ratiController, 'রতি')),
                const SizedBox(width: 8),
                Expanded(child: _buildInputField(_pointController, 'পয়েন্ট')),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'মূল্য ও মজুরি:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInputField(_pricePerVoriController, 'প্রতি ভরি সোনার দাম (টাকা)'),
            const SizedBox(height: 10),
            _buildInputField(_makingChargeController, 'মজুরি / মেকিং চার্জ (টাকা)'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateTotal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'মোট হিসাব করুন',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            const SizedBox(height: 30),
            Card(
              color: Colors.amber[50],
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'সর্বমোট মূল্য',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '৳ ${_totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[900],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
