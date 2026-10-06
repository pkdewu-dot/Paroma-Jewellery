
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({Key? key}) : super(key: key);

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  static const String _sourceUrl = 'https://www.goldr.org/';

  final TextEditingController _deductionController =
      TextEditingController(text: '18');

  Map<String, int> _goldRates = {};
  Map<String, int> _silverRates = {};

  bool _loading = false;
  String? _error;
  DateTime? _lastUpdated;

  double get _deduction {
    final value = double.tryParse(_deductionController.text.trim());
    if (value == null) return 18;
    return value.clamp(0, 100).toDouble();
  }

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  @override
  void dispose() {
    _deductionController.dispose();
    super.dispose();
  }

  String _englishDigits(String text) {
    const bengali = '০১২৩৪৫৬৭৮৯';
    const english = '0123456789';

    return text.split('').map((character) {
      final index = bengali.indexOf(character);
      return index < 0 ? character : english[index];
    }).join();
  }

  int? _extractTaka(String text) {
    final normalized = _englishDigits(text);

    final match = RegExp(
      r'৳\s*([0-9,]+)',
    ).firstMatch(normalized);

    if (match == null) return null;

    return int.tryParse(
      match.group(1)!.replaceAll(',', ''),
    );
  }

  Map<String, int> _readRates(
    html_parser.Document document, {
    required bool silver,
  }) {
    final result = <String, int>{};

    final rows = document.querySelectorAll('tr');

    for (final row in rows) {
      final cells = row.querySelectorAll('th, td');
      if (cells.length < 2) continue;

      final label = cells.first.text
          .replaceAll('\u00a0', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim()
          .toLowerCase();

      for (final karat in ['22', '21', '18']) {
        final expected = silver
            ? RegExp('$karat\\s*karat\\s*silver')
            : RegExp('$karat\\s*karat\\s*gold');

        if (!expected.hasMatch(label)) continue;

        // প্রথম টাকার ঘরটি বর্তমান বাজারমূল্য।
        int? price;

        for (final cell in cells.skip(1)) {
          final cellText = cell.text.trim();

          if (cellText.contains('৳')) {
            price = _extractTaka(cellText);
            break;
          }
        }

        if (price != null && price > 0) {
          result[karat] = price;
        }
      }
    }

    return result;
  }

  Future<void> _fetchRates() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http
          .get(
            Uri.parse(_sourceUrl),
            headers: const {
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 10) '
                  'AppleWebKit/537.36 Chrome/120.0.0.0 '
                  'Mobile Safari/537.36',
              'Accept':
                  'text/html,application/xhtml+xml,'
                  'application/xml;q=0.9,*/*;q=0.8',
            },
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        throw Exception(
          'GoldR ওয়েবসাইট থেকে তথ্য পাওয়া যায়নি '
          '(HTTP ${response.statusCode})',
        );
      }

      final document = html_parser.parse(
        response.body,
      );

      final gold = _readRates(
        document,
        silver: false,
      );

      final silver = _readRates(
        document,
        silver: true,
      );

      if (gold.length != 3 || silver.length != 3) {
        throw Exception(
          'ওয়েবসাইটের রেট শনাক্ত করা যায়নি। '
          'আবার Refresh করুন।',
        );
      }

      if (!mounted) return;

      setState(() {
        _goldRates = gold;
        _silverRates = silver;
        _lastUpdated = DateTime.now();
        _error = null;
      });
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _error = 'ইন্টারনেট সংযোগ ধীর। আবার চেষ্টা করুন।';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _money(int value) {
    final digits = value.toString();
    return digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  int _afterDeduction(int rate) {
    return (rate * (1 - _deduction / 100)).round();
  }

  String _timeText() {
    if (_lastUpdated == null) return '';

    final time = _lastUpdated!;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return 'সর্বশেষ চেক: $hour:$minute';
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
        bottom: 10,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.amber.shade800,
            size: 25,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rateCard({
    required String title,
    required int? rate,
    required bool showDeduction,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          if (rate == null)
            const Text('রেট পাওয়া যায়নি')
          else ...[
            Row(
              children: [
                const Expanded(
                  child: Text('আজকের বাজার'),
                ),
                Text(
                  '৳${_money(rate)}',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (showDeduction) ...[
              const Divider(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'ডিডাকশন ${_deduction.toStringAsFixed(
                        _deduction.truncateToDouble() ==
                                _deduction
                            ? 0
                            : 2,
                      )}%',
                    ),
                  ),
                  Text(
                    '৳${_money(_afterDeduction(rate))}',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildRates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          '২২ ক্যারেট সোনার আজকের বাজার',
          Icons.diamond_outlined,
        ),
        _rateCard(
          title: '২২K সোনা',
          rate: _goldRates['22'],
          showDeduction: true,
        ),
        _sectionTitle(
          '২১ ক্যারেট সোনার আজকের বাজার',
          Icons.diamond_outlined,
        ),
        _rateCard(
          title: '২১K সোনা',
          rate: _goldRates['21'],
          showDeduction: true,
        ),
        _sectionTitle(
          '১৮ ক্যারেট সোনার আজকের বাজার',
          Icons.diamond_outlined,
        ),
        _rateCard(
          title: '১৮K সোনা',
          rate: _goldRates['18'],
          showDeduction: true,
        ),
        _sectionTitle(
          'আজকের রূপার বাজার',
          Icons.circle_outlined,
        ),
        _rateCard(
          title: '২২K রূপা',
          rate: _silverRates['22'],
          showDeduction: false,
        ),
        _rateCard(
          title: '২১K রূপা',
          rate: _silverRates['21'],
          showDeduction: false,
        ),
        _rateCard(
          title: '১৮K রূপা',
          rate: _silverRates['18'],
          showDeduction: false,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF3),
      appBar: AppBar(
        title: const Text(
          'আজকের বাজার',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'রেট Refresh করুন',
            onPressed: _loading ? null : _fetchRates,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRates,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'পুরান সোনার ডিডাকশন %',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _deductionController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9.]'),
                      ),
                    ],
                    decoration: InputDecoration(
                      hintText: '১৮',
                      suffixText: '%',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Colors.red.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _loading ? null : _fetchRates,
                icon: const Icon(Icons.refresh),
                label: const Text('আবার চেষ্টা করুন'),
              ),
            ],
            if (_goldRates.isNotEmpty &&
                _silverRates.isNotEmpty) ...[
              if (_lastUpdated != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _timeText(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              _buildRates(),
            ],
            if (!_loading &&
                _error == null &&
                _goldRates.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'বাজারের রেট লোড হচ্ছে না। '
                  'Refresh করে আবার চেষ্টা করুন।',
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
