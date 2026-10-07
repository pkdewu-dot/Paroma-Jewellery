import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({super.key});

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  WebViewController? _controller;

  bool _loading = true;
  bool _fetching = false;

  String _error = '';

  Map<String, dynamic> _prices = {};

  @override
  void initState() {
    super.initState();
    _loadSavedOrFetch();
  }

  // ============================================================
  // BASIC CONSTANTS
  // ============================================================

  static const double gramPerBhori = 11.664;
  static const double anaPerBhori = 16.0;
  static const double rotiPerBhori = 96.0;

  // ============================================================
  // START
  // ============================================================

  Future<void> _loadSavedOrFetch() async {
    final prefs = await SharedPreferences.getInstance();

    final savedDate = prefs.getString('market_date') ?? '';
    final today = _todayKey();

    final savedJson = prefs.getString('market_prices');

    if (savedDate == today && savedJson != null) {
      try {
        final decoded = jsonDecode(savedJson);

        if (decoded is Map) {
          setState(() {
            _prices = Map<String, dynamic>.from(decoded);
            _loading = false;
          });

          return;
        }
      } catch (_) {}
    }

    await _fetchFromGoldR();
  }

  String _todayKey() {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // WEBVIEW
  // ============================================================

  Future<void> _fetchFromGoldR() async {
    if (_fetching) return;

    _fetching = true;

    setState(() {
      _loading = true;
      _error = '';
    });

    final html = '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<script async src="https://www.goldr.org/price.ultra.js"></script>
</head>

<body>

<i id="g22" data="22k-1bhori-dam"></i>
<i id="g21" data="21k-1bhori-dam"></i>
<i id="g18" data="18k-1bhori-dam"></i>

<i id="s22" data="22k-1bhori-dam"></i>

</body>
</html>
''';

    try {
      final controller = WebViewController();

      await controller.setJavaScriptMode(
        JavaScriptMode.unrestricted,
      );

      await controller.setBackgroundColor(
        Colors.white,
      );

      await controller.setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            // এখানে error দেখাব না।
            // Script load হতে সময় লাগতে পারে।
          },
        ),
      );

      _controller = controller;

      await controller.loadHtmlString(html);

      // GoldR script-এর জন্য কিছু সময় অপেক্ষা
      await Future.delayed(
        const Duration(seconds: 7),
      );

      final result = await controller.runJavaScriptReturningResult(
        '''
(function() {
  function getValue(id) {
    var el = document.getElementById(id);
    if (!el) return "";
    return (el.innerText || el.textContent || "").trim();
  }

  return JSON.stringify({
    g22: getValue("g22"),
    g21: getValue("g21"),
    g18: getValue("g18")
  });
})();
''',
      );

      String jsonText = result.toString();

      // WebView result অনেক সময় quoted JSON হিসেবে আসে
      if (jsonText.startsWith('"') &&
          jsonText.endsWith('"')) {
        try {
          jsonText = jsonDecode(jsonText);
        } catch (_) {}
      }

      final decoded = jsonDecode(jsonText);

      final g22 = _extractNumber(
        decoded['g22']?.toString() ?? '',
      );

      final g21 = _extractNumber(
        decoded['g21']?.toString() ?? '',
      );

      final g18 = _extractNumber(
        decoded['g18']?.toString() ?? '',
      );

      // অন্তত একটি rate পেলেই success
      if (g22.isEmpty &&
          g21.isEmpty &&
          g18.isEmpty) {
        throw Exception(
          'GoldR থেকে price পাওয়া যায়নি',
        );
      }

      await _savePrices(
        g22: g22,
        g21: g21,
        g18: g18,
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _fetching = false;
        _error = '';
      });
    } catch (e) {
      // আজকের নতুন rate না পেলে আগের saved rate ব্যবহার
      final prefs = await SharedPreferences.getInstance();

      final savedJson =
          prefs.getString('market_prices');

      if (savedJson != null) {
        try {
          final decoded = jsonDecode(savedJson);

          if (decoded is Map) {
            setState(() {
              _prices =
                  Map<String, dynamic>.from(decoded);
              _loading = false;
              _fetching = false;
              _error =
                  'নতুন বাজার দর পাওয়া যায়নি। '
                  'সর্বশেষ সংরক্ষিত দর দেখানো হচ্ছে।';
            });

            return;
          }
        } catch (_) {}
      }

      if (!mounted) return;

      setState(() {
        _loading = false;
        _fetching = false;
        _error =
            'আজকের বাজারের দাম পাওয়া যাচ্ছে না।\n\n'
            'ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';
      });
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _savePrices({
    required String g22,
    required String g21,
    required String g18,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final data = {
      'date': _todayKey(),
      'g22': g22,
      'g21': g21,
      'g18': g18,
    };

    await prefs.setString(
      'market_prices',
      jsonEncode(data),
    );

    await prefs.setString(
      'market_date',
      _todayKey(),
    );

    if (!mounted) return;

    setState(() {
      _prices = data;
    });
  }

  // ============================================================
  // NUMBER CLEANER
  // ============================================================

  String _extractNumber(String value) {
    if (value.trim().isEmpty) {
      return '';
    }

    String text = value.trim();

    const bangla = '০১২৩৪৫৬৭৮৯';
    const english = '0123456789';

    for (int i = 0; i < bangla.length; i++) {
      text = text.replaceAll(
        bangla[i],
        english[i],
      );
    }

    // GoldR price হতে পারে:
    // ৳২২৯,০৮১
    // ৳ 229,081
    // 229081

    final match = RegExp(
      r'([0-9]+(?:,[0-9]{3})*)',
    ).firstMatch(text);

    if (match == null) {
      return '';
    }

    return match
            .group(1)
            ?.replaceAll(',', '') ??
        '';
  }

  // ============================================================
  // CALCULATIONS
  // ============================================================

  double _number(String key) {
    final value = _prices[key];

    if (value == null) {
      return 0;
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  double _ana(double bhori) {
    return bhori / anaPerBhori;
  }

  double _roti(double bhori) {
    return bhori / rotiPerBhori;
  }

  double _gram(double bhori) {
    return bhori / gramPerBhori;
  }

  double _oldGold(double current) {
    return current * 0.82;
  }

  // ============================================================
  // FORMATTING
  // ============================================================

  String _formatNumber(
    double value, {
    int decimals = 0,
  }) {
    if (value == 0) {
      return 'তথ্য নেই';
    }

    if (decimals == 0) {
      return value.round().toString();
    }

    return value.toStringAsFixed(decimals);
  }

  String _banglaDigits(String value) {
    const english = '0123456789';
    const bangla = '০১২৩৪৫৬৭৮৯';

    String result = value;

    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(
        english[i],
        bangla[i],
      );
    }

    return result;
  }

  String _price(double value) {
    if (value == 0) {
      return 'তথ্য নেই';
    }

    return '৳ ${_banglaDigits(
      _formatNumber(value),
    )}';
  }

  // ============================================================
  // PRICE CARD
  // ============================================================

  Widget _priceCard({
    required String title,
    required double bhori,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
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
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
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

                const SizedBox(height: 5),

                Text(
                  '১ ভরি',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _price(bhori),
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),

                if (bhori > 0) ...[
                  const SizedBox(height: 8),

                  Text(
                    '১ আনা: ${_price(_ana(bhori))}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),

                  Text(
                    '১ রতি: ${_price(_roti(bhori))}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),

                  Text(
                    '১ গ্রাম: ${_price(_gram(bhori))}',
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final g22 = _number('g22');
    final g21 = _number('g21');
    final g18 = _number('g18');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'আজকের বাজার',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            const Color(0xFFFF3B30),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: _loading
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

          : _error.isNotEmpty &&
                  _prices.isEmpty
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(25),
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
                          _error,
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          onPressed:
                              _fetchFromGoldR,
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

              : RefreshIndicator(
                  onRefresh: _fetchFromGoldR,

                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),

                    padding:
                        const EdgeInsets.all(14),

                    children: [
                      if (_error.isNotEmpty)
                        Container(
                          width:
                              double.infinity,
                          margin:
                              const EdgeInsets.only(
                            bottom: 12,
                          ),
                          padding:
                              const EdgeInsets.all(12),
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.orange
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
                            _error,
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
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'সর্বশেষ বাজার দর',
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

                      const Padding(
                        padding:
                            EdgeInsets.only(
                          top: 5,
                          bottom: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .auto_awesome,
                              color:
                                  Color(
                                0xFF8B6508,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'সোনার দাম',
                              style:
                                  TextStyle(
                                fontSize: 21,
                                fontWeight:
                                    FontWeight
                                        .bold,
                                color:
                                    Color(
                                  0xFF6B0000,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      _priceCard(
                        title:
                            '২২ ক্যারেট সোনা',
                        bhori: g22,
                        color:
                            Colors.amber.shade800,
                        icon: Icons
                            .workspace_premium,
                      ),

                      _priceCard(
                        title:
                            '২১ ক্যারেট সোনা',
                        bhori: g21,
                        color:
                            Colors.amber.shade800,
                        icon: Icons
                            .workspace_premium,
                      ),

                      _priceCard(
                        title:
                            '১৮ ক্যারেট সোনা',
                        bhori: g18,
                        color:
                            Colors.amber.shade800,
                        icon: Icons
                            .workspace_premium,
                      ),

                      const SizedBox(height: 10),

                      if (g22 > 0)
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets
                                  .all(16),
                          margin:
                              const EdgeInsets
                                  .only(
                            bottom: 12,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors
                                .brown
                                .withOpacity(
                              0.06,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const Text(
                                'পুরাতন সোনা',
                                style:
                                    TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              Text(
                                '২২K Old Gold: '
                                '${_price(
                                  _oldGold(g22),
                                )} / ভরি',
                                style:
                                    const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              const Text(
                                '১৮% deduction বাদ দিয়ে হিসাব করা হয়েছে।',
                                style:
                                    TextStyle(
                                  fontSize: 11,
                                  color:
                                      Colors.black54,
                                ),
                              ),
                            ],
                          ),
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

                      const SizedBox(height: 15),

                      const Center(
                        child: Text(
                          'তথ্যসূত্র: GoldR.org',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Colors.black45,
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
