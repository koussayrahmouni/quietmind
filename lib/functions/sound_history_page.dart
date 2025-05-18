import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../pages/configuration/config.dart';

class SoundHistoryPage extends StatefulWidget {
  final String childId;
  const SoundHistoryPage({super.key, required this.childId});

  @override
  State<SoundHistoryPage> createState() => _SoundHistoryPageState();
}

class _SoundHistoryPageState extends State<SoundHistoryPage> with SingleTickerProviderStateMixin {
  List<dynamic> soundHistory = [];
  Map<String, double> _chartData = {};
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;

  final List<Color> _gradientColors = [
    const Color(0xFFB3CBF2),
    const Color(0xFFE2A9F3),
  ];

  @override
  void initState() {
    super.initState();
    fetchSoundHistory();

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

  Future<void> fetchSoundHistory() async {
    try {
      final response = await http.get(Uri.parse(fetchSoundHistoryUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _generateChartData(data);
        setState(() {
          soundHistory = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load sound history');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _generateChartData(List<dynamic> soundData) {
    Map<String, double> categories = {
      "Faible (<50 dB)": 0,
      "Normal (50-70 dB)": 0,
      "Élevé (>70 dB)": 0
    };

    for (var item in soundData) {
      double sound = double.tryParse(item['sound'].toString()) ?? 0;
      if (sound < 50) {
        categories["Faible (<50 dB)"] = categories["Faible (<50 dB)"]! + 1;
      } else if (sound <= 70) {
        categories["Normal (50-70 dB)"] = categories["Normal (50-70 dB)"]! + 1;
      } else {
        categories["Élevé (>70 dB)"] = categories["Élevé (>70 dB)"]! + 1;
      }
    }

    setState(() {
      _chartData = categories.map((k, v) => MapEntry(k, v.toDouble()));
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Répartition Sonore',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: PieChart(
                dataMap: _chartData,
                animationDuration: const Duration(milliseconds: 800),
                chartType: ChartType.ring,
                chartRadius: MediaQuery.of(context).size.width / 3,
                colorList: const [Colors.green, Colors.blue, Colors.red],
                ringStrokeWidth: 24,
                legendOptions: const LegendOptions(
                  showLegends: true,
                  legendPosition: LegendPosition.bottom,
                ),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValuesInPercentage: true,
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
          "🔊 Historique Sonore",
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
        child: _isLoading
            ? _buildShimmerLoading()
            : soundHistory.isEmpty
                ? _buildEmptyState()
                : Stack(
                    children: [
                      _buildAnimatedList(soundHistory),
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
                  ),
      ),
    );
  }

  Widget _buildAnimatedList(List<dynamic> sounds) {
    return AnimatedList(
      initialItemCount: sounds.length,
      itemBuilder: (context, index, animation) {
        final item = sounds[index];
        final soundLevel = double.tryParse(item['sound'].toString()) ?? 0;
        final date = item['date']?.toString() ?? 'Unknown';

        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: FadeTransition(
            opacity: animation,
            child: _buildSoundCard(soundLevel, date),
          ),
        );
      },
    );
  }

  Widget _buildSoundCard(double soundLevel, String date) {
    Color cardColor;
    IconData statusIcon;
    String statusText;

    if (soundLevel < 50) {
      cardColor = Colors.green;
      statusIcon = Icons.volume_down;
      statusText = "Faible";
    } else if (soundLevel <= 70) {
      cardColor = Colors.blue;
      statusIcon = Icons.volume_up;
      statusText = "Normal";
    } else {
      cardColor = Colors.red;
      statusIcon = Icons.volume_off;
      statusText = "Élevé";
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
              '${soundLevel.toStringAsFixed(1)} dB',
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

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.volume_off, size: 80, color: Colors.grey),
        SizedBox(height: 20),
        Text(
          'Aucune donnée sonore disponible',
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
      duration: const Duration(milliseconds: 200),
    );
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
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}