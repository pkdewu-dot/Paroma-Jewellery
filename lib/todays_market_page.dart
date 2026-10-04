import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({super.key});

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  static const String sourceUrl = 'https://www.goldr.org/';

  final TextEditingController deductionController =
      TextEditingController(text: '20');

  String selectedUnit = 'ভরি';

  bool loading = true;
  String? error;

  final Map<String, double> gold = {};
  final Map<String, double> silver = {};

  static const units = {
    'ভরি': 1.0,
    'আনা': 16.0,
    'রতি': 96.0,
    'পয়েন্ট': 960.0,
    'গ্রাম': 11.664,
  };

  @override
  void initState() {
    super.initState();
    fetchRates();
  }

  @override
  void dispose() {
    deductionController.dispose();
    super.dispose();
  }

  Future<void> fetchRates() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse(sourceUrl),
        headers: const {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 15) AppleWebKit/537.36 Chrome/154 Mobile Safari/537.36',
          'Accept': 'text/html',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final document = parser.parse(response.body);

      final newGold = <String, double>{};
      final newSilver = <String, double>{};

      for (final table in document.querySelectorAll('table')) {
        final text = clean(table.text);

        final isGold =
            text.contains('সোনার') &&
            text.contains('প্রতি ভরি');

        final isSilver =
            (text.contains('রুপার') ||
                text.contains('রূপার') ||
                text.contains('চান্দি')) &&
            text.contains('প্রতি ভরি');

        if (!isGold && !isSilver) {
          continue;
        }

        for (final row in table.querySelectorAll('tr')) {
          final cells = row.querySelectorAll('th, td');

          if (cells.length < 2) {
            continue;
          }

          final label = clean(row.text);

          String? carat;

          if (label.contains('22')) {
            carat = '22';
          } else if (label.contains('21')) {
            carat = '21';
          } else if (label.contains('18')) {
            carat = '18';
          }

          if (carat == null) {
            continue;
          }

          double? rate;

          // প্রথমে দ্বিতীয় cell থেকে rate নেওয়া হবে।
          rate = firstNumber(cells[1].text);

          // না পাওয়া গেলে পুরো row থেকে খোঁজা হবে।
          rate ??= firstLargeNumber(row.text);

          if (rate == null || rate <= 0) {
            continue;
          }

          if (isGold) {
            newGold[carat] = rate;
          }

          if (isSilver) {
            newSilver[carat] = rate;
          }
        }
      }

      // অতিরিক্ত fallback
      if (newGold.length < 3 || newSilver.length < 3) {
        for (final row in document.querySelectorAll('tr')) {
          final text = clean(row.text);

          String? carat;

          if (text.contains('22')) {
            carat = '22';
          } else if (text.contains('21')) {
            carat = '21';
          } else if (text.contains('18')) {
            carat = '18';
          }

          if (carat == null) {
            continue;
          }

          final value = firstLargeNumber(text);

          if (value == null) {
            continue;
          }

          if (text.contains('Gold') ||
              text.contains('gold') ||
              text.contains('সোনা')) {
            newGold[carat] ??= value;
          }

          if (text.contains('Silver') ||
              text.contains('silver') ||
              text.contains('রূপা') ||
              text.contains('রুপা')) {
            newSilver[carat] ??= value;
          }
        }
      }

      if (newGold.length < 3) {
        throw Exception('Gold rate পাওয়া যায়নি');
      }

      if (newSilver.length < 3) {
        throw Exception('Silver rate পাওয়া যায়নি');
      }

      if (!mounted) return;

      setState(() {
        gold
          ..clear()
          ..addAll(newGold);

        silver
          ..clear()
          ..addAll(newSilver);

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error =
            'আজকের বাজারের rate আনা যায়নি। আবার চেষ্টা করুন।';
      });
    }
  }

  String clean(String value) {
    return value
        .replaceAll('\u00A0', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  double? firstNumber(String text) {
    final normalized = normalizeDigits(text)
        .replaceAll('৳', '')
        .replaceAll('Tk', '')
        .replaceAll('TK', '');

    final matches =
        RegExp(r'\d[\d,]*(?:\.\d+)?').allMatches(normalized);

    for (final match in matches) {
      final value = double.tryParse(
        match.group(0)!.replaceAll(',', ''),
      );

      if (value != null && value >= 1000) {
        return value;
      }
    }

    return null;
  }

  double? firstLargeNumber(String text) {
    return firstNumber(text);
  }

  String normalizeDigits(String text) {
    const bn = '০১২৩৪৫৬৭৮৯';
    const en = '0123456789';

    var result = text;

    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(bn[i], en[i]);
    }

    return result;
  }

  double get deduction {
    final value = double.tryParse(
      normalizeDigits(
        deductionController.text,
      ).replaceAll(',', '.'),
    );

    if (value == null) {
      return 20;
    }

    return value.clamp(0, 100);
  }

  double convert(double value) {
    return value / (units[selectedUnit] ?? 1);
  }

  double oldGold(double value) {
    return value * (1 - deduction / 100);
  }

  String money(double value) {
    final rounded = value.round();

    final formatted = rounded.toString();

    String result = formatted;

    if (formatted.length > 3) {
      final lastThree =
          formatted.substring(formatted.length - 3);

      var remaining =
          formatted.substring(0, formatted.length - 3);

      final parts = <String>[];

      while (remaining.length > 2) {
        parts.insert(
          0,
          remaining.substring(remaining.length - 2),
        );

        remaining =
            remaining.substring(0, remaining.length - 2);
      }

      if (remaining.isNotEmpty) {
        parts.insert(0, remaining);
      }

      result = '${parts.join(',')},$lastThree';
    }

    return '৳${banglaDigits(result)}';
  }

  String banglaDigits(String text) {
    const en = '0123456789';
    const bn = '০১২৩৪৫৬৭৮৯';

    var result = text;

    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(en[i], bn[i]);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B0000),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'আজকের বাজার',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loading ? null : fetchRates,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B0000),
              ),
            )
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 55,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: fetchRates,
                          child: const Text(
                            'আবার চেষ্টা করুন',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchRates,
                  child: ListView(
                    padding: const EdgeInsets.all(10),
                    children: [
                      buildUnits(),
                      const SizedBox(height: 12),
                      buildDeduction(),
                      const SizedBox(height: 12),
                      buildGoldTable(),
                      const SizedBox(height: 16),
                      buildSilverTable(),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Main Rate Source: GoldR.org',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget buildUnits() {
    const colors = [
      Color(0xFF7B1FA2),
      Color(0xFF1565C0),
      Color(0xFF00897B),
      Color(0xFFE65100),
      Color(0xFF2E7D32),
    ];

    final names = [
      'ভরি',
      'আনা',
      'রতি',
      'পয়েন্ট',
      'গ্রাম',
    ];

    return Row(
      children: List.generate(names.length, (index) {
        final name = names[index];
        final selected = selectedUnit == name;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedUnit = name;
                });
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: colors[index],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected
                        ? Colors.black
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget buildDeduction() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE0D7CE),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'পুরাতন সোনার ডিডাকশন',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 90,
            height: 44,
            child: TextField(
              controller: deductionController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                suffixText: '%',
                filled: true,
                fillColor: const Color(0xFFFFF8E1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGoldTable() {
    return buildTable(
      title: 'সোনার বাজার',
      headers: [
        'ক্যারেট',
        'মেইন বাজার মূল্য',
        'পুরাতন সোনার মূল্য',
      ],
      rows: ['22', '21', '18'].map((carat) {
        final value = gold[carat] ?? 0;

        return [
          '$carat ক্যারেট',
          money(convert(value)),
          money(convert(oldGold(value))),
        ];
      }).toList(),
    );
  }

  Widget buildSilverTable() {
    return buildTable(
      title: 'রূপার বাজার',
      headers: [
        'ক্যারেট',
        'রূপার দাম',
      ],
      rows: ['22', '21', '18'].map((carat) {
        final value = silver[carat] ?? 0;

        return [
          '$carat ক্যারেট',
          money(convert(value)),
        ];
      }).toList(),
    );
  }

  Widget buildTable({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: const BoxDecoration(
              color: Color(0xFF8B0000),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Table(
            border: TableBorder.all(
              color: Colors.grey,
            ),
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  color: Color(0xFFF0E6D8),
                ),
                children: headers
                    .map(
                      (text) => tableCell(
                        text,
                        true,
                      ),
                    )
                    .toList(),
              ),
              ...rows.map(
                (row) => TableRow(
                  children: row
                      .map(
                        (text) => tableCell(
                          text,
                          true,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget tableCell(
    String text,
    bool bold,
  ) {
    return Padding(
      padding: const EdgeInsets.all(9),
      child: Text(
        banglaDigits(text),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight:
              bold ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }
}
