import 'package:flutter/material.dart';

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

class PakaBillView extends StatefulWidget {
  const PakaBillView({Key? key}) : super(key: key);

  @override
  State<PakaBillView> createState() => _PakaBillViewState();
}

class _PakaBillViewState extends State<PakaBillView> {
  // কালার থিম
  final Color primaryBrown = const Color(0xFF7A4A12);
  final Color cardBackground = const Color(0xFFFAF4E8);
  final Color headerBorderColor = const Color(0xFF8D5B28);

  // কাস্টমার ইনফো কন্ট্রোলার
  final TextEditingController _orderNoController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(text: "12/10/2026");
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String selectedKarat = '22k';
  double marketPricePerVori = 228030.0;

  // অগ্রিম জমা
  final TextEditingController _advanceCashController = TextEditingController();
  String advanceGoldKarat = '22k';
  final TextEditingController _advVoriController = TextEditingController();
  final TextEditingController _advAnaController = TextEditingController();
  final TextEditingController _advRotiController = TextEditingController();
  final TextEditingController _advPointController = TextEditingController();

  // গহনার বিস্তারিত (৪টি রো)
  List<TextEditingController> descControllers = List.generate(4, (_) => TextEditingController());
  List<String> rowKarats = List.generate(4, (_) => '22k');
  List<TextEditingController> voriControllers = List.generate(4, (_) => TextEditingController());
  List<TextEditingController> anaControllers = List.generate(4, (_) => TextEditingController());
  List<TextEditingController> rotiControllers = List.generate(4, (_) => TextEditingController());
  List<TextEditingController> pointControllers = List.generate(4, (_) => TextEditingController());

  // মেকিং চার্জ
  final TextEditingController _makingChargeController = TextEditingController();

  // বাজার দর ম্যাপ
  final Map<String, double> goldPrices = {
    '22k': 228030.0,
    '21k': 217777.0,
    '18k': 187032.0,
  };

  @override
  void initState() {
    super.initState();
    marketPricePerVori = goldPrices[selectedKarat] ?? 228030.0;
  }

  void _onKaratChanged(String? newKarat) {
    if (newKarat != null) {
      setState(() {
        selectedKarat = newKarat;
        marketPricePerVori = goldPrices[selectedKarat] ?? 228030.0;
      });
    }
  }

  // ওজন কনভার্সন ফাংশন (মোট পয়েন্টে রূপান্তর)
  double _convertToTotalPoints(double vori, double ana, double roti, double point) {
    return (vori * 16 * 6 * 10) + (ana * 6 * 10) + (roti * 10) + point;
  }

  // পয়েন্ট থেকে ভরি, আনা, রতি, পয়েন্ট অবজেক্ট
  String _formatPointsToWeightString(double totalPoints) {
    if (totalPoints <= 0) return "০.০০ ভরি";
    
    int pts = totalPoints.round();
    int vori = pts ~/ 960;
    pts %= 960;
    int ana = pts ~/ 60;
    pts %= 60;
    int roti = pts ~/ 10;
    int point = pts % 10;

    String res = "";
    if (vori > 0) res += "${toBanglaDigit(vori.toString())} ভরি ";
    if (ana > 0) res += "${toBanglaDigit(ana.toString())} আনা ";
    if (roti > 0) res += "${toBanglaDigit(roti.toString())} রতি ";
    if (point > 0) res += "${toBanglaDigit(point.toString())} পয়েন্ট";
    
    return res.isEmpty ? "০ ভরি" : res.trim();
  }

