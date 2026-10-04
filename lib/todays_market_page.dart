import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({super.key});

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  static const String _sourceUrl = 'https://www.goldr.org/';

  // ১ ভরি = ১৬ আনা = ৯৬ রতি = ৯৬০ পয়েন্ট = ১১.৬৬৪ গ্রাম
  static const Map<String, double> _unitDivisors = {
    'ভরি': 1,
    'আনা': 16,
    'রতি': 96,
    'পয়েন্ট': 960,
    'গ্রাম': 11.664,
  };

  static const List<String> _goldCarats = ['22', '21', '18'];
  static const List<String> _silverCarats = ['22', '21', '18'];

  // পুরাতন সোনার default deduction = ২০%
  final TextEditingController _deductionController =
      TextEditingController(text: '20');

  String _selectedUnit = 'ভরি';

  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _lastUpdated;

  final Map<String, double> _goldPerVori = {};
  final Map<String, double> _silverPerVori = {};

  @override
  void initState() {
    super.initState();
    _fetchMarketData();
  }

  @override
  void dispose() {
    _deductionController.dispose();
    super.dispose();
  }

  Future<void> _fetchMarketData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await http
          .get(
            Uri.parse(_sourceUrl),
            headers: const {
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 '
                  '(KHTML, like Gecko) Chrome/154.0 Mobile Safari/537.36',
              'Accept':
                  'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
              'Accept-Language': 'bn-BD,bn;q=0.9,en-US;q=0.8,en;q=0.7',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Server status: ${response.statusCode}');
      }

      final document = parser.parse(response.body);

      final gold = <String, double>{};
      final silver = <String, double>{};

      /*
       * GoldR-এর বর্তমান page structure:
       *
       * প্রতি ভরি স্বর্ণের দাম
       * 22 Karat Gold
       * 21 Karat Gold
       * 18 Karat Gold
       *
       * আমরা শুধু প্রথম/main price column থেকে rate নিচ্ছি।
       *
       * GoldR-এর "পুরাতন বিক্রয় মূল্য" column ব্যবহার করছি না।
       */

      for (final table in document.querySelectorAll('table')) {
        final tableText = _cleanText(table.text);

        final rows = table.querySelectorAll('tr');

        if (rows.isEmpty) continue;

        // Gold প্রতি ভরি table শনাক্ত
        final isGoldVoriTable =
            tableText.contains('সোনার বাজার মূল্য') &&
            tableText.contains('প্রতি ভরি');

        // Silver প্রতি ভরি table শনাক্ত
        final isSilverVoriTable =
            (tableText.contains('রুপার দাম') ||
                tableText.contains('রূপার দাম') ||
                tableText.contains('চান্দি')) &&
            tableText.contains('প্রতি ভরি');

        if (!isGoldVoriTable && !isSilverVoriTable) {
          continue;
        }

        for (final row in rows) {
          final cells = row.querySelectorAll('th,td');

          if (cells.length < 2) continue;

          final label = _cleanText(cells.first.text);
          final normalizedLabel = label.toLowerCase();

          String? carat;

          if (normalizedLabel.contains('22')) {
            carat = '22';
          } else if (normalizedLabel.contains('21')) {
            carat = '21';
          } else if (normalizedLabel.contains('18')) {
            carat = '18';
          }

          if (carat == null) continue;

          /*
           * cells[1] = GoldR-এর মূল rate
           *
           * উদাহরণ:
           * ৳২৩০,৭৭২$1,872.92
           *
           * আমরা প্রথম টাকা/সংখ্যাটি নেব।
           */
          final value = _firstTakaNumber(cells[1].text);

          if (value == null) continue;

          if (isGoldVoriTable) {
            gold[carat] = value;
          } else if (isSilverVoriTable) {
            silver[carat] = value;
          }
        }
      }

      /*
       * যদি table structure সামান্য পরিবর্তন হয়,
       * তাহলে fallback parser ব্যবহার হবে।
       */
      if (gold.length < 3 || silver.length < 3) {
        _parseRowsFallback(document, gold, silver);
      }

      if (!mounted) return;

      if (gold.length < 3) {
        throw Exception(
          'GoldR থেকে 22K, 21K এবং 18K main gold rate সম্পূর্ণ পাওয়া যায়নি।',
        );
      }

      if (silver.length < 3) {
        throw Exception(
          'GoldR থেকে 22K, 21K এবং 18K silver rate সম্পূর্ণ পাওয়া যায়নি।',
        );
      }

      setState(() {
        _goldPerVori
          ..clear()
          ..addAll(gold);

        _silverPerVori
          ..clear()
          ..addAll(silver);

        _lastUpdated = DateTime.now();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'আজকের বাজারের rate আনা যায়নি। Internet connection এবং source site check করুন।';
      });
    }
  }

  void _parseRowsFallback(
    dynamic document,
    Map<String, double> gold,
    Map<String, double> silver,
  ) {
    for (final row in document.querySelectorAll('tr')) {
      final cells = row.querySelectorAll('th,td');

      if (cells.length < 2) continue;

      final label = _cleanText(cells.first.text);
      final normalizedLabel = label.toLowerCase();

      String? carat;

      if (normalizedLabel.contains('22')) {
        carat = '22';
      } else if (normalizedLabel.contains('21')) {
        carat = '21';
      } else if (normalizedLabel.contains('18')) {
        carat = '18';
      }

      if (carat == null) continue;

      final value = _firstTakaNumber(cells[1].text);

      if (value == null) continue;

      final parentText = _cleanText(row.parent?.text ?? '');

      final isGold =
          normalizedLabel.contains('gold') ||
          parentText.contains('সোনার বাজার মূল্য');

      final isSilver =
          normalizedLabel.contains('silver') ||
          normalizedLabel.contains('রুপা') ||
          normalizedLabel.contains('রূপা') ||
          normalizedLabel.contains('চান্দি');

      final isVori =
          parentText.contains('প্রতি ভরি') ||
          parentText.toLowerCase().contains('vori');

      if (!isVori) continue;

      if (isGold) {
        gold[carat] ??= value;
      } else if (isSilver) {
        silver[carat] ??= value;
      }
    }
  }

  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('\u00A0', ' ')
        .trim();
  }

  double? _firstTakaNumber(String text) {
    final normalized = _normalizeDigits(text)
        .replaceAll('৳', '')
        .replaceAll('Tk', '')
        .replaceAll('TK', '');

    /*
     * প্রথমে comma সহ number খুঁজে বের করি।
     *
     * যেমন:
     * 230,772
     * 220,391
     * 189,248
     */
    final matches =
        RegExp(r'\d[\d,]*(?:\.\d+)?').allMatches(normalized);

    for (final match in matches) {
      final raw = match.group(0)!.replaceAll(',', '');

      final value = double.tryParse(raw);

      if (value != null && value > 0) {
        return value;
      }
    }

    return null;
  }

  String _normalizeDigits(String value) {
    const bangla = '০১২৩৪৫৬৭৮৯';
    const english = '0123456789';

    var result = value;

    for (var i = 0; i < bangla.length; i++) {
      result = result.replaceAll(
        bangla[i],
        english[i],
      );
    }

    return result;
  }

  double get _deductionPercent {
    final value = double.tryParse(
      _normalizeDigits(
        _deductionController.text,
      ).replaceAll(',', '.'),
    );

    if (value == null) return 20;

    return value.clamp(0, 100);
  }

  double _unitRate(double perVori) {
    return perVori / _unitDivisors[_selectedUnit]!;
  }

  /*
   * পুরাতন সোনার দাম:
   *
   * Main GoldR price × (100 - deduction)% 
   *
   * Default deduction = 20%
   */
  double _oldGoldRate(double perVori) {
    return perVori * (1 - (_deductionPercent / 100));
  }

  String _money(double value) {
    final rounded = value.roundToDouble();

    final display = (value - rounded).abs() < 0.005
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);

    final parts = display.split('.');

    var integerPart = parts[0];

    final sign = integerPart.startsWith('-') ? '-' : '';

    integerPart = integerPart.replaceFirst('-', '');

    if (integerPart.length > 3) {
      final lastThree =
          integerPart.substring(integerPart.length - 3);

      var remaining =
          integerPart.substring(0, integerPart.length - 3);

      final chunks = <String>[];

      while (remaining.length > 2) {
        chunks.insert(
          0,
          remaining.substring(
            remaining.length - 2,
          ),
        );

        remaining =
            remaining.substring(0, remaining.length - 2);
      }

      if (remaining.isNotEmpty) {
        chunks.insert(0, remaining);
      }

      integerPart =
          '${chunks.join(',')},$lastThree';
    }

    final formatted =
        parts.length > 1 && parts[1] != '00'
            ? '$sign$integerPart.${parts[1]}'
            : '$sign$integerPart';

    return '৳${_toBanglaDigit(formatted)}';
  }

  String _toBanglaDigit(String input) {
    const english = [
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
    ];

    const bangla = [
      '০',
      '১',
      '২',
      '৩',
      '৪',
      '৫',
      '৬',
      '৭',
      '৮',
      '৯',
    ];

    var result = input;

    for (var i = 0; i < english.length; i++) {
      result = result.replaceAll(
        english[i],
        bangla[i],
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        title: const Text(
          'আজকের বাজার',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF8B0000),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                _isLoading ? null : _fetchMarketData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B0000),
              ),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
                  color: const Color(0xFF8B0000),
                  onRefresh: _fetchMarketData,
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      10,
                      12,
                      10,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        _buildUnitSelector(),

                        const SizedBox(height: 14),

                        _buildDeductionBox(),

                        const SizedBox(height: 10),

                        _buildGoldTable(),

                        const SizedBox(height: 16),

                        _buildSilverTable(),

                        const SizedBox(height: 12),

                        if (_lastUpdated != null)
                          Text(
                            'সর্বশেষ সফলভাবে আপডেট: '
                            '${_formatDateTime(_lastUpdated!)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                        const SizedBox(height: 4),

                        const Text(
                          'Main Rate Source: GoldR.org',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 52,
              color: Colors.grey,
            ),

            const SizedBox(height: 12),

            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _fetchMarketData,
              icon: const Icon(Icons.refresh),
              label: const Text('আবার চেষ্টা করুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF8B0000),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSelector() {
    const units = [
      ('ভরি', Color(0xFF7B1FA2), Colors.white),
      ('আনা', Color(0xFF1565C0), Colors.white),
      ('রতি', Color(0xFF00897B), Colors.white),
      ('পয়েন্ট', Color(0xFFE65100), Colors.white),
      ('গ্রাম', Color(0xFF2E7D32), Colors.white),
    ];

    return Row(
      children: units.map((item) {
        final selected =
            _selectedUnit == item.$1;

        return Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 2,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(8),
                onTap: () {
                  setState(() {
                    _selectedUnit = item.$1;
                  });
                },
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 180),
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.$2,
                    borderRadius:
                        BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? Colors.black87
                          : Colors.transparent,
                      width: selected ? 2 : 0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          selected ? .20 : .10,
                        ),
                        blurRadius:
                            selected ? 5 : 3,
                        offset:
                            const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.$1,
                      style: TextStyle(
                        color: item.$3,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeductionBox() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(10),
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
                fontSize: 14,
              ),
            ),
          ),

          SizedBox(
            width: 82,
            height: 42,
            child: TextField(
              controller:
                  _deductionController,
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
                fillColor:
                    const Color(0xFFFFF8E1),
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 7,
                ),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(8),
                ),
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoldTable() {
    return _buildTableCard(
      title: 'সোনার বাজার',
      header: const [
        'সোনার ক্যারেট',
        'মেইন বাজার মূল্য',
        'পুরাতন সোনার মূল্য',
      ],
      rows: _goldCarats.map((carat) {
        final base =
            _goldPerVori[carat]!;

        return [
          '$carat ক্যারেট',
          _money(_unitRate(base)),
          _money(
            _unitRate(
              _oldGoldRate(base),
            ),
          ),
        ];
      }).toList(),
      columnFlex: const [
        2,
        2,
        3,
      ],
    );
  }

  Widget _buildSilverTable() {
    return _buildTableCard(
      title: 'রূপার বাজার',
      header: const [
        'রূপার ক্যারেট',
        'রূপার দাম',
      ],
      rows: _silverCarats.map((carat) {
        final base =
            _silverPerVori[carat]!;

        return [
          '$carat ক্যারেট',
          _money(_unitRate(base)),
        ];
      }).toList(),
      columnFlex: const [
        2,
        3,
      ],
    );
  }

  Widget _buildTableCard({
    required String title,
    required List<String> header,
    required List<List<String>> rows,
    required List<int> columnFlex,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(
              vertical: 10,
            ),
            decoration:
                const BoxDecoration(
              color: Color(0xFF8B0000),
              borderRadius:
                  BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Text(
              title,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          Table(
            border:
                TableBorder.all(
              color:
                  const Color(0xFFD8D8D8),
              width: .8,
            ),
            columnWidths: {
              for (
                var i = 0;
                i < columnFlex.length;
                i++
              )
                i: FlexColumnWidth(
                  columnFlex[i].toDouble(),
                ),
            },
            children: [
              TableRow(
                decoration:
                    const BoxDecoration(
                  color:
                      Color(0xFFF0E6D8),
                ),
                children:
                    header.map((text) {
                  return _tableCell(
                    text,
                    bold: true,
                    fontSize: 11,
                  );
                }).toList(),
              ),

              ...rows.asMap()
                  .entries
                  .map((entry) {
                final index =
                    entry.key;

                final row =
                    entry.value;

                return TableRow(
                  decoration:
                      BoxDecoration(
                    color: index.isEven
                        ? Colors.white
                        : const Color(
                            0xFFFFFCF7,
                          ),
                  ),
                  children:
                      row.map((text) {
                    return _tableCell(
                      text,
                      bold: true,
                      fontSize: 12,
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableCell(
    String text, {
    bool bold = false,
    double fontSize = 12,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      child: Text(
        _toBanglaDigit(text),
        textAlign:
            TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: bold
              ? FontWeight.bold
              : FontWeight.normal,
          color: Colors.black87,
        ),
      ),
    );
  }

  String _formatDateTime(
    DateTime dateTime,
  ) {
    final d = dateTime.day
        .toString()
        .padLeft(2, '0');

    final m = dateTime.month
        .toString()
        .padLeft(2, '0');

    final y =
        dateTime.year.toString();

    final h = dateTime.hour % 12 == 0
        ? 12
        : dateTime.hour % 12;

    final min = dateTime.minute
        .toString()
        .padLeft(2, '0');

    final period =
        dateTime.hour >= 12
            ? 'PM'
            : 'AM';

    return '${_toBanglaDigit('$d/$m/$y')} '
        '${_toBanglaDigit('$h:$min')} $period';
  }
}
