import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pie_chart/pie_chart.dart';
import '../pages/configuration/config.dart';

class HeartRateHistoryPage extends StatefulWidget {
  const HeartRateHistoryPage({super.key, required String childId});

  @override
  _HeartRateHistoryPageState createState() => _HeartRateHistoryPageState();
}

class _HeartRateHistoryPageState extends State<HeartRateHistoryPage> with TickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _futureHeartRates;
  Map<String, double> _chartData = {};
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _futureHeartRates = fetchHeartRateHistory();

    // Fade-in animation controller for the page
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  Future<List<Map<String, dynamic>>> fetchHeartRateHistory() async {
    try {
      final response = await http.get(Uri.parse(fetchHeartRateHistoryUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final parsedData = data.cast<Map<String, dynamic>>();
        _generateChartData(parsedData);
        return parsedData;
      } else {
        throw Exception('Erreur serveur: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur : ${e.toString()}');
    }
  }

  void _generateChartData(List<Map<String, dynamic>> heartRates) {
    Map<String, int> categories = {
      "Low (<60 bpm)": 0,
      "Normal (60-100 bpm)": 0,
      "High (>100 bpm)": 0,
    };

    for (var item in heartRates) {
      int bpm = int.tryParse(item['bpm'].toString()) ?? 0;
      if (bpm < 60) {
        categories["Low (<60 bpm)"] = categories["Low (<60 bpm)"]! + 1;
      } else if (bpm <= 100) {
        categories["Normal (60-100 bpm)"] = categories["Normal (60-100 bpm)"]! + 1;
      } else {
        categories["High (>100 bpm)"] = categories["High (>100 bpm)"]! + 1;
      }
    }

    setState(() {
      _chartData = {
        for (var entry in categories.entries) entry.key: entry.value.toDouble(),
      };
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Heart Rate History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFB3CBF2),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(  // FutureBuilder to handle API call
            future: _futureHeartRates,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erreur : ${snapshot.error}',
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "Aucune donnée disponible",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }

              final heartRates = snapshot.data!;

              return Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Heart Rate Distribution",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    child: PieChart(
                      dataMap: _chartData,
                      animationDuration: const Duration(milliseconds: 800),
                      chartType: ChartType.ring,
                      chartRadius: MediaQuery.of(context).size.width / 2.5,
                      colorList: const [
                        Color.fromARGB(255, 208, 243, 33),
                        Color.fromARGB(255, 166, 190, 166),
                        Color.fromARGB(255, 238, 86, 225),
                      ],
                      legendOptions: const LegendOptions(
                        showLegends: true,
                        legendPosition: LegendPosition.bottom,
                      ),
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValuesInPercentage: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: heartRates.length,
                      itemBuilder: (context, index) {
                        final item = heartRates[index];
                        final bpm = item['bpm'] ?? '?';
                        final date = item['date'] ?? 'Date inconnue';

                        return AnimatedCard(
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              title: Text(
                                '$bpm bpm',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Date: $date',
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AnimatedCard({super.key, required this.child, this.onTap});

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.onTap != null) widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}  