import 'package:flutter/material.dart';

class PakaBillView extends StatefulWidget {
  const PakaBillView({Key? key}) : super(key: key);

  @override
  State<PakaBillView> createState() => _PakaBillViewState();
}

class _PakaBillViewState extends State<PakaBillView> {
  // কাস্টমার তথ্য কন্ট্রোলার
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _orderNoController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // অগ্রিম স্বর্ণ (ভরি, আনা, রতি, পয়েন্ট)
  final TextEditingController _advGoldVori = TextEditingController(text: '0');
  final TextEditingController _advGoldAna = TextEditingController(text: '0');
  final TextEditingController _advGoldRoti = TextEditingController(text: '0');
  final TextEditingController _advGoldPoint = TextEditingController(text: '0');

  // অগ্রিম নগদ টাকা
  final TextEditingController _advCashController = TextEditingController(text: '0');

  // ৪টি রো গহনার বিবরণ (বিবরণ, ক্যারেট, ভরি, আনা, রতি, পয়েন্ট, প্রতি ভরি দাম, মুজরি)
  final List<Map<String, TextEditingController>> _itemRows = List.generate(4, (_) => {
    'desc': TextEditingController(),
    'karat': TextEditingController(text: '২২ ক্যারেট'),
    'vori': TextEditingController(text: '0'),
    'ana': TextEditingController(text: '0'),
    'roti': TextEditingController(text: '0'),
    'point': TextEditingController(text: '0'),
    'pricePerVori': TextEditingController(text: '228030'),
    'makingCharge': TextEditingController(text: '0'),
  });

  // হিসাবের ফলাফল ভ্যারিয়েবল
  double totalWeightVori = 0.0;
  double totalNetWeightVori = 0.0;
  double totalNetValue = 0.0;
  double totalMakingCharge = 0.0;
  double grandTotal = 0.0;

  @override
  void initState() {
    super.initState();
    // অ্যাপ চালু হওয়ার সাথেই আজকের তারিখ অটোমেটিক সেট হয়ে যাবে (যেমন: DD/MM/YYYY ফরম্যাটে)
    DateTime now = DateTime.now();
    _dateController.text = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
  }

  void _calculateBill() {
    double tempTotalWeight = 0.0;
    double tempTotalValue = 0.0;
    double tempTotalMaking = 0.0;

    for (var row in _itemRows) {
      double vori = double.tryParse(row['vori']!.text) ?? 0.0;
      double ana = double.tryParse(row['ana']!.text) ?? 0.0;
      double roti = double.tryParse(row['roti']!.text) ?? 0.0;
      double point = double.tryParse(row['point']!.text) ?? 0.0;
      double pricePerVori = double.tryParse(row['pricePerVori']!.text) ?? 0.0;
      double making = double.tryParse(row['makingCharge']!.text) ?? 0.0;

      double itemVoriEq = vori + (ana / 16) + (roti / 96) + (point / 1000);
      tempTotalWeight += itemVoriEq;
      tempTotalValue += (itemVoriEq * pricePerVori);
      tempTotalMaking += making;
    }

    // অগ্রিম স্বর্ণ হিসাব
    double advV = double.tryParse(_advGoldVori.text) ?? 0.0;
    double advA = double.tryParse(_advGoldAna.text) ?? 0.0;
    double advR = double.tryParse(_advGoldRoti.text) ?? 0.0;
    double advP = double.tryParse(_advGoldPoint.text) ?? 0.0;
    double advGoldEq = advV + (advA / 16) + (advR / 96) + (advP / 1000);

    double netWt = tempTotalWeight - advGoldEq;
    if (netWt < 0) netWt = 0;

    double advCash = double.tryParse(_advCashController.text) ?? 0.0;
    double finalGrand = tempTotalValue - advCash + tempTotalMaking;
    if (finalGrand < 0) finalGrand = 0;

    setState(() {
      totalWeightVori = tempTotalWeight;
      totalNetWeightVori = netWt;
      totalNetValue = tempTotalValue;
      totalMakingCharge = tempTotalMaking;
      grandTotal = finalGrand;
    });
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: Colors.brown),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.white,
      ),
      style: const TextStyle(fontSize: 13),
      onChanged: (_) => _calculateBill(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // হালকা সোনালী/হলুদ ব্যাকগ্রাউন্ড
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
            // দোকানের হেডার
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Text('পরমা জুয়েলার্স', style: TextStyle(color: Color(0xFFFFD700), fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('কাপুড়িয়া পট্টি, চৌরাস্তা, যশোর', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  SizedBox(height: 2),
                  Text('পাকা ক্যাশ মেমো / বিল', style: TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold)),
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
                        Expanded(flex: 2, child: _buildTextField('গ্রাহকের নাম', _customerNameController)),
                        const SizedBox(width: 8),
                        Expanded(flex: 1, child: _buildTextField('মোবাইল নং', _customerPhoneController, isNumber: true)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(flex: 2, child: _buildTextField('ঠিকানা', _customerAddressController)),
                        const SizedBox(width: 8),
                        Expanded(flex: 1, child: _buildTextField('তারিখ', _dateController)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // গহনার বিবরণ (৪টি রো)
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
                                Expanded(flex: 2, child: _buildTextField('পণ্যের বিবরণ #${index + 1}', row['desc']!)),
                                const SizedBox(width: 6),
                                Expanded(flex: 1, child: _buildTextField('মূল্য/ভরি', row['pricePerVori']!, isNumber: true)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(child: _buildTextField('ভরি', row['vori']!, isNumber: true)),
                                const SizedBox(width: 4),
                                Expanded(child: _buildTextField('আনা', row['ana']!, isNumber: true)),
                                const SizedBox(width: 4),
                                Expanded(child: _buildTextField('রতি', row['roti']!, isNumber: true)),
                                const SizedBox(width: 4),
                                Expanded(child: _buildTextField('পয়েন্ট', row['point']!, isNumber: true)),
                                const SizedBox(width: 4),
                                Expanded(child: _buildTextField('মুজরি', row['makingCharge']!, isNumber: true)),
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
              padding: const EdgeInsets.all(12),
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
                      const Text('মোট ওজন:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${totalWeightVori.toStringAsFixed(3)} ভরি', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('নিট ওজন (বাদ অগ্রিম):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                      Text('${totalNetWeightVori.toStringAsFixed(3)} ভরি', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('সর্বমোট মূল্য:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('৳ ${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // হিসাব করুন বাটন
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D6E63),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _calculateBill,
                child: const Text('হিসাব আপডেট করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
