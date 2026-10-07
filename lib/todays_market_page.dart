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
  bool _refreshing = false;

  String? _goldError;
  String? _silverError;
  String? _lastUpdate;

  double? gold22;
  double? gold21;
  double? gold18;

  double? silver22;
  double? silver21;
  double? silver18;

  static const String goldApi =
      'https://gold-price.bd/api/gold/latest.json';

  static const String silverApi =
      'https://gold-price.bd/api/silver/latest.json';

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _goldError = null;
        _silverError = null;
      });
    }

    await Future.wait([
      _loadGold(),
      _loadSilver(),
    ]);

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _refreshPrices() async {
    if (_refreshing) return;

    setState(() {
      _refreshing = true;
      _goldError = null;
      _silverError = null;
    });

    await Future.wait([
      _loadGold(),
      _loadSilver(),
    ]);

    if (mounted) {
      setState(() {
        _refreshing = false;
      });
    }
  }

  Future<void> _loadGold() async {
    try {
      final uri = Uri.parse(
        '$goldApi?refresh=${DateTime.now().millisecondsSinceEpoch}',
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Paroma-Jewellery-App',
        },
      ).timeout(
        const Duration(seconds: 20),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Gold API status: ${response.statusCode}',
        );
      }

      final body = response.body.trim();

      if (body.isEmpty) {
        throw Exception('Gold API empty response');
      }

      final data = jsonDecode(body);

      final latest = data['latest'];

      if (latest == null) {
        throw Exception('Gold latest data পাওয়া যায়নি');
      }

      final k22 = _toDouble(latest['k22']);
      final k21 = _toDouble(latest['k21']);
      final k18 = _toDouble(latest['k18']);

      if (k22 == null || k21 == null || k18 == null) {
        throw Exception('Gold 22K/21K/18K data পাওয়া যায়নি');
      }

      final update = data['lastUpdate']?.toString();

      if (!mounted) return;

      setState(() {
        gold22 = k22;
        gold21 = k21;
        gold18 = k18;

        if (update != null && update.isNotEmpty) {
          _lastUpdate = update;
        }

        _goldError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _goldError = 'Gold data পাওয়া যায়নি';
      });
    }
  }

  Future<void> _loadSilver() async {
    try {
      final uri = Uri.parse(
        '$silverApi?refresh=${DateTime.now().millisecondsSinceEpoch}',
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Paroma-Jewellery-App',
        },
      ).timeout(
        const Duration(seconds: 20),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Silver API status: ${response.statusCode}',
        );
      }

      final body = response.body.trim();

      if (body.isEmpty) {
        throw Exception('Silver API empty response');
      }

      final data = jsonDecode(body);

      final latest = data['latest'];

      if (latest == null) {
        throw Exception('Silver latest data পাওয়া যায়নি');
      }

      final k22 = _toDouble(latest['k22']);
      final k21 = _toDouble(latest['k21']);
      final k18 = _toDouble(latest['k18']);

      if (k22 == null || k21 == null || k18 == null) {
        throw Exception('Silver 22K/21K/18K data পাওয়া যায়নি');
      }

      if (!mounted) return;

      setState(() {
        silver22 = k22;
        silver21 = k21;
        silver18 = k18;

        _silverError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _silverError = 'Silver data পাওয়া যায়নি';
      });
    }
  }

  double? _toDouble(dynamic value) {
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

  double _bhori(double gramPrice) {
    return gramPrice * 11.664;
  }

  double _ana(double gramPrice) {
    return _bhori(gramPrice) / 16;
  }

  double _roti(double gramPrice) {
    return _bhori(gramPrice) / 96;
  }

  double _point(double gramPrice) {
    return _bhori(gramPrice) / 960;
  }

  Widget _sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
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

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 5,
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'ভরি',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'আনা',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'রতি',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'পয়েন্ট',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'গ্রাম',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow({
    required String karat,
    required double gramPrice,
    bool oldGold = false,
  }) {
    final multiplier = oldGold ? 0.82 : 1.0;

    final bhori = _bhori(gramPrice) * multiplier;
    final ana = _ana(gramPrice) * multiplier;
    final roti = _roti(gramPrice) * multiplier;
    final point = _point(gramPrice) * multiplier;

    return Container(
      margin: const EdgeInsets.only(top: 7),
      padding: const EdgeInsets.symmetric(
        vertical: 11,
        horizontal: 3,
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
              _money(bhori),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _money(ana),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _money(roti),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _money(point),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _money(gramPrice * multiplier),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingBox(String text) {
    return Container(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 15),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _goldSection() {
    if (gold22 == null ||
        gold21 == null ||
        gold18 == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off,
              size: 45,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              _goldError ?? 'Gold price পাওয়া যাচ্ছে না',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('সোনার দাম'),
        _tableHeader(),

        _priceRow(
          karat: '22K',
          gramPrice: gold22!,
        ),

        _priceRow(
          karat: '21K',
          gramPrice: gold21!,
        ),

        _priceRow(
          karat: '18K',
          gramPrice: gold18!,
        ),

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

        _sectionTitle('পুরাতন সোনার দাম'),
        _tableHeader(),

        _priceRow(
          karat: '22K',
          gramPrice: gold22!,
          oldGold: true,
        ),

        _priceRow(
          karat: '21K',
          gramPrice: gold21!,
          oldGold: true,
        ),

        _priceRow(
          karat: '18K',
          gramPrice: gold18!,
          oldGold: true,
        ),
      ],
    );
  }

  Widget _silverSection() {
    if (silver22 == null ||
        silver21 == null ||
        silver18 == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off,
              size: 45,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              _silverError ?? 'Silver price পাওয়া যাচ্ছে না',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('রুপার দাম'),
        _tableHeader(),

        _priceRow(
          karat: '22K',
          gramPrice: silver22!,
        ),

        _priceRow(
          karat: '21K',
          gramPrice: silver21!,
        ),

        _priceRow(
          karat: '18K',
          gramPrice: silver18!,
        ),
      ],
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
                : _refreshPrices,
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
          ? _loadingBox(
              'আজকের বাজারের দাম লোড হচ্ছে...',
            )
          : RefreshIndicator(
              onRefresh: _refreshPrices,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _goldSection(),

                  const SizedBox(height: 28),

                  _silverSection(),

                  const SizedBox(height: 20),

                  if (_lastUpdate != null)
                    Text(
                      'সর্বশেষ আপডেট: $_lastUpdate',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),

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
