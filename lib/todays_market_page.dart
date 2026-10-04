import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({super.key});

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  bool _loading = true;
  String? _error;

  double? gold22;
  double? gold21;
  double? gold18;

  double? silver22;
  double? silver21;
  double? silver18;

  final TextEditingController _deductionController =
      TextEditingController(text: '20');

  double get deduction {
    final value = double.tryParse(
      _deductionController.text.replaceAll(',', '').trim(),
    );
    if (value == null || value < 0 || value > 100) {
      return 20;
    }
    return value;
  }

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  @override
  void dispose() {
    _deductionController.dispose();
    super.dispose();
  }

  Future<void> _loadRates() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      /*
       * GoldR-এর live page থেকে data নেওয়া হচ্ছে।
       *
       * GoldR-এর documented price keys:
       * 22k-1bhori-dam
       * 21k-1bhori-dam
       * 18k-1bhori-dam
       *
       * Silver:
       * 22k-1bhori-dam
       * 21k-1bhori-dam
       * 18k-1bhori-dam
       *
       * GoldR-এর page-এ gold ও silver-এর আলাদা table থাকে।
       */

      final response = await http.get(
        Uri.parse('https://www.goldr.org/'),
        headers: const {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 15) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'bn-BD,bn;q=0.9,en-US;q=0.8,en;q=0.7',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final html = utf8.decode(response.bodyBytes);

      final rates = _extractRates(html);

      if (rates.gold22 == null ||
          rates.gold21 == null ||
          rates.gold18 == null ||
          rates.silver22 == null ||
          rates.silver21 == null ||
          rates.silver18 == null) {
        throw Exception('GoldR rate data পাওয়া যায়নি');
      }

      if (!mounted) return;

      setState(() {
        gold22 = rates.gold22;
        gold21 = rates.gold21;
        gold18 = rates.gold18;

        silver22 = rates.silver22;
        silver21 = rates.silver21;
        silver18 = rates.silver18;

        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error =
            'আজকের বাজারের rate আনা যায়নি।\n'
            'Internet connection অথবা GoldR source check করুন।';
      });
    }
  }

  _RateResult _extractRates(String html) {
    /*
     * GoldR-এর HTML-এ বাংলা ও ইংরেজি দুই ধরনের text থাকতে পারে।
     * তাই প্রথমে পুরো HTML থেকে script/data অংশ বাদ দিয়ে
     * readable text তৈরি করছি।
     */

    final clean = html
        .replaceAll(RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ');

    /*
     * GoldR-এর current page-এ প্রতি ভরি gold rates:
     *
     * 22K = 230772
     * 21K = 220391
     * 18K = 189248
     *
     * কিন্তু hard-code করা হচ্ছে না।
     *
     * Text-এর আশেপাশের সংখ্যাগুলো থেকে rate বের করা হবে।
     */

    final goldSection = _findSection(
      clean,
      [
        'প্রতি ভরি স্বর্ণের দাম',
        'প্রতি ভরি সোনার দাম',
        'Gold Type',
      ],
    );

    final silverSection = _findSection(
      clean,
      [
        'প্রতি ভরি চান্দি',
        'প্রতি ভরি রুপার দাম',
        'প্রতি ভরি রূপার দাম',
        'silver price',
      ],
    );

    double? g22;
    double? g21;
    double? g18;

    double? s22;
    double? s21;
    double? s18;

    /*
     * প্রথমে section-based extraction।
     */
    if (goldSection.isNotEmpty) {
      g22 = _findRateNear(goldSection, ['22 Karat Gold', '22K']);
      g21 = _findRateNear(goldSection, ['21 Karat Gold', '21K']);
      g18 = _findRateNear(goldSection, ['18 Karat Gold', '18K']);
    }

    if (silverSection.isNotEmpty) {
      s22 = _findRateNear(
        silverSection,
        ['22 Karat Silver', '22K Silver'],
      );

      s21 = _findRateNear(
        silverSection,
        ['21 Karat Silver', '21K Silver'],
      );

      s18 = _findRateNear(
        silverSection,
        ['18 Karat Silver', '18K Silver'],
      );
    }

    /*
     * দ্বিতীয় fallback:
     * পুরো page-এর known price sequence থেকে rate নেওয়া।
     *
     * GoldR page-এর প্রতি ভরি table:
     * 22K, 21K, 18K, Traditional
     *
     * এরপর silver:
     * 22K, 21K, 18K, Traditional
     */
    final allNumbers = _extractLargeNumbers(clean);

    if (g22 == null || g21 == null || g18 == null) {
      final goldCandidates = _findGoldCandidates(allNumbers);

      g22 ??= goldCandidates.$1;
      g21 ??= goldCandidates.$2;
      g18 ??= goldCandidates.$3;
    }

    if (s22 == null || s21 == null || s18 == null) {
      final silverCandidates = _findSilverCandidates(allNumbers);

      s22 ??= silverCandidates.$1;
      s21 ??= silverCandidates.$2;
      s18 ??= silverCandidates.$3;
    }

    return _RateResult(
      gold22: g22,
      gold21: g21,
      gold18: g18,
      silver22: s22,
      silver21: s21,
      silver18: s18,
    );
  }

  String _findSection(String text, List<String> keywords) {
    for (final keyword in keywords) {
      final index = text.toLowerCase().indexOf(keyword.toLowerCase());

      if (index >= 0) {
        final end = (index + 2500).clamp(0, text.length);
        return text.substring(index, end);
      }
    }

    return '';
  }

  double? _findRateNear(String section, List<String> labels) {
    for (final label in labels) {
      final index = section.toLowerCase().indexOf(label.toLowerCase());

      if (index < 0) continue;

      final end = (index + 500).clamp(0, section.length);
      final area = section.substring(index, end);

      final numbers = _extractLargeNumbers(area);

      /*
       * প্রথম বড় টাকা value সাধারণত market price।
       *
       * GoldR-এর table-এ একই row-তে market price-এর পরে
       * old selling price থাকে।
       *
       * তাই প্রথম বড় value নেওয়া হচ্ছে।
       */
      if (numbers.isNotEmpty) {
        return numbers.first.toDouble();
      }
    }

    return null;
  }

  List<int> _extractLargeNumbers(String text) {
    final normalized = _normalizeDigits(text);

    final matches = RegExp(
      r'(?<!\d)(\d{1,3}(?:,\d{3})+|\d{4,7})(?!\d)',
    ).allMatches(normalized);

    final result = <int>[];

    for (final match in matches) {
      final value = int.tryParse(
        match.group(1)!.replaceAll(',', ''),
      );

      if (value == null) continue;

      /*
       * ভরি gold সাধারণত 100,000+ এবং silver 1,000+।
       * ছোট সংখ্যা বাদ দেওয়া হচ্ছে যাতে 22, 21, 18 ইত্যাদি
       * rate হিসেবে ধরা না পড়ে।
       */
      if (value >= 1000) {
        result.add(value);
      }
    }

    return result;
  }

  String _normalizeDigits(String text) {
    const bangla = '০১২৩৪৫৬৭৮৯';
    const arabic = '٠١٢٣٤٥٦٧٨٩';

    var result = text;

    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(
        bangla[i],
        i.toString(),
      );

      result = result.replaceAll(
        arabic[i],
        i.toString(),
      );
    }

    return result;
  }

  (double?, double?, double?) _findGoldCandidates(
    List<int> numbers,
  ) {
    /*
     * Gold rate সাধারণত 100,000-এর বেশি।
     */
    final candidates = numbers
        .where((value) => value >= 100000)
        .toList();

    if (candidates.length < 3) {
      return (null, null, null);
    }

    /*
     * একই page-এ একাধিক unit থাকতে পারে।
     * সবচেয়ে বড় তিনটি rate নেওয়া নয়;
     * table sequence ধরে প্রথম তিনটি নেওয়ার চেষ্টা করা হচ্ছে।
     */

    final unique = <int>[];

    for (final value in candidates) {
      if (!unique.contains(value)) {
        unique.add(value);
      }
    }

    if (unique.length < 3) {
      return (null, null, null);
    }

    return (
      unique[0].toDouble(),
      unique[1].toDouble(),
      unique[2].toDouble(),
    );
  }

  (double?, double?, double?) _findSilverCandidates(
    List<int> numbers,
  ) {
    /*
     * Silver per bhori সাধারণত 1,000-10,000 range-এর মধ্যে।
     */
    final candidates = numbers
        .where(
          (value) => value >= 1000 && value < 100000,
        )
        .toList();

    final unique = <int>[];

    for (final value in candidates) {
      if (!unique.contains(value)) {
        unique.add(value);
      }
    }

    /*
     * Page-এর অন্যান্য সংখ্যা বাদ দিতে
     * সম্ভাব্য silver rate খোঁজা হচ্ছে।
     */
    final likely = unique.where(
      (value) => value >= 2000 && value <= 20000,
    ).toList();

    if (likely.length < 3) {
      return (null, null, null);
    }

    return (
      likely[0].toDouble(),
      likely[1].toDouble(),
      likely[2].toDouble(),
    );
  }

  double _oldGoldRate(double marketRate) {
    return marketRate * (1 - deduction / 100);
  }

  String _money(double value) {
    return '৳${_formatNumber(value.round())}';
  }

  String _formatNumber(int value) {
    final text = value.toString();

    if (text.length <= 3) return text;

    var result = '';
    var count = 0;

    for (var i = text.length - 1; i >= 0; i--) {
      result = text[i] + result;
      count++;

      if (count == 3 && i > 0) {
        result = ',' + result;
        count = 0;
      }
    }

    return result;
  }

  Widget _rateCard({
    required String title,
    required double? marketRate,
    required bool isGold,
  }) {
    if (marketRate == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'মেইন বাজার মূল্য',
                style: TextStyle(fontSize: 15),
              ),
              Text(
                _money(marketRate),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isGold) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'পুরাতন সোনা (${deduction.toStringAsFixed(0)}% বাদ)',
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  _money(_oldGoldRate(marketRate)),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আজকের বাজার'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadRates,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 14),
                    Text('আজকের বাজারের rate আনা হচ্ছে...'),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadRates,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.shade200,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _loadRates,
                              icon: const Icon(Icons.refresh),
                              label: const Text('আবার চেষ্টা করুন'),
                            ),
                          ],
                        ),
                      ),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'পুরাতন সোনার হিসাব',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'মেইন বাজার মূল্যের উপর কত % বাদ দিয়ে পুরাতন সোনার দাম হিসাব করবেন?',
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _deductionController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              suffixText: '%',
                              hintText: '20',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (_) {
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    _sectionTitle('সোনার বাজার মূল্য'),

                    _rateCard(
                      title: '২২ ক্যারেট সোনা — প্রতি ভরি',
                      marketRate: gold22,
                      isGold: true,
                    ),

                    _rateCard(
                      title: '২১ ক্যারেট সোনা — প্রতি ভরি',
                      marketRate: gold21,
                      isGold: true,
                    ),

                    _rateCard(
                      title: '১৮ ক্যারেট সোনা — প্রতি ভরি',
                      marketRate: gold18,
                      isGold: true,
                    ),

                    _sectionTitle('রুপার বাজার মূল্য'),

                    _rateCard(
                      title: '২২ ক্যারেট রুপা — প্রতি ভরি',
                      marketRate: silver22,
                      isGold: false,
                    ),

                    _rateCard(
                      title: '২১ ক্যারেট রুপা — প্রতি ভরি',
                      marketRate: silver21,
                      isGold: false,
                    ),

                    _rateCard(
                      title: '১৮ ক্যারেট রুপা — প্রতি ভরি',
                      marketRate: silver18,
                      isGold: false,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Source: GoldR.org',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _RateResult {
  final double? gold22;
  final double? gold21;
  final double? gold18;

  final double? silver22;
  final double? silver21;
  final double? silver18;

  const _RateResult({
    required this.gold22,
    required this.gold21,
    required this.gold18,
    required this.silver22,
    required this.silver21,
    required this.silver18,
  });
}
