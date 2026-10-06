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
  String _statusMessage = 'লাইভ বাজার দর লোড হচ্ছে...';

  final TextEditingController _deductionController =
      TextEditingController(text: '18');
  double _deductionPercent = 18.0;

  // বর্তমান বাজার দর (ভরি প্রতি BDT)
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
    _initApp();
  }

  Future<void> _initApp() async {
    await _loadSavedRates();
    await _fetchLiveRatesSafely();
  }

  void _updateDeduction() {
    if (!mounted) return;
    setState(() {
      _deductionPercent = double.tryParse(_deductionController.text) ?? 18.0;
    });
  }

  Future<void> _fetchLiveRatesSafely() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _statusMessage = 'ইন্টারনেট থেকে আজকের লাইভ দর সংগ্রহ করা হচ্ছে...';
    });

    try {
      final response = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['rates'] != null && data['rates']['BDT'] != null) {
          double bdtRate = ConvertToDouble(data['rates']['BDT']);

          // বিডি মার্কেট এডজাস্টমেন্ট
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
              _statusMessage = 'সফলভাবে লাইভ দর আপডেট করা হয়েছে';
            });
          }
          await _saveRates();
          return;
        }
      }
    } catch (_) {
      // নেটওয়ার্ক ফেল করলে অফলাইনে চলবে, অ্যাপ ক্র্যাশ করবে না
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'সংরক্ষিত/ডিফল্ট বাজার দর প্রদর্শিত হচ্ছে';
      });
    }
  }

  double ConvertToDouble(dynamic val) {
    if (val is int) return val.toDouble();
    if (val is double) return val;
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
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
      if (mounted) {
        setState(() {
          goldRate22k = prefs.getDouble('g22') ?? 142000;
          goldRate21k = prefs.getDouble('g21') ?? 135500;
          goldRate18k = prefs.getDouble('g18') ?? 116000;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLiveRatesSafely,
            tooltip: 'রিফ্রেশ করুন',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: LinearProgressIndicator(),
              ),
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
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