  @override
  Widget build(BuildContext context) {
    // ১. মোট ওজনের হিসাব
    double totalJewelryPoints = 0;
    for (int i = 0; i < 4; i++) {
      double v = double.tryParse(voriControllers[i].text) ?? 0;
      double a = double.tryParse(anaControllers[i].text) ?? 0;
      double r = double.tryParse(rotiControllers[i].text) ?? 0;
      double p = double.tryParse(pointControllers[i].text) ?? 0;
      totalJewelryPoints += _convertToTotalPoints(v, a, r, p);
    }

    // ২. অগ্রিম সোনার ওজন
    double advV = double.tryParse(_advVoriController.text) ?? 0;
    double advA = double.tryParse(_advAnaController.text) ?? 0;
    double advR = double.tryParse(_advRotiController.text) ?? 0;
    double advP = double.tryParse(_advPointController.text) ?? 0;
    double totalAdvGoldPoints = _convertToTotalPoints(advV, advA, advR, advP);

    // ৩. নিট গহনার ওজন
    double netJewelryPoints = totalJewelryPoints - totalAdvGoldPoints;
    if (netJewelryPoints < 0) netJewelryPoints = 0;

    // ৪. মূল্যের হিসাব
    double netVoriEquivalent = netJewelryPoints / 960.0;
    double netJewelryPrice = netVoriEquivalent * marketPricePerVori;

    // অগ্রিম টাকা বাদ
    String cleanAdvCash = _advanceCashController.text.replaceAll(',', '').replaceAll('০', '0').replaceAll('১', '1').replaceAll('২', '2').replaceAll('৩', '3').replaceAll('৪', '4').replaceAll('৫', '5').replaceAll('৬', '6').replaceAll('৭', '7').replaceAll('৮', '8').replaceAll('৯', '9');
    double advCash = double.tryParse(cleanAdvCash) ?? 0;

    double priceAfterAdvCash = netJewelryPrice - advCash;
    if (priceAfterAdvCash < 0) priceAfterAdvCash = 0;

    // মেকিং চার্জ
    String cleanMaking = _makingChargeController.text.replaceAll(',', '').replaceAll('০', '0').replaceAll('১', '1').replaceAll('২', '2').replaceAll('৩', '3').replaceAll('৪', '4').replaceAll('৫', '5').replaceAll('৬', '6').replaceAll('৭', '7').replaceAll('৮', '8').replaceAll('৯', '9');
    double makingCharge = double.tryParse(cleanMaking) ?? 0;

    double grandTotal = priceAfterAdvCash + makingCharge;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // ================= ১. হেডার সেকশন =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: headerBorderColor, width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    'পরমা জুয়েলার্স',
                    style: TextStyle(
                      color: primaryBrown,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'কাপুরিয়া পট্টি, চৌরাস্তা, যশোর।',
                    style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ================= ২. কাস্টমার তথ্য =================
            _buildSectionCard(
              title: 'কাস্টমার',
              icon: Icons.person,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInlineLabelField('অর্ডার নং:', _orderNoController, hint: 'ম্যানুয়াল ইনপুট'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInlineLabelField('তাং:', _dateController, hint: 'দিন/মাস/বছর'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('ক্যারেট: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedKarat,
                            isDense: true,
                            items: ['22k', '21k', '18k'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: _onKaratChanged,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text('বাজার মূল্য:  ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          formatNumberWithCommas(marketPricePerVori),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      const Text(' (প্রতি ভরি)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildInlineLabelField('কাস্টমারের নাম:', _customerNameController, hint: 'ম্যানুয়াল ইনপুট'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('ফোন নাম্বার:  ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Text('+৮৮০', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDeco('ম্যানুয়াল ইনপুট'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildInlineLabelField('ঠিকানা:', _addressController, hint: 'ম্যানুয়াল ইনপুট'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ================= ৩. কাস্টমারের অগ্রিম জমা =================
            _buildSectionCard(
              title: 'কাস্টমারের অগ্রিম জমা',
              icon: Icons.monetization_on,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('টাকা:  ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: TextField(
                            controller: _advanceCashController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            decoration: _inputDeco('১,০০০ / ১০,০০০ / ১,০০,০০০'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('সোনা:  ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: advanceGoldKarat,
                            isDense: true,
                            items: ['22k', '21k', '18k'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => advanceGoldKarat = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMiniWeightInput('ভরি', _advVoriController)),
                      const SizedBox(width: 4),
                      Expanded(child: _buildMiniWeightInput('আনা', _advAnaController)),
                      const SizedBox(width: 4),
                      Expanded(child: _buildMiniWeightInput('রতি', _advRotiController)),
                      const SizedBox(width: 4),
                      Expanded(child: _buildMiniWeightInput('পয়েন্ট', _advPointController)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ================= ৪. গহনার বিস্তারিত =================
            _buildSectionCard(
              title: 'গহনার বিস্তারিত',
              icon: Icons.diamond,
              child: Column(
                children: [
                  // টেবিল হেডার
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    color: Colors.grey.shade300,
                    child: Row(
                      children: const [
                        SizedBox(width: 20, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        Expanded(flex: 3, child: Text('গহনার বিবরণ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        SizedBox(width: 45, child: Text('ক্যারেট', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        SizedBox(width: 4),
                        Expanded(child: Center(child: Text('ভরি', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)))),
                        Expanded(child: Center(child: Text('আনা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)))),
                        Expanded(child: Center(child: Text('রতি', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)))),
                        Expanded(child: Center(child: Text('পয়েন্ট', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  // ৪টি লাইন
                  for (int i = 0; i < 4; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          SizedBox(width: 20, child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 34,
                              child: TextField(
                                controller: descControllers[i],
                                decoration: _inputDeco('১ টা চেন / আংটি ইত্যাদি'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: rowKarats[i],
                                isDense: true,
                                style: const TextStyle(fontSize: 12, color: Colors.black),
                                items: ['22k', '21k', '18k'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => rowKarats[i] = val);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(child: _buildMiniWeightInput('ভরি', voriControllers[i])),
                          const SizedBox(width: 2),
                          Expanded(child: _buildMiniWeightInput('আনা', anaControllers[i])),
                          const SizedBox(width: 2),
                          Expanded(child: _buildMiniWeightInput('রতি', rotiControllers[i])),
                          const SizedBox(width: 2),
                          Expanded(child: _buildMiniWeightInput('পয়েন্ট', pointControllers[i])),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ================= ৫ & ৬. ওজনের ও মূল্যের হিসাব (পাশাপাশি/নিচে) =================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // গহনার ওজনের হিসাব
                Expanded(
                  child: _buildSectionCard(
                    title: 'গহনার ওজনের হিসাব',
                    icon: Icons.scale,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalculationRow('মোট ওজন:', _formatPointsToWeightString(totalJewelryPoints)),
                        const Divider(),
                        _buildCalculationRow('অগ্রিম জমা (সোনার):', _formatPointsToWeightString(totalAdvGoldPoints)),
                        const Divider(),
                        _buildCalculationRow('নিট গহনার ওজন:', _formatPointsToWeightString(netJewelryPoints), isHighlight: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // গহনার মূল্যের হিসাব
                Expanded(
                  child: _buildSectionCard(
                    title: 'গহনার মূল্যের হিসাব',
                    icon: Icons.calculate,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalculationRow('নিট গহনার মূল্য:', formatNumberWithCommas(netJewelryPrice)),
                        const Divider(),
                        _buildCalculationRow('(-) অগ্রিম টাকা জমা:', formatNumberWithCommas(advCash)),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('মেকিং চার্জ:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            SizedBox(
                              width: 70,
                              height: 30,
                              child: TextField(
                                controller: _makingChargeController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                decoration: _inputDeco('০.০০'),
                              ),
                            ),
                          ],
                        ),
                        const Divider(thickness: 1.5, color: Colors.brown),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: _buildCalculationRow('সর্বমোট মূল্য:', formatNumberWithCommas(grandTotal), isBold: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= উইজেট বিল্ডার ফাংশনসমূহ =================
  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: headerBorderColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // কার্ড হেডার ব্যাজ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryBrown,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(7), bottomRight: Radius.circular(12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.amber, size: 16),
                const SizedBox(width: 6),
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInlineLabelField(String label, TextEditingController controller, {required String hint}) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(width: 6),
        Expanded(
          child: SizedBox(
            height: 36,
            child: TextField(
              controller: controller,
              decoration: _inputDeco(hint),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniWeightInput(String hint, TextEditingController controller) {
    return SizedBox(
      height: 34,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 10, color: Colors.black38),
          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade400)),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11, color: Colors.black38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade400)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: primaryBrown)),
    );
  }

  Widget _buildCalculationRow(String label, String value, {bool isHighlight = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: (isHighlight || isBold) ? FontWeight.bold : FontWeight.w600,
            color: isHighlight ? primaryBrown : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isHighlight ? primaryBrown : (isBold ? Colors.red.shade900 : Colors.black87),
          ),
        ),
      ],
    );
  }
}
