import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({super.key});

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  static const String _marketUrl =
      'https://raw.githubusercontent.com/pkdewu-dot/Paroma-Jewellery/main/market.json';

  bool _loading = true;
  bool _refreshing = false;

  String? _error;
  String? _lastUpdate;

  double? _gold22;
  double? _gold21;
  double? _gold18;

  double? _silver22;
  double? _silver21;
  double? _silver18;

  double _deduction = 18.0;

  final TextEditingController _percentageController =
      TextEditingController(text: '18');

  @override
  void initState() {
    super.initState();
    _loadMarket();
  }

  @override
  void dispose() {
    _percentageController.dispose();
    super.dispose();
  }

  Future<void> _loadMarket({bool manualRefresh = false}) async {
    if (mounted) {
      setState(() {
        if (!manualRefresh) {
          _loading = true;
        }

        if (manualRefresh) {
          _refreshing = true;
        }

        _error = null;
      });
    }

    try {
      final uri = Uri.parse(
        '$_marketUrl?ts=${DateTime.now().millisecondsSinceEpoch}',
      );

      final response = await http
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Cache-Control': 'no-cache',
              'Pragma': 'no-cache',
            },
          )
          .timeout(
            const Duration(seconds: 20),
          );

      if (response.statusCode != 200) {
        throw Exception(
          'Market file status: ${response.statusCode}',
        );
      }

      final body = response.body.trim();

      if (body.isEmpty) {
        throw Exception('Market file empty');
      }

      final data = jsonDecode(body);

      final gold = data['gold'];
      final silver = data['silver'];

      final g22 = _number(gold?['k22']);
      final g21 = _number(gold?['k21']);
      final g18 = _number(gold?['k18']);

      final s22 = _number(silver?['k22']);
      final s21 = _number(silver?['k21']);
      final s18 = _number(silver?['k18']);

      if (g22 == null || g21 == null || g18 == null) {
        throw Exception('Incomplete gold data');
      }

      if (!mounted) return;

      setState(() {
        _gold22 = g22;
        _gold21 = g21;
        _gold18 = g18;

        _silver22 = s22;
        _silver21 = s21;
        _silver18 = s18;

        _lastUpdate = data['lastUpdate']?.toString();

        _loading = false;
        _refreshing = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _refreshing = false;
        _error =
            'আজকের বাজারের দাম পাওয়া যাচ্ছে না। আবার চেষ্টা করুন।';
      });
    }
  }

  double? _number(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(
        value.replaceAll(',', '').trim(),
      );
    }

    return null;
  }

  // ============================================================
  // Bangla number formatting
  // ============================================================

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

  String _formatNumber(double value) {
    final rounded = value.round();

    final negative = rounded < 0;

    String number = rounded.abs().toString();

    if (number.length <= 3) {
      return _banglaDigits(
        '${negative ? '-' : ''}$number',
      );
    }

    final lastThree =
        number.substring(number.length - 3);

    String remaining =
        number.substring(0, number.length - 3);

    final groups = <String>[];

    while (remaining.length > 2) {
      groups.insert(
        0,
        remaining.substring(
          remaining.length - 2,
        ),
      );

      remaining = remaining.substring(
        0,
        remaining.length - 2,
      );
    }

    if (remaining.isNotEmpty) {
      groups.insert(
        0,
        remaining,
      );
    }

    final formatted =
        '${groups.join(',')},$lastThree';

    return _banglaDigits(
      '${negative ? '-' : ''}$formatted',
    );
  }

  String _money(double value) {
    return _formatNumber(value);
  }

  // ============================================================
  // Unit calculation
  //
  // 1 ভরি = 11.664 gram
  // 1 ভরি = 16 আনা
  // 1 ভরি = 96 রতি
  // 1 রতি = 10 পয়েন্ট
  // ============================================================

  double _bhori(double gram) {
    return gram * 11.664;
  }

  double _ana(double gram) {
    return _bhori(gram) / 16;
  }

  double _roti(double gram) {
    return _bhori(gram) / 96;
  }

  double _point(double gram) {
    return _bhori(gram) / 960;
  }

  // ============================================================
  // Colors
  // ============================================================

  static const Color _primaryGold =
      Color(0xFFB8860B);

  static const Color _headerDark =
      Color(0xFF263238);

  static const Color _headerBlue =
      Color(0xFF1976A8);

  static const Color _headerGreen =
      Color(0xFF2E7D5B);

  static const Color _headerPurple =
      Color(0xFF7257A5);

  static const Color _headerOrange =
      Color(0xFFB56B2C);

  static const Color _headerRed =
      Color(0xFF9B4B4B);

  static const Color _rowBlue =
      Color(0xFFEAF7FF);

  static const Color _rowAsh =
      Color(0xFFF1F3F4);

  static const Color _rowWhite =
      Color(0xFFFFFFFF);

  static const Color _valueBlue =
      Color(0xFF1769AA);

  static const Color _valueGreen =
      Color(0xFF19764A);

  static const Color _valuePurple =
      Color(0xFF6845A5);

  static const Color _valueOrange =
      Color(0xFFB05A16);

  static const Color _valueRed =
      Color(0xFF9C4141);

  static const Color _percentageUnderline =
      Color(0xFFD9D9D9);

  // ============================================================
  // Section title
  // ============================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 27,
            decoration: BoxDecoration(
              color: _primaryGold,
              borderRadius:
                  BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _headerDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Table header
  // ============================================================

  Widget _tableHeader() {
    const style = TextStyle(
      fontWeight: FontWeight.w800,
      fontSize: 12,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      // IMPORTANT:
      // এখানে const Row রাখা হয়নি,
      // কারণ style.copyWith() const expression নয়।
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'ক্যারেট',
              textAlign: TextAlign.center,
              style: style.copyWith(
                color: _headerDark,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'ভরি',
              textAlign: TextAlign.center,
              style: style.copyWith(
                color: _headerBlue,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'আনা',
              textAlign: TextAlign.center,
              style: style.copyWith(
                color: _headerGreen,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'রতি',
              textAlign: TextAlign.center,
              style: style.copyWith(
                color: _headerPurple,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'পয়েন্ট',
              textAlign: TextAlign.center,
              style: style.copyWith(
                color: _headerOrange,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'গ্রাম',
              textAlign: TextAlign.center,
              style: style.copyWith(
                color: _headerRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Price row
  // ============================================================

  Widget _priceRow(
    String karat,
    double gramPrice, {
    bool oldGold = false,
    Color background = _rowWhite,
  }) {
    final multiplier =
        oldGold ? (1 - (_deduction / 100)) : 1.0;

    final gram =
        gramPrice * multiplier;

    final bhori =
        _bhori(gramPrice) * multiplier;

    final ana =
        _ana(gramPrice) * multiplier;

    final roti =
        _roti(gramPrice) * multiplier;

    final point =
        _point(gramPrice) * multiplier;

    Color karatColor;

    if (karat == '22K') {
      karatColor =
          const Color(0xFF1769AA);
    } else if (karat == '18K') {
      karatColor =
          const Color(0xFF59636A);
    } else {
      karatColor = _headerDark;
    }

    return Container(
      margin: const EdgeInsets.only(
        top: 6,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 13,
        horizontal: 3,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(9),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // ======================================================
          // Karat
          // ======================================================

          Expanded(
            flex: 2,
            child: Text(
              karat,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: karatColor,
                fontWeight:
                    FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),

          // ======================================================
          // Bhori
          // ======================================================

          Expanded(
            flex: 3,
            child: Text(
              _money(bhori),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _valueBlue,
                fontWeight:
                    FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),

          // ======================================================
          // Ana
          // ======================================================

          Expanded(
            flex: 3,
            child: Text(
              _money(ana),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _valueGreen,
                fontWeight:
                    FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),

          // ======================================================
          // Roti
          // ======================================================

          Expanded(
            flex: 3,
            child: Text(
              _money(roti),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _valuePurple,
                fontWeight:
                    FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),

          // ======================================================
          // Point
          // ======================================================

          Expanded(
            flex: 3,
            child: Text(
              _money(point),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _valueOrange,
                fontWeight:
                    FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),

          // ======================================================
          // Gram
          // ======================================================

          Expanded(
            flex: 3,
            child: Text(
              _money(gram),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _valueRed,
                fontWeight:
                    FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Percentage input
  // ============================================================

  Widget _percentageInput() {
    return SizedBox(
      width: 72,
      child: TextField(
        controller:
            _percentageController,
        keyboardType:
            const TextInputType.numberWithOptions(
          decimal: true,
        ),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        decoration:
            const InputDecoration(
          hintText: '%',
          hintStyle: TextStyle(
            color: Colors.white,
          ),
          suffixText: '%',
          suffixStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          isDense: true,
          contentPadding:
              EdgeInsets.only(
            left: 4,
            right: 4,
            bottom: 5,
          ),
          enabledBorder:
              UnderlineInputBorder(
            borderSide: BorderSide(
              color: _percentageUnderline,
              width: 1.5,
            ),
          ),
          focusedBorder:
              UnderlineInputBorder(
            borderSide: BorderSide(
              color: _percentageUnderline,
              width: 1.5,
            ),
          ),
        ),
        onChanged: (value) {
          final parsed =
              double.tryParse(
            value.trim(),
          );

          if (parsed == null) {
            return;
          }

          if (parsed < 0 || parsed > 100) {
            return;
          }

          setState(() {
            _deduction = parsed;
          });
        },
      ),
    );
  }

  // ============================================================
  // Old gold title
  // ============================================================

  Widget _oldGoldTitle() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Text(
              'পুরাতন সোনার দাম',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
                color: _headerDark,
              ),
            ),
          ),
          _percentageInput(),
        ],
      ),
    );
  }

  // ============================================================
  // Gold section
  // ============================================================

  Widget _goldSection() {
    if (_gold22 == null ||
        _gold21 == null ||
        _gold18 == null) {
      return _unavailable(
        'সোনার দাম পাওয়া যাচ্ছে না',
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'সোনার দাম',
        ),

        _tableHeader(),

        // 22K
        _priceRow(
          '22K',
          _gold22!,
          background: _rowBlue,
        ),

        // 21K
        _priceRow(
          '21K',
          _gold21!,
          background: _rowWhite,
        ),

        // 18K
        _priceRow(
          '18K',
          _gold18!,
          background: _rowAsh,
        ),

        // Old gold
        _oldGoldTitle(),

        _tableHeader(),

        // Old gold 22K
        _priceRow(
          '22K',
          _gold22!,
          oldGold: true,
          background: _rowBlue,
        ),

        // Old gold 21K
        _priceRow(
          '21K',
          _gold21!,
          oldGold: true,
          background: _rowWhite,
        ),

        // Old gold 18K
        _priceRow(
          '18K',
          _gold18!,
          oldGold: true,
          background: _rowAsh,
        ),
      ],
    );
  }

  // ============================================================
  // Silver section
  // ============================================================

  Widget _silverSection() {
    if (_silver22 == null ||
        _silver21 == null ||
        _silver18 == null) {
      return _unavailable(
        'রুপার দাম পাওয়া যাচ্ছে না',
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'রুপার দাম',
        ),

        _tableHeader(),

        // 22K
        _priceRow(
          '22K',
          _silver22!,
          background: _rowBlue,
        ),

        // 21K
        _priceRow(
          '21K',
          _silver21!,
          background: _rowWhite,
        ),

        // 18K
        _priceRow(
          '18K',
          _silver18!,
          background: _rowAsh,
        ),
      ],
    );
  }

  // ============================================================
  // Unavailable
  // ============================================================

  Widget _unavailable(String text) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off,
            size: 42,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign:
                TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'আজকের বাজার',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _refreshing
                ? null
                : () {
                    _loadMarket(
                      manualRefresh: true,
                    );
                  },
            icon: _refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.refresh,
                  ),
          ),
        ],
      ),

      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () {
                return _loadMarket(
                  manualRefresh: true,
                );
              },
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.all(15),
                children: [
                  // GOLD
                  _goldSection(),

                  const SizedBox(
                    height: 30,
                  ),

                  // SILVER
                  _silverSection(),

                  if (_error != null) ...[
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      _error!,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ],

                  if (_lastUpdate != null) ...[
                    const SizedBox(
                      height: 18,
                    ),
                    Text(
                      'সর্বশেষ আপডেট: $_lastUpdate',
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'Prices provided by Gold Price Bangladesh',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
    );
  }
}
