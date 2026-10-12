import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GoldMarketDashboard extends StatefulWidget {
  const GoldMarketDashboard({Key? key}) : super(key: key);

  @override
  State<GoldMarketDashboard> createState() => _GoldMarketDashboardState();
}

class _GoldMarketDashboardState extends State<GoldMarketDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3B30),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('স্বর্ণের মূল্য ক্যালকুলেটর', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'ক্যালকুলেটর'),
            Tab(text: 'পাকা বিল'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CalculatorView(),
          Center(child: Text('পাকা বিল সেকশন খুব শীঘ্রই আসছে', style: TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}

class CalculatorView extends StatefulWidget {
  const CalculatorView({Key? key}) : super(key: key);

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  final String apiKey = "01578e7e7dfa3bb8617e40afc0a3848f";
  
  String selectedMetal = 'Gold'; 
  String selectedKarat = '22K';   
  String selectedMuzoriType = 'Percent'; 
  
  double liveMarketPricePerVori = 0.0;
  
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _muzoriValueController = TextEditingController(text: "6");
  
  final TextEditingController _voriController = TextEditingController();
  final TextEditingController _anaController = TextEditingController();
  final TextEditingController _rotiController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();

  double totalMetalPrice = 0.0;
  double totalMuzori = 0.0;
  double grandTotal = 0.0;
  bool showResult = false;

  @override
  void initState() {
    super.initState();
    fetchLivePrice();
  }

  Future<void> fetchLivePrice() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.goldapi.io/api/XAU/BDT'),
        headers: {'x-access-token': apiKey},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double gramPrice = (data['price'] as num).toDouble() / 31.1035;
        setState(() {
          liveMarketPricePerVori = gramPrice * 11.664;
          updateCalculatedPrice();
        });
      }
    } catch (_) {}
  }

  void updateCalculatedPrice() {
    double base = selectedMetal == 'Gold' ? liveMarketPricePerVori : (liveMarketPricePerVori * 0.015);
    double multiplier = 1.0;
    if (selectedKarat == '21K') multiplier = 0.916;
    if (selectedKarat == '18K') multiplier = 0.75;

    setState(() {
      _priceController.text = (base * multiplier).toStringAsFixed(0);
    });
  }

  void calculateBill() {
    double pricePerVori = double.tryParse(_priceController.text) ?? 0.0;
    
    double vori = double.tryParse(_voriController.text) ?? 0.0;
    double ana = double.tryParse(_anaController.text) ?? 0.0;
    double roti = double.tryParse(_rotiController.text) ?? 0.0;
    double point = double.tryParse(_pointController.text) ?? 0.0;

    double totalVoriEquivalent = vori + (ana / 16) + (roti / 96) + (point / 1000);

    totalMetalPrice = pricePerVori * totalVoriEquivalent;

    double muzoriInput = double.tryParse(_muzoriValueController.text) ?? 0.0;
    if (selectedMuzoriType == 'Fixed') {
      totalMuzori = muzoriInput;
    } else if (selectedMuzoriType == 'PerVori') {
      totalMuzori = muzoriInput * totalVoriEquivalent;
    } else if (selectedMuzoriType == 'Percent') {
      totalMuzori = totalMetalPrice * (muzoriInput / 100);
    }

    grandTotal = totalMetalPrice + totalMuzori;

    setState(() {
      showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                Icon(Icons.calculate_rounded, color: Colors.black, size: 24),
                SizedBox(width: 10),
                Text(
                  'হিসাব করুন',
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildCheckboxTile('Gold', selectedMetal == 'Gold', (val) {
                setState(() { selectedMetal = 'Gold'; updateCalculatedPrice(); });
              }),
              const SizedBox(width: 20),
              _buildCheckboxTile('Silver', selectedMetal == 'Silver', (val) {
                setState(() { selectedMetal = 'Silver'; updateCalculatedPrice(); });
              }),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCheckboxTile('২২ ক্যারেট', selectedKarat == '22K', (val) {
                setState(() { selectedKarat = '22K'; updateCalculatedPrice(); });
              }),
              _buildCheckboxTile('২১ ক্যারেট', selectedKarat == '21K', (val) {
                setState(() { selectedKarat = '21K'; updateCalculatedPrice(); });
              }),
              _buildCheckboxTile('১৮ ক্যারেট', selectedKarat == '18K', (val) {
                setState(() { selectedKarat = '18K'; updateCalculatedPrice(); });
              }),
            ],
          ),
          const SizedBox(height: 16),
          const Text('বর্তমান গহনার দাম (প্রতি ভরি)', style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            decoration: _inputDecoration('টাকা লিখুন'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCheckboxTile('ফিক্সড মুজরী', selectedMuzoriType == 'Fixed', (val) {
                setState(() { selectedMuzoriType = 'Fixed'; _muzoriValueController.text = "500"; });
              }),
              _buildCheckboxTile('ভরি প্রতি মুজরী', selectedMuzoriType == 'PerVori', (val) {
                setState(() { selectedMuzoriType = 'PerVori'; _muzoriValueController.text = "15000"; });
              }),
              _buildCheckboxTile('মুজরী %', selectedMuzoriType == 'Percent', (val) {
                setState(() { selectedMuzoriType = 'Percent'; _muzoriValueController.text = "6"; });
              }),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            selectedMuzoriType == 'Fixed' ? 'ফিক্সড মুজরী লিখুন' : (selectedMuzoriType == 'PerVori' ? 'প্রতি ভরি মুজরী লিখুন' : 'মুজরী % লিখুন'),
            style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _muzoriValueController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            decoration: _inputDecoration('মূল্য বা পার্সেন্ট দিন'),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildWeightBox('কত ভরি তা লিখুন', _voriController)),
              const SizedBox(width: 12),
              Expanded(child: _buildWeightBox('কত আনা তা লিখুন', _anaController)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildWeightBox('কত রতি তা লিখুন', _rotiController)),
              const SizedBox(width: 12),
              Expanded(child: _buildWeightBox('কত পয়েন্ট তা লিখুন', _pointController)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: calculateBill,
              child: const Text(
                'হিসাব করুন',
                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (showResult) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade700),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _resultRow('মোট সোনার মূল্য:', '৳ ${totalMetalPrice.toStringAsFixed(2)}'),
                  const Divider(color: Colors.black12),
                  _resultRow('মোট মুজরি:', '৳ ${totalMuzori.toStringAsFixed(2)}'),
                  const Divider(color: Colors.amber),
                  _resultRow('মোট মূল্য:', '৳ ${grandTotal.toStringAsFixed(2)}', isBold: true),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(String title, bool isSelected, Function(bool?) onChanged) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: isSelected,
            activeColor: Colors.amber.shade700,
            checkColor: Colors.white,
            onChanged: onChanged,
          ),
          Text(title, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWeightBox(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.black87, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 12),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.amber)),
    );
  }

  Widget _resultRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? Colors.black87 : Colors.black54, fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(color: isBold ? Colors.green.shade800 : Colors.black87, fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
