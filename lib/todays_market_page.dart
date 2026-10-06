
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({Key? key}) : super(key: key);

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  late final WebViewController _web;

  final TextEditingController _deduction =
      TextEditingController(text: '18');

  final Map<String, int> _gold = {};
  final Map<String, int> _silver = {};

  bool _loading = true;
  bool _pageReady = false;
  bool _reading = false;
  String? _error;
  DateTime? _updated;
  Timer? _timer;

  double get _percent {
    final value = double.tryParse(_deduction.text.trim());
    if (value == null) return 18;
    return value.clamp(0, 100).toDouble();
  }

  @override
  void initState() {
    super.initState();

    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'GoldRates',
        onMessageReceived: (message) => _receive(message.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            _pageReady = false;
            if (mounted) {
              setState(() {
                _loading = true;
                _error = null;
              });
            }
          },
          onPageFinished: (_) {
            _pageReady = true;
            _scheduleRead();
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted) {
              setState(() {
                _loading = false;
                _error = 'GoldR খুলতে সমস্যা হয়েছে। ইন্টারনেট পরীক্ষা করুন।';
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.goldr.org/'));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _deduction.dispose();
    super.dispose();
  }

  void _scheduleRead() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), _readRates);
  }

  Future<void> _readRates() async {
    if (!_pageReady || _reading) return;
    _reading = true;

    const js = r'''
(function () {
  function englishDigits(s) {
    return String(s).replace(/[০-৯]/g, function (d) {
      return String('০১২৩৪৫৬৭৮৯'.indexOf(d));
    });
  }

  function takaValues(s) {
    const text = englishDigits(s);
    const matches = text.match(/৳\s*[0-9,]+(?:\.[0-9]+)?/g) || [];
    return matches.map(function (x) {
      return Number(x.replace(/৳/g, '').replace(/,/g, '').trim());
    }).filter(function (x) {
      return Number.isFinite(x) && x > 0;
    });
  }

  const result = { gold: {}, silver: {} };
  const keys = ['22', '21', '18'];

  document.querySelectorAll('tr').forEach(function (row) {
    const cells = Array.from(row.querySelectorAll('th, td'));
    if (cells.length < 2) return;

    const label = englishDigits(cells[0].innerText || '')
      .replace(/\s+/g, ' ')
      .trim()
      .toLowerCase();

    const goldMatch = label.match(/(22|21|18)\s*karat\s*gold/);
    const silverMatch = label.match(/(22|21|18)\s*karat\s*silver/);
    if (!goldMatch && !silverMatch) return;

    const prices = takaValues(cells.slice(1).map(function (c) {
      return c.innerText || '';
    }).join(' '));

    if (!prices.length) return;

    const price = Math.max.apply(null, prices);
    const group = goldMatch ? 'gold' : 'silver';
    const karat = (goldMatch || silverMatch)[1];

    if (!result[group][karat] || price > result[group][karat]) {
      result[group][karat] = price;
    }
  });

  GoldRates.postMessage(JSON.stringify(result));
})();
''';

    try {
      await _web.runJavaScript(js);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'রেট পড়া যায়নি। Refresh করে আবার চেষ্টা করুন।';
        });
      }
    } finally {
      _reading = false;
    }
  }

  void _receive(String message) {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final rawGold = Map<String, dynamic>.from(data['gold'] ?? {});
      final rawSilver = Map<String, dynamic>.from(data['silver'] ?? {});

      final gold = <String, int>{};
      final silver = <String, int>{};

      for (final k in ['22', '21', '18']) {
        final g = rawGold[k];
        final s = rawSilver[k];

        if (g is num && g > 0) gold[k] = g.round();
        if (s is num && s > 0) silver[k] = s.round();
      }

      if (gold.length != 3 || silver.length != 3) {
        if (mounted) {
          setState(() {
            _loading = false;
            _error =
                'সব রেট পাওয়া যায়নি। GoldR-এর পেজের কাঠামো বদলে থাকতে পারে।';
          });
        }
        return;
      }

      if (!mounted) return;

      setState(() {
        _gold
          ..clear()
          ..addAll(gold);
        _silver
          ..clear()
          ..addAll(silver);
        _updated = DateTime.now();
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'রেটের তথ্য বুঝতে সমস্যা হয়েছে। আবার Refresh করুন।';
        });
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _web.reload();
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Refresh করা যায়নি।';
        });
      }
    }
  }

  int _oldPrice(int rate) => (rate * (1 - _percent / 100)).round();

  String _money(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }

  Widget _heading(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber.shade800),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rateCard(String title, int? rate, {bool deduction = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 10),
          if (rate == null)
            const Text('রেট পাওয়া যায়নি')
          else ...[
            _priceLine('আজকের বাজার', rate),
            if (deduction) ...[
              const Divider(height: 24),
              _priceLine(
                'ডিডাকশন ${_percent.toStringAsFixed(_percent % 1 == 0 ? 0 : 2)}%',
                _oldPrice(rate),
                color: Colors.green.shade800,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _priceLine(String label, int value, {Color? color}) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          '৳${_money(value)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _ratesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('২২ ক্যারেট সোনার আজকের বাজার', Icons.diamond_outlined),
        _rateCard('২২K সোনা', _gold['22'], deduction: true),
        _heading('২১ ক্যারেট সোনার আজকের বাজার', Icons.diamond_outlined),
        _rateCard('২১K সোনা', _gold['21'], deduction: true),
        _heading('১৮ ক্যারেট সোনার আজকের বাজার', Icons.diamond_outlined),
        _rateCard('১৮K সোনা', _gold['18'], deduction: true),
        _heading('আজকের রূপার বাজার', Icons.circle_outlined),
        _rateCard('২২K রূপা', _silver['22']),
        _rateCard('২১K রূপা', _silver['21']),
        _rateCard('১৮K রূপা', _silver['18']),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF3),
      appBar: AppBar(
        title: const Text('আজকের বাজার'),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'রেট Refresh করুন',
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
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
                        controller: _deduction,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.]'),
                          ),
                        ],
                        decoration: InputDecoration(
                          suffixText: '%',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('আবার চেষ্টা করুন'),
                  ),
                ],
                if (_gold.isNotEmpty && _silver.isNotEmpty) ...[
                  if (_updated != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'সর্বশেষ চেক: '
                        '${_updated!.hour.toString().padLeft(2, '0')}:'
                        '${_updated!.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  _ratesList(),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            width: 2,
            height: 2,
            child: WebViewWidget(controller: _web),
          ),
        ],
      ),
    );
  }
}
