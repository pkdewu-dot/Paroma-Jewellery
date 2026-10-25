import 'package:flutter/material.dart';

// বাংলা সংখ্যা কনভার্ট করার হেল্পার ফাংশন
String toBanglaDigit(String input) {
  const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const banglaDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  for (int i = 0; i < englishDigits.length; i++) {
    input = input.replaceAll(englishDigits[i], banglaDigits[i]);
  }
  return input;
}

class PakaBillView extends StatefulWidget {
  const PakaBillView({Key? key}) : super(key: key);

  @override
  State<PakaBillView> createState() => _PakaBillViewState();
}

class _PakaBillViewState extends State<PakaBillView> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final TextEditingController _advGoldVori = TextEditingController(text: '০');
  final TextEditingController _advGoldAna = TextEditingController(text: '০');
  final TextEditingController _advGoldRoti = TextEditingController(text: '০');
  final TextEditingController _advGoldPoint = TextEditingController(text: '০');

  final TextEditingController _advCashController = TextEditingController(text: '০');

  // আজকের বাজারের সাথে সামঞ্জস্যপূর্ণ সঠিক রেট তালিকা
  final Map<String, String> karatPrices = {
    '২২ ক্যারেট': '২২৮০৩০',
    '২১ ক্যারেট': '২১০৯৪৩',
    '১৮ ক্যারেট': '১৮১২০০',
  };

  // ৪টি রো গহনার বিবরণ
  late final List<Map<String, dynamic>> _itemRows;

  @override
  void initState() {
    super.initState();
    // অটোমেটিক আজকের তারিখ দিন/মাস/বছর ফরম্যাটে এবং বাংলা ডিজিটে সেট করা
    DateTime now = DateTime.now();
    String engDate = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    _dateController.text = toBanglaDigit(engDate);

    // ইনিশিয়ালাইজেশন
    _itemRows = List.generate(4, (_) => {
      'desc': TextEditingController(),
      'karat': '২২ ক্যারেট',
      'priceController': TextEditingController(text: '২২৮০৩০'),
      'vori': TextEditingController(text: '০'),
      'ana': TextEditingController(text: '০'),
      'roti': TextEditingController(text: '০'),
      'point': TextEditingController(text: '০'),
      'makingCharge': TextEditingController(text: '০'),
    });
  }

  double totalWeightVori = 0.0;
  double totalNetWeightVori = 0.0;
  double grandTotal = 0.0;

  double _parseNum(String val) {
    String clean = val
        .replaceAll(',', '')
        .replaceAll('০', '0').replaceAll('১', '1').replaceAll('২', '2')
        .replaceAll('৩', '3').replaceAll('৪', '4').replaceAll('৫', '5')
        .replaceAll('৬', '6').replaceAll('৭', '7').replaceAll('৮', '8')
        .replaceAll('৯', '9');
    return double.tryParse(clean) ?? 0.0;
  }

  void _calculateBill() {
    double tempTotalWeight = 0.0;
    double tempTotalValue = 0.0;
    double tempTotalMaking = 0.0;

    for (var row in _itemRows) {
      double vori = _parseNum(row['vori'].text);
      double ana = _parseNum(row['ana'].text);
      double roti = _parseNum(row['roti'].text);
      double point = _parseNum(row['point'].text);
      double pricePerVori = _parseNum(row['priceController'].text);
      double making = _parseNum(row['makingCharge'].text);

      double itemVoriEq = vori + (ana / 16) + (roti / 96) + (point / 1000);
      tempTotalWeight += itemVoriEq;
      tempTotalValue += (itemVoriEq * pricePerVori);
      tempTotalMaking += making;
    }

    double advV = _parseNum(_advGoldVori.text);
    double advA = _parseNum(_advGoldAna.text);
    double advR = _parseNum(_advGoldRoti.text);
    double advP = _parseNum(_advGoldPoint.text);
    double advGoldEq = advV + (advA / 16) + (advR / 96) + (advP / 1000);

    double netWt = tempTotalWeight - advGoldEq;
    if (netWt < 0) netWt = 0;

    double advCash = _parseNum(_advCashController.text);
    double finalGrand = tempTotalValue - advCash + tempTotalMaking;
    if (finalGrand < 0) finalGrand = 0;

    setState(() {
      totalWeightVori = tempTotalWeight;
      totalNetWeightVori = netWt;
      grandTotal = finalGrand;
    });
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, double fontSize = 13}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11, color: Colors.brown),
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.white,
      ),
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      onChanged: (_) => _calculateBill(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8D6E63),
        title: const Text('পরমা জুয়েলার্স - পাকা বিল', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // দোকানের হেডার (সঠিক ঠিকানা সহ)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Text('পরমা জুয়েলার্স', style: TextStyle(color: Color(0xFFFFD700), fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('কাপুড়িয়া পট্টি, চৌরাস্তা, যশোর', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 2),
                  Text('পাকা ক্যাশ মেমো / বিল', style: TextStyle(color: Colors.amberAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // কাস্টমার তথ্য কার্ড
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('গ্রাহকের বিবরণ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 14)),
                    const Divider(height: 10),
                    Row(
                      children: [
                        Expanded(flex: 3, child: _buildTextField('গ্রাহকের নাম', _customerNameController)),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: _buildTextField('মোবাইল নং', _customerPhoneController, isNumber: true)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(flex: 3, child: _buildTextField('ঠিকানা', _customerAddressController)),
                        const SizedBox(width: 8),
                        Expanded(flex: 1, child: _buildTextField('তাং', _dateController)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // গহনার বিবরণ (ক্যারেট সিলেক্ট করলে লাইভ বাজার দর অটো আপডেট হবে)
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('গহনার বিবরণ ও ওজন (সর্বোচ্চ ৪টি)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 14)),
                    const Divider(height: 10),
                    ..._itemRows.asMap().entries.map((entry) {
                      int index = entry.key;
                      var row = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.brown.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(flex: 2, child: _buildTextField('পণ্যের বিবরণ #${index + 1}', row['desc'])),
                                const SizedBox(width: 6),
                                // ক্যারেট ড্রপডাউন (সঠিক কালার কোড ব্যবহার করা হয়েছে)
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.grey.shade400),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: row['karat'],
                                        isExpanded: true,
                                        style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.bold),
                                        items: ['২২ ক্যারেট', '২১ ক্যারেট', '১৮ ক্যারেট'].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            row['karat'] = newValue!;
                                            row['priceController'].text = karatPrices[newValue]!;
                                            _calculateBill();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(flex: 1, child: _buildTextField('মূল্য/ভরি', row['priceController'], isNumber: true, fontSize: 15)),
                                const SizedBox(width: 4),
                                Expanded(child: _buildTextField('ভরি', row['vori'], isNumber: true)),
                                const SizedBox(width: 4),
                                Expanded(child: _buildTextField('আনা', row['ana'], isNumber: true)),
                                const SizedBox(width: 4),
                                Expanded(child: _buildTextField('রতি', row['roti'], isNumber: true)),
                                const SizedBox(width: 4),
                                Expanded(child: _buildTextField('পয়েন্ট', row['point'], isNumber: true)),
                                const SizedBox(width: 4),
                                Expanded(child: _buildTextField('মুজরি', row['makingCharge'], isNumber: true)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // অগ্রিম জমা কার্ড
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('অগ্রিম জমা (সোনা ও নগদ)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 14)),
                    const Divider(height: 10),
                    const Text('অগ্রিম সোনার ওজন:', style: TextStyle(fontSize: 12, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('ভরি', _advGoldVori, isNumber: true)),
                        const SizedBox(width: 4),
                        Expanded(child: _buildTextField('আনা', _advGoldAna, isNumber: true)),
                        const SizedBox(width: 4),
                        Expanded(child: _buildTextField('রতি', _advGoldRoti, isNumber: true)),
                        const SizedBox(width: 4),
                        Expanded(child: _buildTextField('পয়েন্ট', _advGoldPoint, isNumber: true)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTextField('অগ্রিম নগদ টাকা', _advCashController, isNumber: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // হিসাব ফলাফল সেকশন
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade700, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('মোট ওজন:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${toBanglaDigit(totalWeightVori.toStringAsFixed(3))} ভরি', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('নিট ওজন (বাদ অগ্রিম):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 18)),
                      Text('${toBanglaDigit(totalNetWeightVori.toStringAsFixed(3))} ভরি', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 18)),
                    ],
                  ),
                  const Divider(thickness: 1.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('সর্বমোট মূল্য:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('৳ ${toBanglaDigit(grandTotal.toStringAsFixed(2))}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // হিসাব আপডেট করুন বাটন
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D6E63),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _calculateBill,
                child: const Text('হিসাব আপডেট করুন', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
