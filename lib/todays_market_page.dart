import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({Key? key}) : super(key: key);

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  WebViewController? _webViewController;

  bool _loading = true;
  String? _error;

  Map<String, dynamic> _prices = {};

  String _selectedUnit = 'ভরি';

  final TextEditingController _deductionController =
      TextEditingController(text: '18');

  @override
  void initState() {
    super.initState();
    _loadCachedPrices();
    _initializeWebView();
  }

  @override
  void dispose() {
    _deductionController.dispose();
    super.dispose();
  }

  Future<void> _loadCachedPrices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('paroma_market_prices');

      if (cached != null && cached.isNotEmpty) {
        final decoded = jsonDecode(cached);

        if (decoded is Map) {
          setState(() {
            _prices = Map<String, dynamic>.from(decoded);
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _savePrices(Map<String, dynamic> prices) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'paroma_market_prices',
        jsonEncode(prices),
      );
    } catch (_) {}
  }

  void _initializeWebView() {
    final controller = WebViewController();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'ParomaGold',
        onMessageReceived: (message) {
          _handleJavaScriptResult(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _loading = true;
                _error = null;
              });
            }
          },
          onPageFinished: (_) {
            _extractPrices();
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                _loading = false;
                if (_prices.isEmpty) {
                  _error =
                      'ইন্টারনেট সংযোগ পাওয়া যাচ্ছে না। আবার চেষ্টা করুন।';
                }
              });
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://www.goldr.org/'),
      );

    setState(() {
      _webViewController = controller;
    });
  }

  Future<void> _extractPrices() async {
    final controller = _webViewController;

    if (controller == null) return;

    const javascript = r'''
(function() {
  function cleanText(value) {
    return (value || '')
      .replace(/\s+/g, ' ')
      .trim();
  }

  function getNumber(text) {
    if (!text) return null;

    var match = text.match(/(?:৳|BDT|Tk\.?)?\s*([0-9][0-9,]*(?:\.[0-9]+)?)/i);

    if (!match) {
      return null;
    }

    return match[1].replace(/,/g, '');
  }

  function findGoldPrice(label) {
    var elements = Array.from(document.querySelectorAll('td, th, div, span, p'));

    for (var i = 0; i < elements.length; i++) {
      var text = cleanText(elements[i].innerText);

      if (!text) continue;

      if (text.includes(label)) {
        var number = getNumber(text);

        if (number) {
          return number;
        }

        var parent = elements[i].parentElement;

        if (parent) {
          var parentNumber = getNumber(cleanText(parent.innerText));

          if (parentNumber) {
            return parentNumber;
          }
        }
      }
    }

    return null;
  }

  function findRowPrice(karat) {
    var rows = Array.from(document.querySelectorAll('tr'));

    for (var i = 0; i < rows.length; i++) {
      var text = cleanText(rows[i].innerText);

      if (!text) continue;

      var lower = text.toLowerCase();

      var matchesKarat =
        lower.includes(karat + ' karat') ||
        lower.includes(karat + 'k') ||
        lower.includes(karat + ' kar') ||
        text.includes(karat + ' ক্যারেট') ||
        text.includes(karat + ' ক্যারেটের');

      if (matchesKarat) {
        var number = getNumber(text);

        if (number) {
          return number;
        }
      }
    }

    return null;
  }

  function collect() {
    var result = {};

    var gold22 =
      findRowPrice('22') ||
      findGoldPrice('22 Karat') ||
      findGoldPrice('22K');

    var gold21 =
      findRowPrice('21') ||
      findGoldPrice('21 Karat') ||
      findGoldPrice('21K');

    var gold18 =
      findRowPrice('18') ||
      findGoldPrice('18 Karat') ||
      findGoldPrice('18K');

    if (gold22) result['gold22'] = gold22;
    if (gold21) result['gold21'] = gold21;
    if (gold18) result['gold18'] = gold18;

    var silver22 =
      findRowPrice('22') ||
      findGoldPrice('22 Silver');

    var silver21 =
      findRowPrice('21') ||
      findGoldPrice('21 Silver');

    var silver18 =
      findRowPrice('18') ||
      findGoldPrice('18 Silver');

    if (silver22) result['silver22'] = silver22;
    if (silver21) result['silver21'] = silver21;
    if (silver18) result['silver18'] = silver18;

    result['updatedAt'] = new Date().toISOString();

    return result;
  }

  var attempts = 0;

  function tryExtract() {
    attempts++;

    var result = collect();

    if (
      result['gold22'] ||
      result['gold21'] ||
      result['gold18']
    ) {
      window.ParomaGold.postMessage(JSON.stringify(result));
      return;
    }

    if (attempts < 20) {
      setTimeout(tryExtract, 750);
    } else {
      window.ParomaGold.postMessage(
        JSON.stringify({
          error: 'PRICE_NOT_FOUND'
        })
      );
    }
  }

  setTimeout(tryExtract, 500);
})();
''';

    try {
      await controller.runJavaScript(javascript);
    } catch (_) {
      if (mounted && _prices.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'বাজারের তথ্য লোড করা যাচ্ছে না।';
        });
      }
    }
  }

  Future<void> _handleJavaScriptResult(String message) async {
    try {
      final decoded = jsonDecode(message);

      if (decoded is! Map) return;

      if (decoded['error'] != null) {
        if (mounted) {
          setState(() {
            _loading = false;

            if (_prices.isEmpty) {
              _error =
                  'বর্তমানে বাজারের তথ্য পাওয়া যাচ্ছে না। কিছুক্ষণ পরে আবার চেষ্টা করুন।';
            }
          });
        }

        return;
      }

      final result = Map<String, dynamic>.from(decoded);

      if (result.isEmpty) return;

      await _savePrices(result);

      if (!mounted) return;

      setState(() {
        _prices = result;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;

          if (_prices.isEmpty) {
            _error = 'তথ্য পড়তে সমস্যা হয়েছে। আবার চেষ্টা করুন।';
          }
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
      await _webViewController?.reload();
    } catch (_) {
      _initializeWebView();
    }
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;

    return double.tryParse(
      value.toString().replaceAll(',', '').trim(),
    );
  }

  String _formatPrice(dynamic value) {
    final number = _toDouble(value);

    if (number == null) {
      return '—';
    }

    if (number == number.roundToDouble()) {
      return '৳${number.toStringAsFixed(0)}';
    }

    return '৳${number.toStringAsFixed(2)}';
  }

  String _getPrice(String key) {
    final value = _prices[key];

    if (value == null) {
      return '—';
    }

    return _formatPrice(value);
  }

  String _updatedText() {
    final value = _prices['updatedAt'];

    if (value == null) {
      return 'সর্বশেষ তথ্য';
    }

    try {
      final date = DateTime.parse(value.toString()).toLocal();

      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return 'সর্বশেষ আপডেট: ${date.day}/${date.month}/${date.year} $hour:$minute';
    } catch (_) {
      return 'সর্বশেষ তথ্য';
    }
  }

  Widget _priceCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.amber[800],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.amber[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goldSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.amber.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.workspace_premium,
                color: Colors.amber,
              ),
              SizedBox(width: 8),
              Text(
                'সোনার বাজার মূল্য',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _priceCard(
            title: '২২ ক্যারেট সোনা',
            value: _getPrice('gold22'),
            icon: Icons.circle,
          ),
          _priceCard(
            title: '২১ ক্যারেট সোনা',
            value: _getPrice('gold21'),
            icon: Icons.circle,
          ),
          _priceCard(
            title: '১৮ ক্যারেট সোনা',
            value: _getPrice('gold18'),
            icon: Icons.circle,
          ),
        ],
      ),
    );
  }

  Widget _silverSection() {
    final hasSilver =
        _prices['silver22'] != null ||
        _prices['silver21'] != null ||
        _prices['silver18'] != null;

    if (!hasSilver) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.circle_outlined,
                color: Colors.grey,
              ),
              SizedBox(width: 8),
              Text(
                'রুপার বাজার মূল্য',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _priceCard(
            title: '২২ ক্যারেট রুপা',
            value: _getPrice('silver22'),
            icon: Icons.circle_outlined,
          ),
          _priceCard(
            title: '২১ ক্যারেট রুপা',
            value: _getPrice('silver21'),
            icon: Icons.circle_outlined,
          ),
          _priceCard(
            title: '১৮ ক্যারেট রুপা',
            value: _getPrice('silver18'),
            icon: Icons.circle_outlined,
          ),
        ],
      ),
    );
  }

  Widget _deductionBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'পুরাতন সোনার কর্তন',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: TextField(
              controller: _deductionController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                suffixText: '%',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _unitSelector() {
    const units = [
      'ভরি',
      'আনা',
      'রতি',
      'পয়েন্ট',
      'গ্রাম',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: units.map((unit) {
          final selected = _selectedUnit == unit;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(unit),
              selected: selected,
              selectedColor: Colors.amber[800],
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) {
                setState(() {
                  _selectedUnit = unit;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'আজকের বাজার',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
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
                _unitSelector(),
                const SizedBox(height: 16),
                _deductionBox(),
                _goldSection(),
                _silverSection(),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    _updatedText(),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                const Center(
                  child: Text(
                    'Source: GoldR.org',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // Hidden WebView used only to load live GoldR data.
          if (_webViewController != null)
            Positioned(
              left: -10,
              top: -10,
              width: 1,
              height: 1,
              child: Opacity(
                opacity: 0.01,
                child: WebViewWidget(
                  controller: _webViewController!,
                ),
              ),
            ),

          if (_loading && _prices.isEmpty)
            const Center(
              child: CircularProgressIndicator(),
            ),

          if (_error != null && _prices.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 50,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('আবার চেষ্টা করুন'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
