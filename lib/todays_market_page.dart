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

  String updateText = '';

  final Map<String, Map<String, String>> goldPrices = {};
  final Map<String, Map<String, String>> silverPrices = {};

  @override
  void initState() {
    super.initState();
    _loadMarketData();
  }

  Future<void> _loadMarketData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
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
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception(
          'Server response: ${response.statusCode}',
        );
      }

      final document = html_parser.parse(response.body);

      _clearData();

      _parseTables(document);

      if (_hasAnyGoldData() || _hasAnySilverData()) {
        final pageText = document.body?.text ?? '';

        final updateMatch = RegExp(
          r'সর্বশেষ আপডেট\s*[:ঃ]?\s*([^\n]+)',
        ).firstMatch(pageText);

        if (updateMatch != null) {
          updateText = updateMatch.group(1)?.trim() ?? '';
        }

        if (!mounted) return;

        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception(
          'GoldR থেকে বাজারের দামের তথ্য পাওয়া যায়নি।',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'আজকের বাজারের তথ্য লোড করা যাচ্ছে না।\n\n'
            'ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';
      });
    }
  }

  void _clearData() {
    goldPrices.clear();
    silverPrices.clear();
    updateText = '';
  }

  bool _hasAnyGoldData() {
    return goldPrices.isNotEmpty;
  }

  bool _hasAnySilverData() {
    return silverPrices.isNotEmpty;
  }

  void _parseTables(dom.Document document) {
    final tables = document.querySelectorAll('table');

    for (final table in tables) {
      final tableText = table.text.toLowerCase();

      final rows = table.querySelectorAll('tr');

      bool isGoldTable = false;
      bool isSilverTable = false;

      for (final row in rows) {
        final text = row.text.trim();

        if (text.contains('22 Karat Gold') ||
            text.contains('21 Karat Gold') ||
            text.contains('18 Karat Gold') ||
            text.contains('Traditional')) {
          isGoldTable = true;
        }

        if (text.contains('22 Karat Silver') ||
            text.contains('21 Karat Silver') ||
            text.contains('18 Karat Silver')) {
          isSilverTable = true;
        }
      }

      if (tableText.contains('gold type') &&
          !tableText.contains('silver type')) {
        isGoldTable = true;
      }

      if (tableText.contains('silver type')) {
        isSilverTable = true;
      }

      String unit = _detectUnit(table);

      if (isGoldTable) {
        _parseGoldRows(rows, unit);
      }

      if (isSilverTable) {
        _parseSilverRows(rows, unit);
      }
    }
  }

  String _detectUnit(dom.Element table) {
    String surroundingText = '';

    dom.Element? current = table;

    for (int i = 0; i < 4; i++) {
      if (current == null) break;

      surroundingText =
          '${current.text} $surroundingText'.toLowerCase();

      current = current.parent;
    }

    if (surroundingText.contains('প্রতি ভরি')) {
      return 'ভরি';
    }

    if (surroundingText.contains('প্রতি আনা')) {
      return 'আনা';
    }

    if (surroundingText.contains('প্রতি রতি')) {
      return 'রতি';
    }

    if (surroundingText.contains('প্রতি গ্রাম')) {
      return 'গ্রাম';
    }

    return 'ভরি';
  }

  void _parseGoldRows(
    List<dom.Element> rows,
    String unit,
  ) {
    for (final row in rows) {
      final cells = row.querySelectorAll('td');

      if (cells.length < 2) continue;

      final name = cells[0].text.trim();

      if (!name.contains('Gold') &&
          name != 'Traditional') {
        continue;
      }

      final price = _cleanPrice(cells[1].text);
      String salePrice = '';

      if (cells.length >= 3) {
        salePrice = _cleanPrice(cells[2].text);
      }

      if (price.isEmpty) continue;

      String key;

      if (name.contains('22 Karat')) {
        key = '22K';
      } else if (name.contains('21 Karat')) {
        key = '21K';
      } else if (name.contains('18 Karat')) {
        key = '18K';
      } else if (name.contains('Traditional')) {
        key = 'Traditional';
      } else {
        continue;
      }

      goldPrices[key] = {
        'unit': unit,
        'price': price,
        'sale': salePrice,
      };
    }
  }

  void _parseSilverRows(
    List<dom.Element> rows,
    String unit,
  ) {
    for (final row in rows) {
      final cells = row.querySelectorAll('td');

      if (cells.length < 2) continue;

      final name = cells[0].text.trim();

      if (!name.contains('Silver')) continue;

      final price = _cleanPrice(cells[1].text);

      if (price.isEmpty) continue;

      String key;

      if (name.contains('22 Karat')) {
        key = '22K';
      } else if (name.contains('21 Karat')) {
        key = '21K';
      } else if (name.contains('18 Karat')) {
        key = '18K';
      } else if (name.contains('Traditional')) {
        key = 'Traditional';
      } else {
        continue;
      }

      silverPrices[key] = {
        'unit': unit,
        'price': price,
      };
    }
  }

  String _cleanPrice(String text) {
    String value = text.trim();

    value = value.replaceAll('\n', ' ');
    value = value.replaceAll('\r', ' ');

    final match = RegExp(
      r'[৳]?\s*([0-9০-৯,]+)',
    ).firstMatch(value);

    if (match == null) return '';

    return match.group(1) ?? '';
  }

  String _banglaDigits(String text) {
    const english = '0123456789';
    const bangla = '০১২৩৪৫৬৭৮৯';

    String result = text;

    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(
        english[i],
        bangla[i],
      );
    }

    return result;
  }

  String _priceText(String price) {
    if (price.isEmpty) return 'তথ্য নেই';

    return '৳ ${_banglaDigits(price)}';
  }

  Widget _buildPriceCard({
    required String title,
    required String subtitle,
    required String price,
    String? salePrice,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _priceText(price),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (salePrice != null &&
                    salePrice.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    'পুরাতন বিক্রয়: ${_priceText(salePrice)}',
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

  Widget _buildSectionTitle(
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
            size: 25,
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

  Widget _buildContent() {
    final goldOrder = [
      '22K',
      '21K',
      '18K',
      'Traditional',
    ];

    final silverOrder = [
      '22K',
      '21K',
      '18K',
      'Traditional',
    ];

    return RefreshIndicator(
      onRefresh: _loadMarketData,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6B0000),
                  Color(0xFF9E1B1B),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.storefront,
                  color: Color(0xFFFFD700),
                  size: 36,
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
                  'সর্বশেষ বাজার দর',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          _buildSectionTitle(
            'সোনার দাম',
            Icons.auto_awesome,
          ),

          ...goldOrder.map((key) {
            final item = goldPrices[key];

            if (item == null) {
              return _buildPriceCard(
                title: key == 'Traditional'
                    ? 'সনাতন'
                    : '$key সোনা',
                subtitle: 'প্রতি ভরি',
                price: '',
                color: Colors.amber.shade800,
              );
            }

            return _buildPriceCard(
              title: key == 'Traditional'
                  ? 'সনাতন'
                  : '$key সোনা',
              subtitle:
                  'প্রতি ${item['unit'] ?? 'ভরি'}',
              price: item['price'] ?? '',
              salePrice: item['sale'],
              color: Colors.amber.shade800,
            );
          }),

          const SizedBox(height: 8),

          _buildSectionTitle(
            'রুপার দাম',
            Icons.circle_outlined,
          ),

          ...silverOrder.map((key) {
            final item = silverPrices[key];

            if (item == null) {
              return _buildPriceCard(
                title: key == 'Traditional'
                    ? 'সনাতন রুপা'
                    : '$key রুপা',
                subtitle: 'প্রতি ভরি',
                price: '',
                color: Colors.blueGrey,
              );
            }

            return _buildPriceCard(
              title: key == 'Traditional'
                  ? 'সনাতন রুপা'
                  : '$key রুপা',
              subtitle:
                  'প্রতি ${item['unit'] ?? 'ভরি'}',
              price: item['price'] ?? '',
              color: Colors.blueGrey,
            );
          }),

          const SizedBox(height: 10),

          if (updateText.isNotEmpty)
            Center(
              child: Text(
                'সর্বশেষ আপডেট: $updateText',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ),

          const SizedBox(height: 15),

          const Center(
            child: Text(
              'তথ্য: GoldR.org',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 11,
              ),
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
                  SizedBox(height: 16),
                  Text(
                    'আজকের বাজারের দাম লোড হচ্ছে...',
                    style: TextStyle(
                      fontSize: 15,
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
                          color: Colors.red,
                          size: 65,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _loadMarketData,
                          icon: const Icon(
                            Icons.refresh,
                          ),
                          label: const Text(
                            'আবার চেষ্টা করুন',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(),
    );
  }
}
