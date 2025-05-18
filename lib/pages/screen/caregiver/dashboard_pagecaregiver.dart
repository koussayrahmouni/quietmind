import 'package:flutter/material.dart';
import '../../../functions/services/api_service.dart';
import '../../../functions/alert_page.dart';
import '../../../functions/heartratehistorypage.dart';
import '../../../functions/sound_history_page.dart';
import '../../../functions/tempearture.dart';
import '../../../functions/map_page.dart';

class DashboardPageCaregiver extends StatefulWidget {
  final String childId;
  const DashboardPageCaregiver({super.key, required this.childId});

  @override
  State<DashboardPageCaregiver> createState() =>
      _DashboardPageCaregiverState();
}

class _DashboardPageCaregiverState extends State<DashboardPageCaregiver> {
  Map<String, dynamic>? lastData;
  bool isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchChildData();
  }

  Future<void> fetchChildData() async {
    try {
      final data = await ApiService.fetchChildLastData(widget.childId);
      setState(() {
        lastData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AlertPage()));
    }
  }

  String _getTemperatureStatus(dynamic t) {
    if (t == null || t is! num) return "N/A";
    if (t >= 39) {
      final alertId = lastData?['id'];
      if (alertId is int) {
        ApiService.createAlertIfNotExists(
          alertId,
          "Temperature",
          "Température élevée: $t°C",
        );
      }
      return "Not Normal";
    }
    return "Normal";
  }

  String _getHeartRateStatus(dynamic h) {
    if (h == null || h is! num) return "N/A";
    if (h < 50 || h > 120) { 
      final alertId = lastData?['id'];
      if (alertId is int) {
        ApiService.createAlertIfNotExists(
          alertId,
          "Heart Rate",
          "Fréquence anormale: $h bpm",
        );
      }
      return "Not Normal";
    }
    return "Normal";
  }

  String _getSoundStatus(dynamic s) {
    if (s == null) return "N/A";
    final v = double.tryParse(s.toString());
    if (v == null) return "N/A";
    if (v >= 60 && v <= 70) {
      final alertId = lastData?['id'];
      if (alertId is int) {
        ApiService.createAlertIfNotExists(
          alertId,
          "Sound",
          "Niveau anormal: $v dB",
        );
      }
      return "Not Normal";
    }
    return "Normal";
  }

  Widget _buildCard({
    required Widget child,
    required VoidCallback? onTap,
    required String imagePath,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Container(
          constraints:
              const BoxConstraints(minHeight: 200, maxHeight: 250),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Column(
          children: [
            if (isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (lastData == null)
              const Expanded(
                child:
                    Center(child: Text("👉 L'enfant n'a pas de bracelet.")),
              )
            else
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Heart Rate
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _buildCard(
                        imagePath: 'assets/images/heartbeat.jpg',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HeartRateHistoryPage(
                                childId: widget.childId),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.favorite,
                                color: Colors.redAccent, size: 32),
                            const SizedBox(height: 12),
                            const Text("Heart Rate",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 8),
                            Text(
                              "${lastData?['bpm'] ?? 'N/A'}",
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent),
                            ),
                            Text(
                              _getHeartRateStatus(
                                  lastData?['bpm']),
                              style: TextStyle(
                                fontSize: 16,
                                color: _getHeartRateStatus(
                                            lastData?[
                                                'bpm']) ==
                                        "Normal"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sound
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _buildCard(
                        imagePath: 'assets/images/sound_bg.jpg',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SoundHistoryPage(childId: widget.childId),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.hearing,
                                color: Colors.orangeAccent, size: 32),
                            const SizedBox(height: 12),
                            const Text("Sound",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 8),
                            Text(
                              "${lastData?['sound'] ?? 'N/A'} dB",
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orangeAccent),
                            ),
                            Text(
                              _getSoundStatus(lastData?['sound']),
                              style: TextStyle(
                                fontSize: 16,
                                color: _getSoundStatus(
                                            lastData?['sound']) ==
                                        "Normal"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Temperature
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _buildCard(
                        imagePath: 'assets/images/temperature_bg.jpg',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                HistoriqueTemperaturePage(childId: widget.childId),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.thermostat,
                                color: Colors.blueAccent, size: 32),
                            const SizedBox(height: 12),
                            const Text("Temperature",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 8),
                            Text(
                              "${lastData?['Temperature'] ?? 'N/A'}°C",
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent),
                            ),
                            Text(
                              _getTemperatureStatus(
                                  lastData?['Temperature']),
                              style: TextStyle(
                                fontSize: 16,
                                color: _getTemperatureStatus(
                                            lastData?[
                                                'Temperature']) ==
                                        "Normal"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Location
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _buildCard(
                        imagePath: 'assets/images/map_bg.jpg',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MapPage(childId: widget.childId),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.green, size: 32),
                            const SizedBox(height: 12),
                            const Text("Location",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 8),
                            Text(
                              'Lat: ${lastData?['Latitude'] ?? 'N/A'}, Lon: ${lastData?['Longitude'] ?? 'N/A'}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alertes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(204, 42, 145, 255),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
