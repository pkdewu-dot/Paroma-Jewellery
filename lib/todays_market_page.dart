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

  @override
  void initState() {
    super.initState();
    _loadMarket();
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
          .timeout(const Duration(seconds: 20));

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

      if (g22 == null ||
          g21 == null ||
          g18 == null ||
          s22 == null ||
          s21 == null ||
          s18 == null) {
        throw Exception('Incomplete market data');
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

  String _money(double value) {
    return '৳${value.round()}';
  }

  // 1 ভরি = 11.664 gram
  // 1 ভরি = 16 আনা
  // 1 ভরি = 96 রতি
  // 1 রতি = 10 পয়েন্ট

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

  Widget _title(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: 2,
          width: double.infinity,
          color: Colors.black87,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _header() {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'ক্যারেট',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'ভরি',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'আনা',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'রতি',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'পয়েন্ট',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'গ্রাম',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    String karat,
    double gram, {
    bool oldGold = false,
  }) {
    final multiplier = oldGold ? 0.82 : 1.0;

    return Container(
      margin: const EdgeInsets.only(top: 7),
      padding: const EdgeInsets.symmetric(
        vertical: 11,
        horizontal: 2,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              karat,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _money(_bhori(gram) * multiplier),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _money(_ana(gram) * multiplier),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _money(_roti(gram) * multiplier),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _money(_point(gram) * multiplier),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _money(gram * multiplier),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gold() {
    if (_gold22 == null ||
        _gold21 == null ||
        _gold18 == null) {
      return _unavailable(
        'সোনার দাম পাওয়া যাচ্ছে না',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('সোনার দাম'),
        _header(),

        _row('22K', _gold22!),
        _row('21K', _gold21!),
        _row('18K', _gold18!),

        const SizedBox(height: 14),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.orange.shade200,
            ),
          ),
          child: const Text(
            'Deduction: 18%\nOnly for old gold purchase',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 12),

        _title('পুরাতন সোনার দাম'),
        _header(),

        _row(
          '22K',
          _gold22!,
          oldGold: true,
        ),

        _row(
          '21K',
          _gold21!,
          oldGold: true,
        ),

        _row(
          '18K',
          _gold18!,
          oldGold: true,
        ),
      ],
    );
  }

  Widget _silver() {
    if (_silver22 == null ||
        _silver21 == null ||
        _silver18 == null) {
      return _unavailable(
        'রুপার দাম পাওয়া যাচ্ছে না',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('রুপার দাম'),
        _header(),

        _row('22K', _silver22!),
        _row('21K', _silver21!),
        _row('18K', _silver18!),
      ],
    );
  }

  Widget _unavailable(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            textAlign: TextAlign.center,
          ),
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
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _refreshing
                ? null
                : () => _loadMarket(
                      manualRefresh: true,
                    ),
            icon: _refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => _loadMarket(
                manualRefresh: true,
              ),
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _gold(),

                  const SizedBox(height: 28),

                  _silver(),

                  if (_error != null) ...[
                    const SizedBox(height: 15),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ],

                  if (_lastUpdate != null) ...[
                    const SizedBox(height: 15),
                    Text(
                      'সর্বশেষ আপডেট: $_lastUpdate',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  const Text(
                    'Prices provided by Gold Price Bangladesh',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
