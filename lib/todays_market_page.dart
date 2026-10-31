import 'dart:async';
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
  static const String _marketUrl =
      'https://raw.githubusercontent.com/pkdewu-dot/Paroma-Jewellery/main/market.json';

  static const String _marketCacheKey = 'paroma_market_cache_v1';

  bool _loading = true;
  bool _refreshing = false;
  Timer? _autoRefreshTimer;

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

    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted && !_refreshing) {
        _loadMarket(manualRefresh: true);
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _percentageController.dispose();
    super.dispose();
  }

  static const String _goldApiUrl =
      'https://gold-price.bd/api/gold/latest.json';
  static const String _silverApiUrl =
      'https://gold-price.bd/api/silver/latest.json';

  Future> _fetchApiMarket() async {
    const headers = {
      'Accept': 'application/json',
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
    };

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final responses = await Future.wait([
      http.get(Uri.parse('$_goldApiUrl?ts=$stamp'), headers: headers)
          .timeout(const Duration(seconds: 20)),
      http.get(Uri.parse('$_silverApiUrl?ts=$stamp'), headers: headers)
          .timeout(const Duration(seconds: 20)),
    ]);

    if (responses[0].statusCode != 200 ||
        responses[1].statusCode != 200) {
      throw Exception('Price API status error');
    }

    final goldData = jsonDecode(responses[0].body);
    final silverData = jsonDecode(responses[1].body);
    if (goldData is! Map<String, dynamic> ||
        silverData is! Map<String, dynamic>) {
      throw Exception('Invalid price API response');
    }

    final goldLatest = goldData['latest'];
    final silverLatest = silverData['latest'];
    if (goldLatest is! Map || silverLatest is! Map) {
      throw Exception('Price API data is missing');
    }

    final g22 = _number(goldLatest['k22']);
    final g21 = _number(goldLatest['k21']);
    final g18 = _number(goldLatest['k18']);
    final s22 = _number(silverLatest['k22']);
    final s21 = _number(silverLatest['k21']);
    final s18 = _number(silverLatest['k18']);

    if (g22 == null || g21 == null || g18 == null ||
        s22 == null || s21 == null || s18 == null) {
      throw Exception('Price API returned incomplete prices');
    }

    final goldUpdate = goldData['lastUpdate']?.toString();
    final silverUpdate = silverData['lastUpdate']?.toString();
    if (goldUpdate == null || goldUpdate.isEmpty ||
        silverUpdate == null || silverUpdate.isEmpty) {
      throw Exception('Price API update date is missing');
    }

    return {
      'gold': {'k22': g22, 'k21': g21, 'k18': g18},
      'silver': {'k22': s22, 'k21': s21, 'k18': s18},
      'lastUpdate': 'সোনা: $goldUpdate \vert{} রুপা: $silverUpdate',
    };
  }

  Future<void> _loadMarket({bool manualRefresh = false}) async {
    if (mounted) {
      setState(() {
        if (!manualRefresh) _loading = true;
        if (manualRefresh) _refreshing = true;
        _error = null;
      });
    }

    try {
      Map<String, dynamic> data;

      try {
        data = await _fetchApiMarket();
      } catch (_) {
        final uri = Uri.parse(
          '$_marketUrl?ts=${DateTime.now().millisecondsSinceEpoch}',
        );
        final response = await http.get(
          uri,
          headers: const {
            'Accept': 'application/json',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
          },
        ).timeout(const Duration(seconds: 20));

        if (response.statusCode != 200) {
          throw Exception('Market file status: ${response.statusCode}');
        }
        final body = response.body.trim();
        if (body.isEmpty) throw Exception('Market file empty');

        final decoded = jsonDecode(body);
        if (decoded is! Map<String, dynamic>) {
          throw Exception('Invalid market data');
        }
        data = decoded;
      }

      final gold = data['gold'];
      final silver = data['silver'];
      final g22 = _number(gold?['k22']);
      final g21 = _number(gold?['k21']);
      final g18 = _number(gold?['k18']);
      final s22 = _number(silver?['k22']);
      final s21 = _number(silver?['k21']);
      final s18 = _number(silver?['k18']);

      if (g22 == null || g21 == null || g18 == null ||
          s22 == null || s21 == null || s18 == null) {
        throw Exception('Incomplete gold or silver data');
      }

      final normalizedData = <String, dynamic>{
        'gold': {'k22': g22, 'k21': g21, 'k18': g18},
        'silver': {'k22': s22, 'k21': s21, 'k18': s18},
        'lastUpdate': data['lastUpdate']?.toString() ?? 'তারিখ পাওয়া যায়নি',
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_marketCacheKey, jsonEncode(normalizedData));

      if (!mounted) return;
      setState(() {
        _gold22 = g22;
        _gold21 = g21;
        _gold18 = g18;
        _silver22 = s22;
        _silver21 = s21;
        _silver18 = s18;
        _lastUpdate = normalizedData['lastUpdate'] as String;
        _loading = false;
        _refreshing = false;
        _error = null;
      });
    } catch (_) {
      final cachedData = await _loadCachedMarket();
      if (!mounted) return;

      if (cachedData != null) {
        setState(() {
          _gold22 = cachedData['gold22'];
          _gold21 = cachedData['gold21'];
          _gold18 = cachedData['gold18'];
          _silver22 = cachedData['silver22'];
          _silver21 = cachedData['silver21'];
          _silver18 = cachedData['silver18'];
          _lastUpdate = cachedData['lastUpdate'];
          _loading = false;
          _refreshing = false;
          _error = 'নতুন দাম আনা যায়নি। সর্বশেষ সংরক্ষিত দাম দেখানো হচ্ছে।';
        });
      } else {
        setState(() {
          _loading = false;
          _refreshing = false;
          _error = 'আজকের বাজারের দাম পাওয়া যাচ্ছে না। ইন্টারনেট চালু করে আবার চেষ্টা করুন।';
        });
      }
    }
  }

  Future?> _loadCachedMarket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedBody = prefs.getString(_marketCacheKey);

      if (cachedBody == null || cachedBody.trim().isEmpty) {
        return null;
      }

      final data = jsonDecode(cachedBody);
      if (data is! Map<String, dynamic>) return null;

      final gold = data['gold'];
      final silver = data['silver'];

      final g22 = _number(gold?['k22']);
      final g21 = _number(gold?['k21']);
      final g18 = _number(gold?['k18']);
      final s22 = _number(silver?['k22']);
      final s21 = _number(silver?['k21']);
      final s18 = _number(silver?['k18']);

      if (g22 == null || g21 == null || g18 == null) return null;

      return {
        'gold22': g22,
        'gold21': g21,
        'gold18': g18,
        'silver22': s22,
        'silver21': s21,
        'silver18': s18,
        'lastUpdate': data['lastUpdate']?.toString(),
      };
    } catch (_) {
      return null;
    }
  }

  double? _number(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '').trim());
    }
    return null;
  }

  String _banglaDigits(String value) {
    const english = '0123456789';
    const bangla = '০১২৩৪৫৬৭৮৯';
    String result = value;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], bangla[i]);
    }
    return result;
  }

  String _formatNumber(double value) {
    final rounded = value.round();
    final negative = rounded < 0;
    String number = rounded.abs().toString();

    if (number.length <= 3) {
      return _banglaDigits('${negative ? '-' : ''}$number');
    }

    final lastThree = number.substring(number.length - 3);
    String remaining = number.substring(0, number.length - 3);
    final groups = <String>[];

    while (remaining.length > 2) {
      groups.insert(0, remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }

    if (remaining.isNotEmpty) groups.insert(0, remaining);

    final formatted = '${groups.join(',')},$lastThree';
    return _banglaDigits('${negative ? '-' : ''}$formatted');
  }

  String _money(double value) => _formatNumber(value);

  double _bhori(double gram) => gram * 11.664;
  double _ana(double gram) => _bhori(gram) / 16;
  double _roti(double gram) => _bhori(gram) / 96;
  double _point(double gram) => _bhori(gram) / 960;

  static const Color _primaryGold = Color(0xFFB8860B);
  static const Color _headerDark = Color(0xFF263238);
  static const Color _headerBlue = Color(0xFF1976A8);
  static const Color _headerGreen = Color(0xFF2E7D5B);
  static const Color _headerPurple = Color(0xFF7257A5);
  static const Color _headerOrange = Color(0xFFB56B2C);
  static const Color _headerRed = Color(0xFF9B4B4B);
  static const Color _rowBlue = Color(0xFFEAF7FF);
  static const Color _rowAsh = Color(0xFFF1F3F4);
  static const Color _rowWhite = Color(0xFFFFFFFF);
  static const Color _valueBlue = Color(0xFF1769AA);
  static const Color _valueGreen = Color(0xFF19764A);
  static const Color _valuePurple = Color(0xFF6845A5);
  static const Color _valueOrange = Color(0xFFB05A16);
  static const Color _valueRed = Color(0xFF9C4141);
  static const Color _percentageUnderline = Color(0xFFD9D9D9);

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 27,
            decoration: BoxDecoration(color: _primaryGold, borderRadius: BorderRadius.circular(5)),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _headerDark)),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    const style = TextStyle(fontWeight: FontWeight.w800, fontSize: 12);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('ক্যারেট', textAlign: TextAlign.center, style: style.copyWith(color: _headerDark))),
          Expanded(flex: 3, child: Text('ভরি', textAlign: TextAlign.center, style: style.copyWith(color: _headerBlue))),
          Expanded(flex: 3, child: Text('আনা', textAlign: TextAlign.center, style: style.copyWith(color: _headerGreen))),
          Expanded(flex: 3, child: Text('রতি', textAlign: TextAlign.center, style: style.copyWith(color: _headerPurple))),
          Expanded(flex: 3, child: Text('পয়েন্ট', textAlign: TextAlign.center, style: style.copyWith(color: _headerOrange))),
          Expanded(flex: 3, child: Text('গ্রাম', textAlign: TextAlign.center, style: style.copyWith(color: _headerRed))),
        ],
      ),
    );
  }

  Widget _priceRow(String karat, double gramPrice, {bool oldGold = false, Color background = _rowWhite}) {
    final multiplier = oldGold ? (1 - (_deduction / 100)) : 1.0;
    final gram = gramPrice * multiplier;
    final bhori = _bhori(gramPrice) * multiplier;
    final ana = _ana(gramPrice) * multiplier;
    final roti = _roti(gramPrice) * multiplier;
    final point = _point(gramPrice) * multiplier;

    Color karatColor = (karat == '22K') ? const Color(0xFF1769AA) : (karat == '18K
