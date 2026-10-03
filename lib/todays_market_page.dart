import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class TodaysMarketPage extends StatefulWidget {
  const TodaysMarketPage({super.key});

  @override
  State<TodaysMarketPage> createState() => _TodaysMarketPageState();
}

class _TodaysMarketPageState extends State<TodaysMarketPage> {
  bool isLoading = true;

  // Real-time market rates
  double gold22k = 138000.0;
  double gold21k = 131700.0;
  double gold18k = 112900.0;
  double goldTraditional = 92800.0;
  double silver22k = 2500.0;

  String selectedUnit = 'Vori';
  double buybackPercentage = 20.0;
  final TextEditingController percentageController = TextEditingController(text: '20');

  @override
  void initState() {
    super.initState();
    fetchMarketRates();
  }

  Future<void> fetchMarketRates() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://www.bajus.org/gold-price'),
        headers: {'User-Agent': 'Mozilla/5.0'},
      );

      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        var rows = document.querySelectorAll('table tr');

        for (var row in rows) {
          var columns = row.querySelectorAll('td');
          if (columns.length >= 2) {
            String category = columns[0].text.trim().toLowerCase();
            String priceText = columns[1].text.replaceAll(RegExp(r'[^0-9.]'), '');
            double? parsedPrice = double.tryParse(priceText);

            if (parsedPrice != null && parsedPrice > 0) {
              if (category.contains('22') && category.contains('gold')) {
                gold22k = parsedPrice;
              } else if (category.contains('21') && category.contains('gold')) {
                gold21k = parsedPrice;
              } else if (category.contains('18') && category.contains('gold')) {
                gold18k = parsedPrice;
              } else if (category.contains('traditional')) {
                goldTraditional = parsedPrice;
              } else if (category.contains('silver')) {
                silver22k = parsedPrice;
              }
            }
          }
        }
      }
    } catch (_) {
      // Retains latest actual base fallback values if fetch fails
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  double getConvertedPrice(double voriPrice) {
    switch (selectedUnit) {
      case 'Gram':
        return voriPrice / 11.664;
      case 'Ana':
        return voriPrice / 16.0;
      case 'Rati':
        return voriPrice / 96.0;
      case 'Vori':
      default:
        return voriPrice;
    }
  }

  double getBuybackPrice(double voriPrice) {
    double base = getConvertedPrice(voriPrice);
    return base * (1 - (buybackPercentage / 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আজকের বাজার (Live Rates)'),
        backgroundColor: Colors.amber[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchMarketRates,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'একক সিলেক্ট করুন:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  // Unit Selector Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['Vori', 'Gram', 'Ana', 'Rati'].map((unit) {
                      bool isSelected = selectedUnit == unit;
                      String label = unit == 'Vori'
                          ? 'ভরি'
                          : unit == 'Gram'
                              ? 'গ্রাম'
                              : unit == 'Ana'
                                  ? 'আনা'
                                  : 'রতি';
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: ChoiceChip(
                            label: Center(child: Text(label)),
                            selected: isSelected,
                            selectedColor: Colors.amber[700],
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  selectedUnit = unit;
                                });
                              }
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Deduction Percentage Field
                  Card(
                    color: Colors.amber[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'পুরাতন সোনা বিক্রয়/বদল কর্তন (%):',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: TextField(
                              controller: percentageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                                suffixText: '%',
                              ),
                              onChanged: (val) {
                                setState(() {
                                  buybackPercentage = double.tryParse(val) ?? 0.0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'সোনার বর্তমান বাজার দর:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),

                  _buildRateCard('২২ ক্যারেট সোনা', gold22k, Colors.amber[700]!),
                  _buildRateCard('২১ ক্যারেট সোনা', gold21k, Colors.amber[600]!),
                  _buildRateCard('১৮ ক্যারেট সোনা', gold18k, Colors.amber[500]!),
                  _buildRateCard('সনাতন পদ্ধতির সোনা', goldTraditional, Colors.amber[400]!),

                  const SizedBox(height: 15),
                  const Text(
                    'রুপার বর্তমান বাজার দর:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  _buildRateCard('২২ ক্যারেট রুপা', silver22k, Colors.grey[600]!),
                ],
              ),
            ),
    );
  }

  Widget _buildRateCard(String title, double voriPrice, Color color) {
    double currentPrice = getConvertedPrice(voriPrice);
    double buyback = getBuybackPrice(voriPrice);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.workspace_premium, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'পুরাতন সোনা ক্রয়মূল্য (-$buybackPercentage%): ৳${buyback.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.red[700], fontSize: 12),
        ),
        trailing: Text(
          '৳${currentPrice.toStringAsFixed(2)}\n/ $selectedUnit',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}
