import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pidevmobileflutter/pages/configuration/config.dart' as Config;
import 'package:pie_chart/pie_chart.dart';
import 'package:shimmer/shimmer.dart';

class HeartRateHistoryPage extends StatefulWidget {
  final String childId;
  const HeartRateHistoryPage({super.key, required this.childId});

  @override
  _HeartRateHistoryPageState createState() => _HeartRateHistoryPageState();
}

class _HeartRateHistoryPageState extends State<HeartRateHistoryPage> with TickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _futureHeartRates;
  Map<String, double> _chartData = {};
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Color> _gradientColors = [
    const Color(0xFFB3CBF2),
    const Color(0xFFE2A9F3),
  ];

  @override
  void initState() {
    super.initState();
    _futureHeartRates = fetchHeartRateHistory();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOutCirc,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchHeartRateHistory() async {
    final fetchUrl = Config.fetchHeartRateHistoryUrl;
    final uri = Uri.parse(fetchUrl);
    final response = await http.get(uri);

    if (response.statusCode == 404) {
      throw Exception('Aucune donnée de fréquence cardiaque trouvée (404)');
    }
    if (response.statusCode != 200) {
      throw Exception(
        'Erreur serveur (${response.statusCode}) lors du chargement des données'
      );
    }

    final List<dynamic> raw = json.decode(response.body);
    final list = raw.map<Map<String, dynamic>>((e) {
      return {
        'date': e['date'] as String? ?? 'Unknown',
        'bpm': e['bpm']?.toString() ?? '0',
      };
    }).toList();

    _generateChartData(list);
    return list;
  }

  void _generateChartData(List<Map<String, dynamic>> heartRates) {
    final lowCount = heartRates.where((e) => int.tryParse(e['bpm']!)! < 60).length;
    final normalCount = heartRates.where((e) {
      final bpm = int.tryParse(e['bpm']!)!;
      return bpm >= 60 && bpm <= 100;
    }).length;
    final highCount = heartRates.where((e) => int.tryParse(e['bpm']!)! > 100).length;

    setState(() {
      _chartData = {
        'Low (<60)': lowCount.toDouble(),
        'Normal (60–100)': normalCount.toDouble(),
        'High (>100)': highCount.toDouble(),
      };
    });
  }

  void _showChartPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Heart Rate Statistics',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(child: _buildAnimatedChart()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "❤️ Heart Rate History",
          style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold,
            fontSize: 22, letterSpacing: 1.2,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _gradientColors,
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: FutureBuilder<List<Map<String, dynamic>>>( 
          future: _futureHeartRates,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoading();
            } else if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final heartRates = snapshot.data!;
            return Stack(
              children: [
                _buildAnimatedList(heartRates),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () => _showChartPopup(context),
                    backgroundColor: _gradientColors[1],
                    child: const Icon(Icons.graphic_eq, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedChart() {
    return PieChart(
      dataMap: _chartData,
      animationDuration: const Duration(milliseconds: 1200),
      chartType: ChartType.ring,
      chartRadius: MediaQuery.of(context).size.width / 3,
      colorList: const [
        Color(0xFF6DD5FA), Color(0xFF4CAF50), Color(0xFFFF5252),
      ],
      ringStrokeWidth: 24,
      legendOptions: const LegendOptions(
        showLegends: true,
        legendTextStyle: TextStyle(fontWeight: FontWeight.w600),
        legendPosition: LegendPosition.bottom,
      ),
      chartValuesOptions: const ChartValuesOptions(
        showChartValuesInPercentage: true,
        chartValueStyle: TextStyle(
          fontWeight: FontWeight.bold, color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAnimatedList(List<Map<String, dynamic>> heartRates) {
    return AnimatedList(
      initialItemCount: heartRates.length,
      itemBuilder: (context, index, animation) {
        final item = heartRates[index];
        final bpm = item['bpm']!;
        final date = item['date']!;

        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: FadeTransition(
            opacity: animation,
            child: _buildHeartRateCard(bpm, date),
          ),
        );
      },
    );
  }

  Widget _buildHeartRateCard(String bpm, String date) {
    final intVal = int.tryParse(bpm) ?? 0;
    Color cardColor;
    IconData statusIcon;

    if (intVal < 60) {
      cardColor = const Color(0xFF6DD5FA);
      statusIcon = Icons.arrow_downward;
    } else if (intVal <= 100) {
      cardColor = const Color(0xFF4CAF50);
      statusIcon = Icons.check_circle;
    } else {
      cardColor = const Color(0xFFFF5252);
      statusIcon = Icons.arrow_upward;
    }

    return AnimatedCard(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shadowColor: cardColor.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cardColor.withOpacity(0.9), cardColor],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            leading: Icon(statusIcon, color: Colors.white, size: 32),
            title: Text(
              '$bpm BPM',
              style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold,
                color: Colors.white, letterSpacing: 1.1,
              ),
            ),
            subtitle: Text(
              '📅 $date',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() => Shimmer.fromColors(
    baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
    child: ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15)),
        ),
      ),
    ),
  );

  Widget _buildErrorState(String error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
        const SizedBox(height: 20),
        Text(
          'Oops! Something est arrivé :\n$error',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.favorite_border, size: 80, color: Colors.grey),
        SizedBox(height: 20),
        Text(
          'No heart rate data available',
          style: TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

class AnimatedCard extends StatefulWidget {
  final Widget child;
  const AnimatedCard({super.key, required this.child});

  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _hoverController.forward(),
        onTapUp: (_) => _hoverController.reverse(),
        onTapCancel: () => _hoverController.reverse(),
        child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
      ),
    );
  }
}
