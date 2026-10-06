import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({Key? key}) : super(key: key);

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  bool _isLoading = false;
  String _statusMessage = 'লাইভ দর দেখতে নিচের বাটনে চাপুন';

  final TextEditingController _deductionController =
      TextEditingController(text: '18');
  double _deductionPercent = 18.0;

  // ব্যাকআপ ও ডিফল্ট বাজার দর
  double goldRate22k = 142000;
  double goldRate21k = 135500;
  double goldRate18k = 116000;

  double silverRate22k = 2100;
  double silverRate21k = 2000;
  double silverRate18k = 1750;

  @override
  void initState() {
    super.initState();
    _deductionController.addListener(_updateDeduction);
    _loadSavedRates();
  }

  void _updateDeduction() {
    if (!mounted) return;
    final val = double.tryParse(_deductionController.text);
    if (val != null) {
      setState(() {
        _deductionPercent = val;
      });
    }
  }

  Future<void> _fetchLiveRatesSafely() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'ইন্টারনেট থেকে বাজার দর আপডেট হচ্ছে...';
    });

    try {
      final response = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('rates') && data['rates'] != null) {
          final rates = data['rates'];
          if (rates is Map && rates.containsKey('BDT')) {
            double bdtRate = 0.0;
            var rawBdt = rates['BDT'];
            if (rawBdt is num) {
              bdtRate = rawBdt.toDouble();
            } else if (rawBdt is String) {
              bdtRate = double.tryParse(rawBdt) ?? 0.0;
            }

            if (bdtRate > 0) {
              double base22k = bdtRate * 1180;

              if (mounted) {
                setState(() {
                  goldRate22k = base22k;
                  goldRate21k = base22k * (21 / 22);
                  goldRate18k = base22k * (18 / 22);

                  silverRate22k = base22k * 0.015;
                  silverRate21k = silverRate22k * (21 / 22);
                  silverRate18k = silverRate22k * (18 / 22);

                  _isLoading = false;
                  _statusMessage = 'লাইভ দর সফলভাবে আপডেট করা হয়েছে';
                });
              }
              _saveRates();
              return;
            }
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'ইন্টারনেট কানেকশন চেক করে আবার চেষ্টা করুন';
      });
    }
  }

  Future<void> _saveRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('g22', goldRate22k);
      await prefs.setDouble('g21', goldRate21k);
      await prefs.setDouble('g18', goldRate18k);
    } catch (_) {}
  }

  Future<void> _loadSavedRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      double? g22 = prefs.getDouble('g22');
      double? g21 = prefs.getDouble('g21');
      double? g18 = prefs.getDouble('g18');

      if (mounted && g22 != null && g21 != null && g18 != null) {
        setState(() {
          goldRate22k = g22;
          goldRate21k = g21;
          goldRate18k = g18;
          silverRate22k = goldRate22k * 0.015;
          silverRate21k = silverRate22k * (21 / 22);
          silverRate18k = silverRate22k * (18 / 22);
        });
      }
    } catch (_) {}
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Sync Button
            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _statusMessage,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _fetchLiveRatesSafely,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(_isLoading ? 'অপেক্ষা...' : 'লাইভ দর আনুন'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[800],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Puran Gold Deduction Input
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

            // 22K Gold
            _buildGoldSection(
              headline: '২২ ক্যারেট সোনার আজকের বাজার',
              karatLabel: '২২K',
              basePrice: goldRate22k,
            ),

            // 21K Gold
            _buildGoldSection(
              headline: '২১ ক্যারেট সোনার আজকের বাজার',
              karatLabel: '২১K',
              basePrice: goldRate21k,
            ),

            // 18K Gold
            _buildGoldSection(
              headline: '১৮ ক্যারেট সোনার আজকের বাজার',
              karatLabel: '১৮K',
              basePrice: goldRate18k,
            ),

            // Silver Section
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
                      '২২K: ৳${silverRate22k.toStringAsFixed(0)} /ভরি',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '২১K: ৳${silverRate21k.toStringAsFixed(0)} /ভরি',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '১৮K: ৳${silverRate18k.toStringAsFixed(0)} /ভরি',
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
                  'নতুন সোনা ($karatLabel): ৳${basePrice.toStringAsFixed(0)} /ভরি',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'পুরান সোনা ($karatLabel): ৳${deductedPrice.toStringAsFixed(0)} /ভরি (${_deductionPercent.toStringAsFixed(0)}% বাদ)',
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
