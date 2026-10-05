import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({Key? key}) : super(key: key);

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  late final WebViewController _webViewController;
  
  bool _isLoading = true;
  String _errorMessage = '';

  // ডিডাকশন পার্সেন্টেজ কন্ট্রোলার (বাই ডিফল্ট ১৮%)
  final TextEditingController _deductionController =
      TextEditingController(text: '18');
  double _deductionPercent = 18.0;

  // সোনার বেজ রেট
  double goldRate22k = 230772;
  double goldRate21k = 220391;
  double goldRate18k = 189248;

  // রূপার বেজ রেট
  double silverRate22k = 4316;
  double silverRate21k = 4141;
  double silverRate18k = 3558;

  @override
  void initState() {
    super.initState();
    _deductionController.addListener(_updateDeduction);
    _initWebView();
  }

  void _updateDeduction() {
    setState(() {
      _deductionPercent = double.tryParse(_deductionController.text) ?? 0.0;
    });
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _extractGoldRates();
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://goldr.live/'));
  }

  Future<void> _extractGoldRates() async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      final String rawData = await _webViewController.runJavaScriptReturningResult('''
        (function() {
          return document.body.innerText;
        })();
      ''') as String;

      _parseRatesFromText(rawData);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _parseRatesFromText(String text) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double _calculateDeductedPrice(double basePrice) {
    return basePrice - (basePrice * (_deductionPercent / 100));
  }

  @override
  void dispose() {
    _deductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আজকের বাজার'),
        backgroundColor: Colors.amber[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _webViewController.reload();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('GoldR থেকে লাইভ রেট লোড হচ্ছে...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      style: const TextStyle(color: Colors.red),
                      child: Text(_errorMessage),
                    ),

                  // ১. পুরান সোনার ডিডাকশন % ইনপুট
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
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
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: _deductionController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ২. ২২ ক্যারেট সোনার আজকের বাজার
                  _buildGoldSection(
                    headline: '২২ ক্যারেট সোনার আজকের বাজার',
                    karatLabel: '২২K',
                    basePrice: goldRate22k,
                  ),

                  // ৩. ২১ ক্যারেট সোনার আজকের বাজার
                  _buildGoldSection(
                    headline: '২১ ক্যারেট সোনার আজকের বাজার',
                    karatLabel: '২১K',
                    basePrice: goldRate21k,
                  ),

                  // ৪. ১৮ ক্যারেট সোনার আজকের বাজার
                  _buildGoldSection(
                    headline: '১৮ ক্যারেট সোনার আজকের বাজার',
                    karatLabel: '১৮K',
                    basePrice: goldRate18k,
                  ),

                  // ৫. আজকের রূপার বাজার
                  const Text(
                    'আজকের রূপার বাজার',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '২২K: ৳${silverRate22k.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '২১K: ৳${silverRate21k.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '১৮K: ৳${silverRate18k.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGoldSection({
    required String headline,
    required String karatLabel,
    required double basePrice,
  }) {
    double deductedPrice = _calculateDeductedPrice(basePrice);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headline,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.amber[900],
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$karatLabel: ৳${basePrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$karatLabel: ৳${deductedPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
