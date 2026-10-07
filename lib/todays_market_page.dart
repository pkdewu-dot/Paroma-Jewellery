import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({super.key});

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  bool isLoading = true;
  String errorMessage = '';
  String lastUpdated = '';

  final Map<String, Map<String, String>> goldPrices = {};
  final Map<String, Map<String, String>> silverPrices = {};

  @override
  void initState() {
    super.initState();
    fetchMarketPrices();
  }

  Future<void> fetchMarketPrices() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
      goldPrices.clear();
      silverPrices.clear();
    });

    try {
      final response = await http.get(
        Uri.parse('https://www.goldr.org/'),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/120.0 Mobile Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'bn-BD,bn;q=0.9,en;q=0.8',
        },
      ).timeout(
        const Duration(seconds: 25),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Server response: ${response.statusCode}',
        );
      }

      final document = html_parser.parse(response.body);

      _readMarketTables(document);

      // GoldR-এর page থেকে "সর্বশেষ আপডেট" বের করার চেষ্টা
      final pageText = document.body?.text ?? '';

      final updateMatch = RegExp(
        r'সর্বশেষ আপডেট\s*[:ঃ]?\s*([^\n]+)',
        caseSensitive: false,
      ).firstMatch(pageText);

      if (updateMatch != null) {
        lastUpdated = updateMatch.group(1)?.trim() ?? '';
      }

      // যদি table parser-এ data পাওয়া না যায়,
      // তাহলে পুরো HTML/text থেকে fallback parser চালানো হবে।
      if (goldPrices.isEmpty) {
        _fallbackGoldParser(pageText);
      }

      if (silverPrices.isEmpty) {
        _fallbackSilverParser(pageText);
      }

      if (goldPrices.isEmpty && silverPrices.isEmpty) {
        throw Exception(
          'GoldR থেকে live market data পাওয়া যায়নি।',
        );
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'আজকের বাজারের তথ্য এখন পাওয়া যাচ্ছে না।\n\n'
            'ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';
      });
    }
  }

  void _readMarketTables(dom.Document document) {
    final tables = document.querySelectorAll('table');

    for (final table in tables) {
      final rows = table.querySelectorAll('tr');

      String unit = 'ভরি';

      final tableText = table.text;

      if (tableText.contains('প্রতি গ্রাম')) {
        unit = 'গ্রাম';
      } else if (tableText.contains('প্রতি ভরি')) {
        unit = 'ভরি';
      } else if (tableText.contains('প্রতি আনা')) {
        unit = 'আনা';
      } else if (tableText.contains('প্রতি রতি')) {
        unit = 'রতি';
      }

      for (final row in rows) {
        final cells = row.querySelectorAll('td');

        if (cells.length < 2) {
          continue;
        }

        final name = _normalize(cells[0].text);

        if (_isGoldName(name)) {
          final marketPrice = _extractPrice(
            cells[1].text,
          );

          String salePrice = '';

          if (cells.length >= 3) {
            salePrice = _extractPrice(
              cells[2].text,
            );
          }

          if (marketPrice.isNotEmpty) {
            final key = _goldKey(name);

            goldPrices[key] = {
              'price': marketPrice,
              'sale': salePrice,
              'unit': unit,
            };
          }
        }

        if (_isSilverName(name)) {
          final marketPrice = _extractPrice(
            cells[1].text,
          );

          if (marketPrice.isNotEmpty) {
            final key = _silverKey(name);

            silverPrices[key] = {
              'price': marketPrice,
              'unit': unit,
            };
          }
        }
      }
    }
  }

  bool _isGoldName(String name) {
    return name.contains('22 karat gold') ||
        name.contains('21 karat gold') ||
        name.contains('18 karat gold') ||
        name.contains('traditional');
  }

  bool _isSilverName(String name) {
    return name.contains('22 karat silver') ||
        name.contains('21 karat silver') ||
        name.contains('18 karat silver') ||
        name.contains('traditional');
  }

  String _goldKey(String name) {
    if (name.contains('22 karat gold')) {
      return '22K';
    }

    if (name.contains('21 karat gold')) {
      return '21K';
    }

    if (name.contains('18 karat gold')) {
      return '18K';
    }

    return 'Traditional';
  }

  String _silverKey(String name) {
    if (name.contains('22 karat silver')) {
      return '22K';
    }

    if (name.contains('21 karat silver')) {
      return '21K';
    }

    if (name.contains('18 karat silver')) {
      return '18K';
    }

    return 'Traditional';
  }

  String _normalize(String value) {
    return value
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }

  String _extractPrice(String value) {
    if (value.trim().isEmpty) {
      return '';
    }

    String text = value;

    // Bangla number → English number
    const banglaDigits = '০১২৩৪৫৬৭৮৯';
    const englishDigits = '0123456789';

    for (int i = 0; i < banglaDigits.length; i++) {
      text = text.replaceAll(
        banglaDigits[i],
        englishDigits[i],
      );
    }

    // প্রথম ৳-এর পরের টাকা বের করার চেষ্টা
    final takaMatch = RegExp(
      r'৳\s*([0-9,]+)',
    ).firstMatch(text);

    if (takaMatch != null) {
      return takaMatch.group(1) ?? '';
    }

    // ৳ না থাকলে প্রথম বড় number
    final numberMatch = RegExp(
      r'([0-9]{2,}(?:,[0-9]{3})*)',
    ).firstMatch(text);

    if (numberMatch != null) {
      return numberMatch.group(1) ?? '';
    }

    return '';
  }

  void _fallbackGoldParser(String text) {
    final normalized = text
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');

    _fallbackGoldRow(
      normalized,
      '22 Karat Gold',
      '22K',
    );

    _fallbackGoldRow(
      normalized,
      '21 Karat Gold',
      '21K',
    );

    _fallbackGoldRow(
      normalized,
      '18 Karat Gold',
      '18K',
    );

    _fallbackGoldRow(
      normalized,
      'Traditional',
      'Traditional',
    );
  }

  void _fallbackGoldRow(
    String text,
    String searchName,
    String key,
  ) {
    final index = text.toLowerCase().indexOf(
          searchName.toLowerCase(),
        );

    if (index == -1) {
      return;
    }

    final end = index + 180;

    final section = text.substring(
      index,
      end > text.length ? text.length : end,
    );

    final prices = RegExp(
      r'৳\s*([০-৯0-9,]+)',
    ).allMatches(section);

    final found = <String>[];

    for (final match in prices) {
      final price = match.group(1);

      if (price != null) {
        found.add(_convertDigits(price));
      }
    }

    if (found.isNotEmpty) {
      goldPrices[key] = {
        'price': found[0],
        'sale': found.length > 1 ? found[1] : '',
        'unit': 'ভরি',
      };
    }
  }

  void _fallbackSilverParser(String text) {
    final normalized = text
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');

    _fallbackSilverRow(
      normalized,
      '22 Karat Silver',
      '22K',
    );

    _fallbackSilverRow(
      normalized,
      '21 Karat Silver',
      '21K',
    );

    _fallbackSilverRow(
      normalized,
      '18 Karat Silver',
      '18K',
    );
  }

  void _fallbackSilverRow(
    String text,
    String searchName,
    String key,
  ) {
    final index = text.toLowerCase().indexOf(
          searchName.toLowerCase(),
        );

    if (index == -1) {
      return;
    }

    final end = index + 120;

    final section = text.substring(
      index,
      end > text.length ? text.length : end,
    );

    final prices = RegExp(
      r'৳\s*([০-৯0-9,]+)',
    ).allMatches(section);

    for (final match in prices) {
      final price = match.group(1);

      if (price != null) {
        silverPrices[key] = {
          'price': _convertDigits(price),
          'unit': 'ভরি',
        };

        break;
      }
    }
  }

  String _convertDigits(String value) {
    const banglaDigits = '০১২৩৪৫৬৭৮৯';
    const englishDigits = '0123456789';

    String result = value;

    for (int i = 0; i < banglaDigits.length; i++) {
      result = result.replaceAll(
        banglaDigits[i],
        englishDigits[i],
      );
    }

    return result;
  }

  String _banglaDigits(String value) {
    const englishDigits = '0123456789';
    const banglaDigits = '০১২৩৪৫৬৭৮৯';

    String result = value;

    for (int i = 0; i < englishDigits.length; i++) {
      result = result.replaceAll(
        englishDigits[i],
        banglaDigits[i],
      );
    }

    return result;
  }

  String _displayPrice(String value) {
    if (value.isEmpty) {
      return 'তথ্য নেই';
    }

    return '৳ ${_banglaDigits(value)}';
  }

  Widget _priceCard({
    required String title,
    required String unit,
    required String price,
    String sale = '',
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'প্রতি $unit',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _displayPrice(price),
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                if (sale.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'পুরাতন বিক্রয় মূল্য: ${_displayPrice(sale)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 12,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF8B6508),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B0000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketContent() {
    const goldOrder = [
      '22K',
      '21K',
      '18K',
      'Traditional',
    ];

    const silverOrder = [
      '22K',
      '21K',
      '18K',
      'Traditional',
    ];

    return RefreshIndicator(
      onRefresh: fetchMarketPrices,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6B0000),
                  Color(0xFF9E1B1B),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.storefront,
                  color: Color(0xFFFFD700),
                  size: 38,
                ),
                SizedBox(height: 7),
                Text(
                  'আজকের বাজার',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'সর্বশেষ সোনা ও রুপার বাজার দর',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          _sectionTitle(
            'সোনার দাম',
            Icons.auto_awesome,
          ),

          ...goldOrder.map((key) {
            final data = goldPrices[key];

            final title = key == 'Traditional'
                ? 'সনাতন সোনা'
                : '$key সোনা';

            return _priceCard(
              title: title,
              unit: data?['unit'] ?? 'ভরি',
              price: data?['price'] ?? '',
              sale: data?['sale'] ?? '',
              icon: Icons.workspace_premium,
              iconColor: Colors.amber.shade800,
            );
          }),

          const SizedBox(height: 8),

          _sectionTitle(
            'রুপার দাম',
            Icons.circle_outlined,
          ),

          ...silverOrder.map((key) {
            final data = silverPrices[key];

            final title = key == 'Traditional'
                ? 'সনাতন রুপা'
                : '$key রুপা';

            return _priceCard(
              title: title,
              unit: data?['unit'] ?? 'ভরি',
              price: data?['price'] ?? '',
              icon: Icons.circle_outlined,
              iconColor: Colors.blueGrey,
            );
          }),

          const SizedBox(height: 12),

          if (lastUpdated.isNotEmpty)
            Text(
              'সর্বশেষ আপডেট: $lastUpdated',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),

          const SizedBox(height: 8),

          const Text(
            'তথ্যসূত্র: GoldR.org',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black45,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'আজকের বাজার',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFF3B30),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text(
                    'আজকের বাজারের দাম লোড হচ্ছে...',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 65,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: fetchMarketPrices,
                          icon: const Icon(Icons.refresh),
                          label: const Text(
                            'আবার চেষ্টা করুন',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildMarketContent(),
    );
  }
}
