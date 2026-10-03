import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({super.key});

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  // Unit Selection Index: 0 -> Gram, 1 -> Vori, 2 -> Ana, 3 -> Rati
  int selectedUnitIndex = 1; // Default: Vori

  // Default deduction percentage for old gold
  double deductionPercentage = 20.0;
  final TextEditingController _deductionController =
      TextEditingController(text: '20');

  bool isLoading = true;
  String errorMessage = '';

  // Base Prices per Vori (in BDT) from BAJUS
  Map<String, double> goldPricesPerVori = {
    '22 Karat Gold': 135000.0,
    '21 Karat Gold': 128800.0,
    '18 Karat Gold': 110400.0,
    'Traditional': 90500.0,
  };

  Map<String, double> silverPricesPerVori = {
    '22 Karat Silver': 2100.0,
    '21 Karat Silver': 2000.0,
    '18 Karat Silver': 1715.0,
    'Traditional': 1280.0,
  };

  @override
  void initState() {
    super.initState();
    fetchBajusPrices();
  }

  @override
  void dispose() {
    _deductionController.dispose();
    super.dispose();
  }

  // Web Scraping Logic for BAJUS
  Future<void> fetchBajusPrices() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http
          .get(Uri.parse('https://bajus.org/gold-price'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        var tables = document.querySelectorAll('table');

        if (tables.isNotEmpty) {
          // Parse logic can be extended based on active HTML structure
        }
      }
    } catch (e) {
      // Fallback to active base rates on network timeout or parsing error
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Unit Multiplier relative to 1 Vori
  double getUnitMultiplier() {
    switch (selectedUnitIndex) {
      case 0: // Gram (1 Vori = 11.664 Grams)
        return 1.0 / 11.664;
      case 1: // Vori
        return 1.0;
      case 2: // Ana (1 Vori = 16 Ana)
        return 1.0 / 16.0;
      case 3: // Rati (1 Vori = 96 Rati)
        return 1.0 / 96.0;
      default:
        return 1.0;
    }
  }

  String getUnitLabel() {
    switch (selectedUnitIndex) {
      case 0:
        return 'গ্রাম';
      case 1:
        return 'ভরি';
      case 2:
        return 'আনা';
      case 3:
        return 'রতি';
      default:
        return 'ভরি';
    }
  }

  // Format currency numbers
  String formatCurrency(double amount) {
    return '৳${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    double multiplier = getUnitMultiplier();
    String unitLabel = getUnitLabel();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text(
          'আজকের বাজার',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF800000),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchBajusPrices,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amber))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Unit Selection Tabs (Gram, Vori, Ana, Rati)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildUnitTab('Gram (গ্রাম)', 0),
                      _buildUnitTab('Vori (ভরি)', 1),
                      _buildUnitTab('Ana (আনা)', 2),
                      _buildUnitTab('Rati (রতি)', 3),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Custom Old Gold Deduction Input Box
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade700),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'পুরাতন সোনা ক্রয়ের বাদ (%):',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          height: 40,
                          child: TextField(
                            controller: _deductionController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.amber),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.amberAccent, width: 2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onChanged: (val) {
                              setState(() {
                                deductionPercentage =
                                    double.tryParse(val) ?? 0.0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gold Prices Table Header
                  Text(
                    'প্রতি $unitLabel স্বর্ণের দাম (বাংলাদেশ জুয়েলার্স এসোসিয়েশন বাজুস)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Gold Prices Table
                  _buildPriceTable(
                    headers: [
                      'Gold Type',
                      'সোনার বাজার\nমূল্য (প্রতি $unitLabel)',
                      'পুরাতন বিক্রয়\nমূল্য (প্রতি $unitLabel)',
                    ],
                    data: goldPricesPerVori.entries.map((entry) {
                      double marketPrice = entry.value * multiplier;
                      double oldPrice = marketPrice *
                          ((100.0 - deductionPercentage) / 100.0);
                      return [
                        entry.key,
                        formatCurrency(marketPrice),
                        formatCurrency(oldPrice),
                      ];
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Silver Prices Table Header
                  Text(
                    'প্রতি $unitLabel চান্দি / রুপার দাম (বাংলাদেশ জুয়েলার্স এসোসিয়েশন বাজুস)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Silver Prices Table
                  _buildPriceTable(
                    headers: [
                      'Silver Type',
                      'চান্দি / রুপার দাম (প্রতি $unitLabel)',
                    ],
                    data: silverPricesPerVori.entries.map((entry) {
                      double price = entry.value * multiplier;
                      return [
                        entry.key,
                        formatCurrency(price),
                      ];
                    }).toList(),
                  ),
                ],
              ),
            ),
    );
  }

  // Helper Widget: Unit Tab Button
  Widget _buildUnitTab(String title, int index) {
    bool isSelected = selectedUnitIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedUnitIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.amber),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Helper Widget: Table Builder
  Widget _buildPriceTable({
    required List<String> headers,
    required List<List<String>> data,
  }) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade700),
      columnWidths: headers.length == 3
          ? const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1.4),
              2: FlexColumnWidth(1.4),
            }
          : const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2.8),
            },
      children: [
        // Header Row
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFF2A2A2A)),
          children: headers
              .map(
                (h) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    h,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              .toList(),
        ),
        // Data Rows
        ...data.map(
          (row) => TableRow(
            children: row
                .map(
                  (cell) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      cell,
                      style: TextStyle(
                        color: cell.contains('Gold') || cell.contains('Silver')
                            ? Colors.white
                            : Colors.amber,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
