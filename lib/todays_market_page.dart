import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({super.key});

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  static const double gramsPerBhori = 11.664;
  static const double anaPerBhori = 16.0;
  static const double rotiPerBhori = 96.0;

  bool isLoading = true;
  String errorMessage = '';
  String lastUpdated = '';
  bool showingCachedData = false;

  double gold22 = 0;
  double gold21 = 0;
  double gold18 = 0;

  double silver22 = 0;
  double silver21 = 0;
  double silver18 = 0;

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  // ============================================================
  // MAIN LOAD LOGIC
  // ============================================================

  Future<void> _loadPrices({
    bool forceRefresh = false,
  }) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
      showingCachedData = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final today = _todayKey();
      final savedDate =
          prefs.getString('market_saved_date') ?? '';

      // --------------------------------------------------------
      // যদি আজকের data already save করা থাকে,
      // তাহলে আবার internet request করার দরকার নেই।
      // --------------------------------------------------------

      if (!forceRefresh &&
          savedDate == today &&
          prefs.containsKey('gold22')) {
        _loadSavedData(prefs);

        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      // --------------------------------------------------------
      // আজকের data নেই → API থেকে fetch
      // --------------------------------------------------------

      await _fetchFreshPrices(prefs);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      // --------------------------------------------------------
      // API কাজ না করলে আগের saved data দেখাবে
      // --------------------------------------------------------

      final prefs = await SharedPreferences.getInstance();

      if (prefs.containsKey('gold22')) {
        _loadSavedData(prefs);

        if (!mounted) return;

        setState(() {
          isLoading = false;
          showingCachedData = true;
          errorMessage =
              'নতুন বাজার দর পাওয়া যায়নি।\n'
              'সর্বশেষ সংরক্ষিত দর দেখানো হচ্ছে।';
        });

        return;
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'আজকের বাজারের তথ্য পাওয়া যাচ্ছে না।\n\n'
            'ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';
      });
    }
  }

  // ============================================================
  // FETCH GOLD + SILVER
  // ============================================================

  Future<void> _fetchFreshPrices(
    SharedPreferences prefs,
  ) async {
    final goldResponse = await http
        .get(
          Uri.parse(
            'https://gold-price.bd/api/gold/latest.json',
          ),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    final silverResponse = await http
        .get(
          Uri.parse(
            'https://gold-price.bd/api/silver/latest.json',
          ),
        )
        .timeout(
          const Duration(seconds: 15),
        );

    if (goldResponse.statusCode != 200) {
      throw Exception(
        'Gold API error: ${goldResponse.statusCode}',
      );
    }

    if (silverResponse.statusCode != 200) {
      throw Exception(
        'Silver API error: ${silverResponse.statusCode}',
      );
    }

    final goldJson =
        jsonDecode(goldResponse.body);

    final silverJson =
        jsonDecode(silverResponse.body);

    final goldLatest =
        goldJson['latest'] as Map<String, dynamic>?;

    final silverLatest =
        silverJson['latest'] as Map<String, dynamic>?;

    if (goldLatest == null) {
      throw Exception(
        'Gold price data পাওয়া যায়নি',
      );
    }

    if (silverLatest == null) {
      throw Exception(
        'Silver price data পাওয়া যায়নি',
      );
    }

    final newGold22 =
        _toDouble(goldLatest['k22']);

    final newGold21 =
        _toDouble(goldLatest['k21']);

    final newGold18 =
        _toDouble(goldLatest['k18']);

    final newSilver22 =
        _toDouble(silverLatest['k22']);

    final newSilver21 =
        _toDouble(silverLatest['k21']);

    final newSilver18 =
        _toDouble(silverLatest['k18']);

    if (newGold22 <= 0 ||
        newGold21 <= 0 ||
        newGold18 <= 0) {
      throw Exception(
        'Gold price invalid',
      );
    }

    if (newSilver22 <= 0 ||
        newSilver21 <= 0 ||
        newSilver18 <= 0) {
      throw Exception(
        'Silver price invalid',
      );
    }

    // API rate = per gram
    // আমরা per gram হিসেবেই save করছি।

    gold22 = newGold22;
    gold21 = newGold21;
    gold18 = newGold18;

    silver22 = newSilver22;
    silver21 = newSilver21;
    silver18 = newSilver18;

    lastUpdated =
        goldJson['lastUpdate']?.toString() ?? '';

    if (lastUpdated.isEmpty) {
      lastUpdated =
          silverJson['lastUpdate']?.toString() ?? '';
    }

    // --------------------------------------------------------
    // Save locally
    // --------------------------------------------------------

    await prefs.setDouble(
      'gold22',
      gold22,
    );

    await prefs.setDouble(
      'gold21',
      gold21,
    );

    await prefs.setDouble(
      'gold18',
      gold18,
    );

    await prefs.setDouble(
      'silver22',
      silver22,
    );

    await prefs.setDouble(
      'silver21',
      silver21,
    );

    await prefs.setDouble(
      'silver18',
      silver18,
    );

    await prefs.setString(
      'market_saved_date',
      _todayKey(),
    );

    await prefs.setString(
      'market_last_updated',
      lastUpdated,
    );
  }

  // ============================================================
  // LOAD SAVED DATA
  // ============================================================

  void _loadSavedData(
    SharedPreferences prefs,
  ) {
    gold22 = prefs.getDouble('gold22') ?? 0;
    gold21 = prefs.getDouble('gold21') ?? 0;
    gold18 = prefs.getDouble('gold18') ?? 0;

    silver22 =
        prefs.getDouble('silver22') ?? 0;
    silver21 =
        prefs.getDouble('silver21') ?? 0;
    silver18 =
        prefs.getDouble('silver18') ?? 0;

    lastUpdated =
        prefs.getString('market_last_updated') ?? '';
  }

  // ============================================================
  // HELPERS
  // ============================================================

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  String _todayKey() {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // CONVERSIONS
  // ============================================================

  double _perBhori(double perGram) {
    return perGram * gramsPerBhori;
  }

  double _perAna(double perBhori) {
    return perBhori / anaPerBhori;
  }

  double _perRoti(double perBhori) {
    return perBhori / rotiPerBhori;
  }

  double _perGram(double perGram) {
    return perGram;
  }

  // Old gold = 18% deduction
  double _oldGold(double currentPrice) {
    return currentPrice * 0.82;
  }

  // ============================================================
  // FORMAT
  // ============================================================

  String _formatMoney(
    double value, {
    bool decimal = false,
  }) {
    if (value <= 0) {
      return 'তথ্য নেই';
    }

    String text;

    if (decimal) {
      text = value.toStringAsFixed(2);
    } else {
      text = value.round().toString();
    }

    text = _addComma(text);

    return '৳ ${_banglaDigits(text)}';
  }

  String _addComma(String value) {
    final parts = value.split('.');

    String integerPart = parts[0];

    final isNegative =
        integerPart.startsWith('-');

    if (isNegative) {
      integerPart =
          integerPart.substring(1);
    }

    final buffer = StringBuffer();

    for (int i = 0;
        i < integerPart.length;
        i++) {
      if (i > 0 &&
          (integerPart.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(integerPart[i]);
    }

    String result = buffer.toString();

    if (isNegative) {
      result = '-$result';
    }

    if (parts.length > 1) {
      result += '.${parts[1]}';
    }

    return result;
  }

  String _banglaDigits(String value) {
    const english = '0123456789';
    const bangla = '০১২৩৪৫৬৭৮৯';

    String result = value;

    for (int i = 0;
        i < english.length;
        i++) {
      result = result.replaceAll(
        english[i],
        bangla[i],
      );
    }

    return result;
  }

  // ============================================================
  // PRICE CARD
  // ============================================================

  Widget _priceCard({
    required String title,
    required double perGram,
    required Color color,
    required IconData icon,
    bool showOldGold = false,
  }) {
    final bhori = _perBhori(perGram);
    final ana = _perAna(bhori);
    final roti = _perRoti(bhori);
    final gram = _perGram(perGram);

    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(bottom: 12),
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          _priceRow(
            'প্রতি ভরি',
            _formatMoney(bhori),
            true,
          ),

          _priceRow(
            'প্রতি আনা',
            _formatMoney(ana),
            false,
          ),

          _priceRow(
            'প্রতি রতি',
            _formatMoney(roti),
            false,
          ),

          _priceRow(
            'প্রতি গ্রাম',
            _formatMoney(gram),
            false,
          ),

          if (showOldGold) ...[
            const Divider(
              height: 22,
            ),

            _priceRow(
              'পুরাতন সোনা (১৮% deduction)',
              _formatMoney(
                _oldGold(bhori),
              ),
              true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value,
    bool highlight,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize:
                    highlight ? 14 : 12,
                color: highlight
                    ? Colors.black87
                    : Colors.black54,
                fontWeight: highlight
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize:
                  highlight ? 17 : 13,
              fontWeight:
                  highlight
                      ? FontWeight.bold
                      : FontWeight.w500,
              color: highlight
                  ? const Color(
                      0xFF8B6508,
                    )
                  : Colors.black87,
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
      padding:
          const EdgeInsets.only(
        top: 7,
        bottom: 12,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                const Color(0xFF8B6508),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(0xFF6B0000),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'আজকের বাজার',
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        backgroundColor:
            const Color(0xFFFF3B30),
        iconTheme:
            const IconThemeData(
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
                      color:
                          Colors.black54,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () =>
                  _loadPrices(
                forceRefresh: true,
              ),
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.all(14),
                children: [
                  if (showingCachedData)
                    Container(
                      width:
                          double.infinity,
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      padding:
                          const EdgeInsets.all(
                        12,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors.orange
                            .withOpacity(
                          0.12,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                      child: Text(
                        errorMessage,
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          color:
                              Colors.orange,
                        ),
                      ),
                    ),

                  Container(
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets.all(
                      18,
                    ),
                    margin:
                        const EdgeInsets.only(
                      bottom: 16,
                    ),
                    decoration:
                        BoxDecoration(
                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(0xFF6B0000),
                          Color(0xFF9E1B1B),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                    child:
                        const Column(
                      children: [
                        Icon(
                          Icons.storefront,
                          color:
                              Color(0xFFFFD700),
                          size: 38,
                        ),
                        SizedBox(height: 7),
                        Text(
                          'আজকের বাজার',
                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFFFFD700,
                            ),
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'সর্বশেষ সোনা ও রুপার বাজার দর',
                          style:
                              TextStyle(
                            color:
                                Colors.white,
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

                  _priceCard(
                    title:
                        '২২ ক্যারেট সোনা',
                    perGram: gold22,
                    color:
                        Colors.amber.shade800,
                    icon: Icons
                        .workspace_premium,
                    showOldGold: true,
                  ),

                  _priceCard(
                    title:
                        '২১ ক্যারেট সোনা',
                    perGram: gold21,
                    color:
                        Colors.amber.shade800,
                    icon: Icons
                        .workspace_premium,
                  ),

                  _priceCard(
                    title:
                        '১৮ ক্যারেট সোনা',
                    perGram: gold18,
                    color:
                        Colors.amber.shade800,
                    icon: Icons
                        .workspace_premium,
                  ),

                  const SizedBox(height: 8),

                  _sectionTitle(
                    'রুপার দাম',
                    Icons.circle_outlined,
                  ),

                  _priceCard(
                    title:
                        '২২ ক্যারেট রুপা',
                    perGram: silver22,
                    color:
                        Colors.blueGrey,
                    icon:
                        Icons.circle_outlined,
                  ),

                  _priceCard(
                    title:
                        '২১ ক্যারেট রুপা',
                    perGram: silver21,
                    color:
                        Colors.blueGrey,
                    icon:
                        Icons.circle_outlined,
                  ),

                  _priceCard(
                    title:
                        '১৮ ক্যারেট রুপা',
                    perGram: silver18,
                    color:
                        Colors.blueGrey,
                    icon:
                        Icons.circle_outlined,
                  ),

                  const SizedBox(height: 10),

                  const Center(
                    child: Text(
                      '১ ভরি = ১৬ আনা = ৯৬ রতি = ১১.৬৬৪ গ্রাম',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Colors.black54,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),

                  if (lastUpdated.isNotEmpty) ...[
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      'সর্বশেষ data update: $lastUpdated',
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color:
                            Colors.black45,
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 7,
                  ),

                  const Center(
                    child: Text(
                      'Price source: Gold Price Bangladesh (BAJUS-based)',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            Colors.black38,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
    );
  }
}
