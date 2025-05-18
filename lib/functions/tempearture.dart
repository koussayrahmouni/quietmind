import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import '../pages/configuration/config.dart';

class HistoriqueTemperaturePage extends StatefulWidget {
  final String childId;
  const HistoriqueTemperaturePage({super.key, required this.childId});

  @override
  _HistoriqueTemperaturePageState createState() => _HistoriqueTemperaturePageState();
}

class _HistoriqueTemperaturePageState extends State<HistoriqueTemperaturePage> with SingleTickerProviderStateMixin {
  late Future<List<dynamic>> _futureTemperatures;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;

  final List<Color> _gradientColors = [
    const Color(0xFFB3CBF2),
    const Color(0xFFE2A9F3),
  ];

  final String fetchTemperatureHistoryUrl = 'http://localhost:5000/api/status/temperature';

  @override
  void initState() {
    super.initState();
    _futureTemperatures = fetchTemperatureHistory();
    
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

  Future<List<dynamic>> fetchTemperatureHistory() async {
    try {
      final response = await http.get(Uri.parse(fetchTemperatureHistoryUrl));
      if (response.statusCode == 200) {
        setState(() => _isLoading = false);
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load temperature history');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      return []; // Return empty list on error
    }
  }

  List<FlSpot> _generateChartData(List<dynamic> data) {
    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      double temp = data[i]['Temperature'].toDouble();
      spots.add(FlSpot(i.toDouble(), temp));
    }
    return spots;
  }

  void _showChartPopup(BuildContext context, List<dynamic> data) {
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No data available for the chart')),
      );
      return;
    }

    final spots = _generateChartData(data);

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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Historique Thermique",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text('${value.toInt()}°C'),
                      ),
                    ),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFFE2A9F3),
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: _gradientColors
                              .map((color) => color.withOpacity(0.3))
                              .toList(),
                        ),
                      ),
                      dotData: FlDotData(show: false),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "🌡 Historique Thermique",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: FutureBuilder<List<dynamic>>(
          future: _futureTemperatures,
          builder: (context, snapshot) {
            if (_isLoading) return _buildShimmerLoading();
            if (snapshot.hasError) return _buildErrorState(snapshot.error.toString());
            if (snapshot.data!.isEmpty) return _buildEmptyState();

            final data = snapshot.data!;
            return Stack(
              children: [
                _buildAnimatedList(data),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () => _showChartPopup(context, data),
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

  Widget _buildAnimatedList(List<dynamic> temperatures) {
    return AnimatedList(
      initialItemCount: temperatures.length,
      itemBuilder: (context, index, animation) {
        final item = temperatures[index];
        final temp = item['Temperature'].toDouble();
        final date = item['date']?.toString() ?? 'Unknown';

        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: FadeTransition(
            opacity: animation,
            child: _buildTemperatureCard(temp, date),
          ),
        );
      },
    );
  }

  Widget _buildTemperatureCard(double temperature, String date) {
    Color cardColor;
    IconData statusIcon;
    String statusText;

    if (temperature < 20) {
      cardColor = const Color(0xFF6DD5FA);
      statusIcon = Icons.ac_unit;
      statusText = "Froid";
    } else if (temperature <= 30) {
      cardColor = const Color(0xFF4CAF50);
      statusIcon = Icons.thermostat_auto;
      statusText = "Normal";
    } else {
      cardColor = const Color(0xFFFF5252);
      statusIcon = Icons.whatshot;
      statusText = "Chaud";
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            leading: Icon(statusIcon, color: Colors.white, size: 32),
            title: Text(
              '${temperature.toStringAsFixed(1)}°C',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.1,
              ),
            ),
            subtitle: Text(
              '📅 $date',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            trailing: Text(
              statusText,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
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
          'Erreur de chargement :\n$error',
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
        Icon(Icons.thermostat, size: 80, color: Colors.grey),
        SizedBox(height: 20),
        Text(
          'Aucune donnée thermique',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
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
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
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
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
