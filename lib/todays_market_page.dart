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
  bool _loading = true;
  bool _refreshing = false;
  String? _error;
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

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadPrices({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final loaded = await _loadCache();

      if (loaded) {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }

        // Cache দেখানোর পর quietly online update check করবে
        _fetchOnlinePrices(updateUI: false);
        return;
      }
    }

    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    await _fetchOnlinePrices(updateUI: true);
  }

  Future<bool> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedDate = prefs.getString('market_date');

      if (savedDate == null || savedDate != _todayKey()) {
        return false;
      }

      final g22 = prefs.getDouble('gold22');
      final g21 = prefs.getDouble('gold21');
      final g18 = prefs.getDouble('gold18');

      final s22 = prefs.getDouble('silver22');
      final s21 = prefs.getDouble('silver21');
      final s18 = prefs.getDouble('silver18');

      if (g22 == null ||
          g21 == null ||
          g18 == null ||
          s22 == null ||
          s21 == null ||
          s18 == null) {
        return false;
      }

      if (!mounted) return true;

      setState(() {
        gold22 = g22;
        gold21 = g21;
        gold18 = g18;

        silver22 = s22;
        silver21 = s21;
        silver18 = s18;

        _lastUpdate = prefs.getString('market_last_update');
        _error = null;
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _fetchOnlinePrices({required bool updateUI}) async {
    try {
      final goldResponse = await http
          .get(Uri.parse(goldApi))
          .timeout(const Duration(seconds: 15));

      final silverResponse = await http
          .get(Uri.parse(silverApi))
          .timeout(const Duration(seconds: 15));

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

      final goldData = jsonDecode(goldResponse.body);
      final silverData = jsonDecode(silverResponse.body);

      final newGold22 = _readPrice(goldData, 'k22');
      final newGold21 = _readPrice(goldData, 'k21');
      final newGold18 = _readPrice(goldData, 'k18');

      final newSilver22 = _readPrice(silverData, 'k22');
      final newSilver21 = _readPrice(silverData, 'k21');
      final newSilver18 = _readPrice(silverData, 'k18');

      if (newGold22 == null ||
          newGold21 == null ||
          newGold18 == null ||
          newSilver22 == null ||
          newSilver21 == null ||
          newSilver18 == null) {
        throw Exception('Price data পাওয়া যায়নি');
      }

      final goldLastUpdate = _readLastUpdate(goldData);

      await _saveCache(
        gold22: newGold22,
        gold21: newGold21,
        gold18: newGold18,
        silver22: newSilver22,
        silver21: newSilver21,
        silver18: newSilver18,
        lastUpdate: goldLastUpdate,
      );

      if (!mounted) return;

      setState(() {
        gold22 = newGold22;
        gold21 = newGold21;
        gold18 = newGold18;

        silver22 = newSilver22;
        silver21 = newSilver21;
        silver18 = newSilver18;

        _lastUpdate = goldLastUpdate;
        _loading = false;
        _refreshing = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      // যদি আগে থেকেই data থাকে, data রেখে শুধু warning দেখাবে।
      if (gold22 != null &&
          gold21 != null &&
          gold18 != null &&
          silver22 != null &&
          silver21 != null &&
          silver18 != null) {
        setState(() {
          _loading = false;
          _refreshing = false;
          _error = 'নতুন দাম আপডেট করা যায়নি। আগের সংরক্ষিত দাম দেখানো হচ্ছে।';
        });
      } else {
        setState(() {
          _loading = false;
          _refreshing = false;
          _error =
              'আজকের বাজারের দাম পাওয়া যাচ্ছে না। আবার চেষ্টা করুন।';
        });
      }
    }
  }

  double? _readPrice(dynamic data, String key) {
    try {
      final latest = data['latest'];

      final value = latest[key];

      if (value is num) {
        return value.toDouble();
      }

      if (value is String) {
        return double.tryParse(value.replaceAll(',', '').trim());
      }
    } catch (_) {}

    return null;
  }

  String? _readLastUpdate(dynamic data) {
    try {
      final value = data['lastUpdate'];

      if (value != null) {
        return value.toString();
      }
    } catch (_) {}

    return null;
  }

  Future<void> _saveCache({
    required double gold22,
    required double gold21,
    required double gold18,
    required double silver22,
    required double silver21,
    required double silver18,
    String? lastUpdate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('market_date', _todayKey());

      await prefs.setDouble('gold22', gold22);
      await prefs.setDouble('gold21', gold21);
      await prefs.setDouble('gold18', gold18);

      await prefs.setDouble('silver22', silver22);
      await prefs.setDouble('silver21', silver21);
      await prefs.setDouble('silver18', silver18);

      if (lastUpdate != null) {
        await prefs.setString('market_last_update', lastUpdate);
      }
    } catch (_) {}
  }

  Future<void> _refresh() async {
    if (_refreshing) return;

    setState(() {
      _refreshing = true;
      _error = null;
    });

    await _fetchOnlinePrices(updateUI: true);
  }

  String _money(double value) {
    return '৳${value.round().toString()}';
  }

  // 1 ভরি = 11.664 gram
  // 1 ভরি = 16 আনা
  // 1 ভরি = 96 রতি
  // 1 রতি = 10 পয়েন্ট

  double _bhori(double perGram) {
    return perGram * 11.664;
  }

  double _ana(double perGram) {
    return _bhori(perGram) / 16;
  }

  double _roti(double perGram) {
    return _bhori(perGram) / 96;
  }

  double _point(double perGram) {
    return _roti(perGram) / 10;
  }

  double _oldGold(double perGram) {
    // পুরাতন সোনার ক্ষেত্রে 18% deduction
    return _bhori(perGram) * 0.82;
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
            color: Colors.black87,
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

  Widget _headerRow() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 11,
        horizontal: 8,
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
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'ভরি',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'আনা',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'রতি',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'পয়েন্ট',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'গ্রাম',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow({
    required String karat,
    required double perGram,
    bool oldGold = false,
  }) {
    final bhori = _bhori(perGram);

    return Container(
      margin: const EdgeInsets.only(top: 7),
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
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
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _money(oldGold ? bhori * 0.82 : bhori),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _money(oldGold ? _ana(perGram) * 0.82 : _ana(perGram)),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _money(oldGold ? _roti(perGram) * 0.82 : _roti(perGram)),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _money(oldGold ? _point(perGram) * 0.82 : _point(perGram)),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _money(perGram),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deductionBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12, bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.orange.shade200,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deduction: 18%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Only for old gold purchase',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    if (gold22 == null ||
        gold21 == null ||
        gold18 == null ||
        silver22 == null ||
        silver21 == null ||
        silver18 == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off,
                size: 55,
                color: Colors.grey,
              ),
              const SizedBox(height: 15),
              Text(
                _error ??
                    'আজকের বাজারের দাম লোড হচ্ছে...',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('আবার চেষ্টা করুন'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('সোনার দাম'),

          _headerRow(),

          _priceRow(
            karat: '22K',
            perGram: gold22!,
          ),

          _priceRow(
            karat: '21K',
            perGram: gold21!,
          ),

          _priceRow(
            karat: '18K',
            perGram: gold18!,
          ),

          _deductionBox(),

          const SizedBox(height: 5),

          _sectionTitle('পুরাতন সোনার দাম'),

          _headerRow(),

          _priceRow(
            karat: '22K',
            perGram: gold22!,
            oldGold: true,
          ),

          _priceRow(
            karat: '21K',
            perGram: gold21!,
            oldGold: true,
          ),

          _priceRow(
            karat: '18K',
            perGram: gold18!,
            oldGold: true,
          ),

          const SizedBox(height: 25),

          _sectionTitle('রুপার দাম'),

          _headerRow(),

          _priceRow(
            karat: '22K',
            perGram: silver22!,
          ),

          _priceRow(
            karat: '21K',
            perGram: silver21!,
          ),

          _priceRow(
            karat: '18K',
            perGram: silver18!,
          ),

          if (_error != null) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                ),
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

          const SizedBox(height: 20),

          const Text(
            'সূত্র: Gold Price Bangladesh',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 30),
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
            onPressed: _refreshing ? null : _refresh,
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
          : _content(),
    );
  }
}
