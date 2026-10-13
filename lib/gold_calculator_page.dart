import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ================= হেল্পার ফাংশন: বাংলা ডিজিট ও কমা ফরম্যাটিং =================
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
  String selectedMetal = 'Gold'; 
  String selectedKarat = '22K';   
  String selectedMuzoriType = 'Percent'; 
  
  // ভিডিও অনুযায়ী সঠিক বাজার দর (প্রতি ভরি)
  final Map<String, Map<String, double>> marketPrices = {
    'Gold': {
      '22K': 228030.0,
      '21K': 217777.0,
      '18K': 187032.0,
    },
    'Silver': {
      '22K': 4199.0,
      '21K': 3966.0,
      '18K': 3441.0,
    }
  };

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
    updatePriceBox();
  }

  void updatePriceBox() {
    double price = marketPrices[selectedMetal]?[selectedKarat] ?? 0.0;
    setState(() {
      _priceController.text = price.toStringAsFixed(0);
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
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          Text(title, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWeightBox(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center, // লেখা মাঝখানে বিন্যাস করা হয়েছে
      style: const TextStyle(color: Colors.black87, fontSize: 14),
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
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 12),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.amber)),
    );
  }

  Widget _resultRow(String label, String value, {bool isBold = false, double fontSize = 14, Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label, 
          style: TextStyle(
            color: isBold ? (textColor ?? Colors.black87) : Colors.black87, 
            fontSize: fontSize, 
            fontWeight: FontWeight.bold 
          )
        ),
        Text(
          value, 
          style: TextStyle(
            color: isBold ? (textColor ?? Colors.green.shade800) : Colors.black87, 
            fontSize: fontSize, 
            fontWeight: FontWeight.bold 
          )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // স্কাই ব্লু কালার হেডিং বক্স ("নিচের অপশন থেকে সিলেক্ট করুন")
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'নিচের অপশন থেকে সিলেক্ট করুন',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildCheckboxTile('Gold', selectedMetal == 'Gold', (val) {
                setState(() { 
                  selectedMetal = 'Gold'; 
                  updatePriceBox(); 
                });
              }),
              const SizedBox(width: 30),
              _buildCheckboxTile('Silver', selectedMetal == 'Silver', (val) {
                setState(() { 
                  selectedMetal = 'Silver'; 
                  updatePriceBox(); 
                });
              }),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCheckboxTile('২২ ক্যারেট', selectedKarat == '22K', (val) {
                setState(() { 
                  selectedKarat = '22K'; 
                  updatePriceBox(); 
                });
              }),
              _buildCheckboxTile('২১ ক্যারেট', selectedKarat == '21K', (val) {
                setState(() { 
                  selectedKarat = '21K'; 
                  updatePriceBox(); 
                });
              }),
              _buildCheckboxTile('১৮ ক্যারেট', selectedKarat == '18K', (val) {
                setState(() { 
                  selectedKarat = '18K'; 
                  updatePriceBox(); 
                });
              }),
            ],
          ),
          const SizedBox(height: 16),
          const Text('বর্তমান গহনার দাম (প্রতি ভরি)', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
            decoration: _inputDecoration('বাজার দর'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCheckboxTile('ফিক্সড', selectedMuzoriType == 'Fixed', (val) {
                      setState(() { selectedMuzoriType = 'Fixed'; _muzoriValueController.text = "500"; });
                    }),
                    _buildCheckboxTile('ভরি প্রতি', selectedMuzoriType == 'PerVori', (val) {
                      setState(() { selectedMuzoriType = 'PerVori'; _muzoriValueController.text = "15000"; });
                    }),
                    _buildCheckboxTile('মুজরি %', selectedMuzoriType == 'Percent', (val) {
                      setState(() { selectedMuzoriType = 'Percent'; _muzoriValueController.text = "6"; });
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 75,
                child: TextField(
                  controller: _muzoriValueController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                  decoration: _inputDecoration('মান'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // গহনার ওজন হেডিং (পার্পল কালার বক্স, বড় ফন্ট ও মাঝখানে বিন্যাস)
          Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: const Text(
                'গহনার ওজন',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.purple, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.shade700, width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _resultRow('মোট সোনার মূল্য:', formatNumberWithCommas(totalMetalPrice, isCurrency: true), fontSize: 15),
                  const Divider(color: Colors.black12, height: 16),
                  _resultRow('মোট মুজরি:', formatNumberWithCommas(totalMuzori, isCurrency: true), fontSize: 15),
                  const Divider(color: Colors.amber, height: 16, thickness: 1.5),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _resultRow('মোট মূল্য:', formatNumberWithCommas(grandTotal, isCurrency: true), isBold: true, fontSize: 18, textColor: Colors.green.shade900),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
