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
  static const String _goldApi =
      'https://gold-price.bd/api/gold/latest.json';

  static const String _silverApi =
      'https://gold-price.bd/api/silver/latest.json';

  // Bangladesh jewellery measurement:
  // 1 bhori = 11.664 g
  // 1 bhori = 16 ana
  // 1 bhori = 96 rati
  // 1 bhori = 960 point
  static const double _gramsPerBhori = 11.664;
  static const double _anaPerBhori = 16;
  static const double _ratiPerBhori = 96;
  static const double _pointPerBhori = 960;

  static const List<String> _carats = ['22', '21', '18'];

  final TextEditingController _deductionController =
      TextEditingController(text: '18');

  bool _isLoading = true;
  bool _isRefreshing = false;

  String? _errorMessage;
  String? _goldError;
  String? _silverError;

  DateTime? _lastUpdated;

  String? _goldSourceUpdate;
  String? _silverSourceUpdate;

  // API gives BDT per gram.
  final Map<String, double> _goldPerGram = {};
  final Map<String, double> _silverPerGram = {};

  @override
  void initState() {
    super.initState();
    _loadCachedDataAndFetch();
  }

  @override
  void dispose() {
    _deductionController.dispose();
    super.dispose();
  }

  Future<void> _loadCachedDataAndFetch() async {
    await _loadCachedData();
    await _fetchMarketData();
  }

  // ------------------------------------------------------------
  // CACHE
  // ------------------------------------------------------------

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final goldJson = prefs.getString('paroma_gold_per_gram');
      final silverJson = prefs.getString('paroma_silver_per_gram');

      final updated = prefs.getString('paroma_market_updated');

      final goldUpdate =
          prefs.getString('paroma_gold_source_update');

      final silverUpdate =
          prefs.getString('paroma_silver_source_update');

      if (goldJson == null && silverJson == null) {
        return;
      }

      final gold = goldJson == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(
              jsonDecode(goldJson),
            );

      final silver = silverJson == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(
              jsonDecode(silverJson),
            );

      final parsedUpdated =
          updated == null ? null : DateTime.tryParse(updated);

      if (!mounted) return;

      setState(() {
        _goldPerGram
          ..clear()
          ..addAll(_parseNumberMap(gold));

        _silverPerGram
          ..clear()
          ..addAll(_parseNumberMap(silver));

        _lastUpdated = parsedUpdated;

        _goldSourceUpdate = goldUpdate;
        _silverSourceUpdate = silverUpdate;
      });
    } catch (_) {
      // Bad cache must never stop network fetching.
    }
  }

  Map<String, double> _parseNumberMap(
    Map<String, dynamic> source,
  ) {
    final result = <String, double>{};

    for (final entry in source.entries) {
      final value = entry.value;

      if (value is num && value > 0) {
        result[entry.key] = value.toDouble();
      }
    }

    return result;
  }

  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'paroma_gold_per_gram',
        jsonEncode(_goldPerGram),
      );

      await prefs.setString(
        'paroma_silver_per_gram',
        jsonEncode(_silverPerGram),
      );

      if (_lastUpdated != null) {
        await prefs.setString(
          'paroma_market_updated',
          _lastUpdated!.toIso8601String(),
        );
      }

      if (_goldSourceUpdate != null) {
        await prefs.setString(
          'paroma_gold_source_update',
          _goldSourceUpdate!,
        );
      }

      if (_silverSourceUpdate != null) {
        await prefs.setString(
          'paroma_silver_source_update',
          _silverSourceUpdate!,
        );
      }
    } catch (_) {}
  }

  // ------------------------------------------------------------
  // API FETCH
  // ------------------------------------------------------------

  Future<void> _fetchMarketData() async {
    if (_isRefreshing) return;

    if (mounted) {
      setState(() {
        _isRefreshing = true;

        _errorMessage = null;
        _goldError = null;
        _silverError = null;

        if (_goldPerGram.length < 3 &&
            _silverPerGram.length < 3) {
          _isLoading = true;
        }
      });
    }

    // Gold and Silver are fetched independently.
    final results = await Future.wait([
      _fetchMetal(_goldApi, 'gold'),
      _fetchMetal(_silverApi, 'silver'),
    ]);

    final goldResult = results[0];
    final silverResult = results[1];

    if (!mounted) return;

    setState(() {
      _isRefreshing = false;
      _isLoading = false;

      // GOLD
      if (goldResult.data != null &&
          goldResult.data!.length >= 3) {
        _goldPerGram
          ..clear()
          ..addAll(goldResult.data!);

        _goldSourceUpdate = goldResult.lastUpdate;
      } else if (goldResult.error != null) {
        _goldError = goldResult.error;
      }

      // SILVER
      if (silverResult.data != null &&
          silverResult.data!.length >= 3) {
        _silverPerGram
          ..clear()
          ..addAll(silverResult.data!);

        _silverSourceUpdate = silverResult.lastUpdate;
      } else if (silverResult.error != null) {
        _silverError = silverResult.error;
      }

      if (_goldPerGram.length >= 3 ||
          _silverPerGram.length >= 3) {
        _lastUpdated = DateTime.now();
      }

      // Nothing received at all.
      if (_goldPerGram.length < 3 &&
          _silverPerGram.length < 3) {
        _errorMessage =
            'আজকের বাজারের তথ্য এখন পাওয়া যাচ্ছে না।\n'
            'ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';
      }
    });

    if (_goldPerGram.length >= 3 ||
        _silverPerGram.length >= 3) {
      await _saveCache();
    }
  }

  Future<_MetalResult> _fetchMetal(
    String url,
    String metal,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: const {
              'Accept': 'application/json',
              'Cache-Control': 'no-cache',
            },
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode != 200) {
        return _MetalResult(
          error:
              '${metal == 'gold' ? 'Gold' : 'Silver'} API HTTP ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return _MetalResult(
          error:
              '${_capitalise(metal)} API returned invalid JSON',
        );
      }

      final latest = decoded['latest'];

      if (latest is! Map) {
        return _MetalResult(
          error:
              '${_capitalise(metal)} API: latest data missing',
        );
      }

      final data = <String, double>{};

      for (final carat in _carats) {
        final value = latest['k$carat'];

        if (value is num && value > 0) {
          data[carat] = value.toDouble();
        } else if (value is String) {
          final parsed = double.tryParse(
            value.replaceAll(',', '').trim(),
          );

          if (parsed != null && parsed > 0) {
            data[carat] = parsed;
          }
        }
      }

      if (data.length < 3) {
        return _MetalResult(
          error:
              '${_capitalise(metal)} API: 22K/21K/18K data missing',
        );
      }

      return _MetalResult(
        data: data,
        lastUpdate: decoded['lastUpdate']?.toString(),
      );
    } catch (e) {
      return _MetalResult(
        error:
            '${_capitalise(metal)} API: ${_shortError(e)}',
      );
    }
  }

  String _capitalise(String value) {
    if (value.isEmpty) return value;

    return value[0].toUpperCase() +
        value.substring(1);
  }

  String _shortError(Object error) {
    if (error is http.ClientException) {
      return 'network error';
    }

    if (error.toString().contains(
          'TimeoutException',
        )) {
      return 'timeout';
    }

    return 'connection failed';
  }

  // ------------------------------------------------------------
  // CALCULATION
  // ------------------------------------------------------------

  double get _deductionPercent {
    final value = double.tryParse(
      _normalizeDigits(
        _deductionController.text,
      ).replaceAll(',', '.'),
    );

    if (value == null) return 18;

    return value.clamp(0, 100).toDouble();
  }

  double _rateForUnit(
    double perGram,
    String unit,
  ) {
    switch (unit) {
      case 'ভরি':
        return perGram * _gramsPerBhori;

      case 'আনা':
        return perGram *
            (_gramsPerBhori / _anaPerBhori);

      case 'রতি':
        return perGram *
            (_gramsPerBhori / _ratiPerBhori);

      case 'পয়েন্ট':
        return perGram *
            (_gramsPerBhori / _pointPerBhori);

      case 'গ্রাম':
      default:
        return perGram;
    }
  }

  double _oldGoldRate(double perGram) {
    return perGram *
        (1 - (_deductionPercent / 100));
  }

  // ------------------------------------------------------------
  // NUMBER FORMATTING
  // ------------------------------------------------------------

  String _normalizeDigits(String value) {
    const bangla = '০১২৩৪৫৬৭৮৯';
    const english = '0123456789';

    var result = value;

    for (var i = 0; i < bangla.length; i++) {
      result = result.replaceAll(
        bangla[i],
        english[i],
      );
    }

    return result;
  }

  String _money(double value) {
    final rounded = value.roundToDouble();

    final display =
        (value - rounded).abs() < 0.005
            ? value.toStringAsFixed(0)
            : value.toStringAsFixed(2);

    final parts = display.split('.');

    var integerPart = parts[0];

    final sign =
        integerPart.startsWith('-') ? '-' : '';

    integerPart =
        integerPart.replaceFirst('-', '');

    if (integerPart.length > 3) {
      final lastThree =
          integerPart.substring(
        integerPart.length - 3,
      );

      var remaining =
          integerPart.substring(
        0,
        integerPart.length - 3,
      );

      final chunks = <String>[];

      while (remaining.length > 2) {
        chunks.insert(
          0,
          remaining.substring(
            remaining.length - 2,
          ),
        );

        remaining = remaining.substring(
          0,
          remaining.length - 2,
        );
      }

      if (remaining.isNotEmpty) {
        chunks.insert(0, remaining);
      }

      integerPart =
          '${chunks.join(',')},$lastThree';
    }

    final formatted =
        parts.length > 1 &&
                parts[1] != '00'
            ? '$sign$integerPart.${parts[1]}'
            : '$sign$integerPart';

    return '৳${_toBanglaDigit(formatted)}';
  }

  String _toBanglaDigit(String input) {
    const english = [
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
    ];

    const bangla = [
      '০',
      '১',
      '২',
      '৩',
      '৪',
      '৫',
      '৬',
      '৭',
      '৮',
      '৯',
    ];

    var result = input;

    for (var i = 0; i < english.length; i++) {
      result = result.replaceAll(
        english[i],
        bangla[i],
      );
    }

    return result;
  }

  String _formatSourceUpdate(String? value) {
    if (value == null || value.isEmpty) {
      return 'উৎসের সময় পাওয়া যায়নি';
    }

    final date = DateTime.tryParse(value);

    if (date == null) return value;

    final local = date.toLocal();

    final dateText =
        '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';

    return 'উৎস আপডেট: ${_toBanglaDigit(dateText)}';
  }

  String _formatDateTime(
    DateTime dateTime,
  ) {
    final d =
        dateTime.day.toString().padLeft(2, '0');

    final m =
        dateTime.month.toString().padLeft(2, '0');

    final y =
        dateTime.year.toString();

    final h =
        dateTime.hour % 12 == 0
            ? 12
            : dateTime.hour % 12;

    final min =
        dateTime.minute.toString().padLeft(2, '0');

    final period =
        dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${_toBanglaDigit('$d/$m/$y')} '
        '${_toBanglaDigit('$h:$min')} '
        '$period';
  }

  // ------------------------------------------------------------
  // MAIN UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final hasGold =
        _goldPerGram.length >= 3;

    final hasSilver =
        _silverPerGram.length >= 3;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF9F6F0),

      appBar: AppBar(
        title: const Text(
          'আজকের বাজার',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor:
            const Color(0xFF8B0000),

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                _isRefreshing
                    ? null
                    : _fetchMarketData,

            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.refresh,
                  ),
          ),
        ],
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: Color(0xFF8B0000),
              ),
            )
          : RefreshIndicator(
              color:
                  const Color(0xFF8B0000),

              onRefresh:
                  _fetchMarketData,

              child:
                  SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.fromLTRB(
                  10,
                  14,
                  10,
                  24,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,

                  children: [
                    if (_errorMessage != null) ...[
                      _buildErrorBanner(),
                      const SizedBox(height: 10),
                    ],

                    _buildUnitHeader(),

                    const SizedBox(height: 10),

                    _buildDeductionBox(),

                    const SizedBox(height: 12),

                    if (hasGold)
                      _buildGoldTable()
                    else
                      _buildUnavailableCard(
                        'সোনার দাম এখন পাওয়া যাচ্ছে না',
                      ),

                    const SizedBox(height: 16),

                    if (hasSilver)
                      _buildSilverTable()
                    else
                      _buildUnavailableCard(
                        'রুপার দাম এখন পাওয়া যাচ্ছে না',
                      ),

                    const SizedBox(height: 14),

                    if (_lastUpdated != null)
                      Text(
                        'অ্যাপে সর্বশেষ সফল আপডেট: '
                        '${_formatDateTime(_lastUpdated!)}',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color:
                              Colors.grey.shade700,
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                    const SizedBox(height: 5),

                    const Text(
                      'দামের উৎস: Gold Price Bangladesh '
                      '(BAJUS-based records)',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),

                    if (_goldSourceUpdate != null) ...[
                      const SizedBox(height: 3),

                      Text(
                        _formatSourceUpdate(
                          _goldSourceUpdate,
                        ),
                        textAlign:
                            TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 9,
                        ),
                      ),
                    ],

                    if (_goldError != null ||
                        _silverError != null) ...[
                      const SizedBox(height: 8),

                      Text(
                        'একটি source unavailable হলে '
                        'cached/অন্য metal-এর data '
                        'দেখানো হচ্ছে।',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color:
                              Colors.orange.shade800,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  // ------------------------------------------------------------
  // ERROR BANNER
  // ------------------------------------------------------------

  Widget _buildErrorBanner() {
    return Container(
      padding:
          const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.red.shade50,

        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color: Colors.red.shade100,
        ),
      ),

      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            color: Colors.red.shade700,
            size: 22,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade900,
                fontWeight:
                    FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),

          TextButton(
            onPressed:
                _isRefreshing
                    ? null
                    : _fetchMarketData,

            child:
                const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // UNIT HEADER
  // ------------------------------------------------------------

  Widget _buildUnitHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        border: Border.all(
          color: const Color(0xFFD0D0D0),
        ),
      ),

      child: Row(
        children: [
          'ভরি',
          'আনা',
          'রতি',
          'পয়েন্ট',
          'গ্রাম',
        ]
            .map(
              (unit) => Expanded(
                child: Container(
                  height: 36,

                  alignment:
                      Alignment.center,

                  decoration:
                      const BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color:
                            Color(0xFFD0D0D0),
                      ),
                    ),
                  ),

                  child: Text(
                    unit,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ------------------------------------------------------------
  // DEDUCTION
  // ------------------------------------------------------------

  Widget _buildDeductionBox() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),

      decoration:
          BoxDecoration(
        color: Colors.transparent,

        borderRadius:
            BorderRadius.circular(8),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,

        children: [
          const Text(
            'Deduction %:',
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 12,
            ),
          ),

          const SizedBox(width: 5),

          SizedBox(
            width: 58,
            height: 34,

            child: TextField(
              controller:
                  _deductionController,

              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),

              textAlign:
                  TextAlign.center,

              onChanged: (_) =>
                  setState(() {}),

              decoration:
                  const InputDecoration(
                suffixText: '%',

                contentPadding:
                    EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 5,
                ),

                border:
                    OutlineInputBorder(),

                isDense: true,
              ),

              style:
                  const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 7),

          const Expanded(
            child: Text(
              '(Only for old gold purchase)',
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // GOLD
  // ------------------------------------------------------------

  Widget _buildGoldTable() {
    return _buildMarketSection(
      title: 'সোনার দাম',

      rows: _carats.map(
        (carat) {
          final perGram =
              _goldPerGram[carat]!;

          return _buildRateRow(
            '${carat}K:',
            perGram,
            oldGold: true,
          );
        },
      ).toList(),
    );
  }

  // ------------------------------------------------------------
  // SILVER
  // ------------------------------------------------------------

  Widget _buildSilverTable() {
    return _buildMarketSection(
      title: 'রুপার দাম',

      rows: _carats.map(
        (carat) {
          final perGram =
              _silverPerGram[carat]!;

          return _buildRateRow(
            '${carat}K:',
            perGram,
            oldGold: false,
          );
        },
      ).toList(),
    );
  }

  // ------------------------------------------------------------
  // RATE ROW
  // ------------------------------------------------------------

  Widget _buildRateRow(
    String label,
    double perGram, {
    required bool oldGold,
  }) {
    final values = <String>[
      _money(
        _rateForUnit(
          perGram,
          'ভরি',
        ),
      ),

      _money(
        _rateForUnit(
          perGram,
          'আনা',
        ),
      ),

      _money(
        _rateForUnit(
          perGram,
          'রতি',
        ),
      ),

      _money(
        _rateForUnit(
          perGram,
          'পয়েন্ট',
        ),
      ),

      _money(perGram),
    ];

    final oldRate = oldGold
        ? _money(
            _rateForUnit(
              _oldGoldRate(perGram),
              'ভরি',
            ),
          )
        : null;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),

      child: Row(
        children: [
          SizedBox(
            width: 48,

            child: Text(
              label,

              style:
                  const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          ...values.map(
            (value) => Expanded(
              child: Text(
                value,

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),

          if (oldRate != null)
            Padding(
              padding:
                  const EdgeInsets.only(
                left: 4,
              ),

              child: Text(
                'Old: $oldRate',

                style:
                    const TextStyle(
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      Color(0xFF8B0000),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION
  // ------------------------------------------------------------

  Widget _buildMarketSection({
    required String title,
    required List<Widget> rows,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,

      children: [
        Text(
          title,

          style:
              const TextStyle(
            fontSize: 17,
            fontWeight:
                FontWeight.bold,
            color:
                Color(0xFF333333),
          ),
        ),

        const SizedBox(height: 5),

        Container(
          height: 4,

          decoration:
              BoxDecoration(
            color:
                const Color(0xFF333333),

            borderRadius:
                BorderRadius.circular(2),
          ),
        ),

        const SizedBox(height: 8),

        ...rows,
      ],
    );
  }

  // ------------------------------------------------------------
  // UNAVAILABLE
  // ------------------------------------------------------------

  Widget _buildUnavailableCard(
    String message,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(14),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color:
              const Color(0xFFE0D7CE),
        ),
      ),

      child: Text(
        message,

        textAlign:
            TextAlign.center,

        style:
            const TextStyle(
          fontSize: 12,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// API RESULT MODEL
// ------------------------------------------------------------

class _MetalResult {
  const _MetalResult({
    this.data,
    this.lastUpdate,
    this.error,
  });

  final Map<String, double>? data;
  final String? lastUpdate;
  final String? error;
}
