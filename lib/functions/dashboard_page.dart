import 'package:flutter/material.dart';
import 'package:pidevmobileflutter/functions/alert_page.dart';
import 'package:pidevmobileflutter/functions/heartratehistorypage.dart';
import 'package:pidevmobileflutter/functions/services/notification_service.dart';
import 'package:pidevmobileflutter/functions/sound_history_page.dart';
import 'package:pidevmobileflutter/functions/tempearture.dart';
import 'map_page.dart';
import 'services/api_service.dart';
import 'room_page.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../functions/services/api_service.dart';
import 'package:pidevmobileflutter/functions/notification_page.dart';
import 'package:pidevmobileflutter/functions/MusicPage.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}
class SocketService {
  static late IO.Socket socket;

  static void initSocket() {
    socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('Socket connected ✅');
    });

    socket.on("alert", (data) {
      final String type = data['alert_type'] ?? 'Alerte';
      final String message = data['alert_message'] ?? 'Message inconnu';
      NotificationService.showNotification(type, message);
    });

    socket.onDisconnect((_) => print('Socket disconnected ❌'));
  }
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? lastData;
  bool isLoading = true;
  int _selectedIndex = 0;
  bool hasNotification = false;


void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;

    // Réinitialise le badge si Alertes est ouvert
    if (index == 1) hasNotification = false;
  });

  if (index == 1) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AlertPage()));
  } else if (index == 2) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomPage()));
  }
  else if (index == 3) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const Sound1Page()));
  }
}

  

@override
void initState() {
  super.initState();
  fetchData();

  // Init socket après initState
  SocketService.socket.on("alert", (data) {
    final String type = data['alert_type'] ?? 'Alerte';
    final String message = data['alert_message'] ?? 'Message inconnu';
    NotificationService.showNotification(type, message);

    // Active le badge
    setState(() {
      hasNotification = true;
    });
  });
}


  Future<void> fetchData() async {
    try {
      final data = await ApiService.fetchDashboardData();
      lastData = data.lastWhere(
        (e) => e.containsKey('bpm') && e['bpm'] != null,
        orElse: () => {},
      );
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  String _getTemperatureStatus(dynamic t) {
    if (t == null || t is! num) return "N/A";
    if (t >= 39) {
      ApiService.createAlertIfNotExists(lastData?['id'], "Temperature", "Température élevée: $t°C");
      return "Not Normal";
    }
    return "Normal";
  }

  String _getHeartRateStatus(dynamic h) {
    if (h == null || h is! num) return "N/A";
    if (h < 50 || h > 120) {
      ApiService.createAlertIfNotExists(lastData?['id'], "Heart Rate", "Fréquence anormale: $h bpm");
      return "Not Normal";
    }
    return "Normal";
  }

  String _getSoundStatus(dynamic s) {
    if (s == null) return "N/A";
    final v = double.tryParse(s.toString());
    if (v == null) return "N/A";
    if (v >= 60 && v <= 70) {
      ApiService.createAlertIfNotExists(lastData?['id'], "Sound", "Niveau anormal: $v dB");
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Container(
          constraints: const BoxConstraints(minHeight: 200, maxHeight: 250),
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
                          Colors.black.withOpacity(0.3)
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
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Column(
          children: [
            if (isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _buildCard(
                        imagePath: 'assets/images/heartbeat.jpg',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HeartRateHistoryPage(childId: '',)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              lastData?['bpm']?.toString() ?? "N/A",
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent),
                            ),
                            Text(
                              _getHeartRateStatus(lastData?['bpm']),
                              style: TextStyle(
                                fontSize: 16,
                                color: _getHeartRateStatus(lastData?['bpm']) == "Normal"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _buildCard(
                        imagePath: 'assets/images/sound_bg.jpg',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SoundHistoryPage(childId: '',)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                color: _getSoundStatus(lastData?['sound']) == "Normal"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _buildCard(
                        imagePath: 'assets/images/temperature_bg.jpg',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HistoriqueTemperaturePage(childId: '',)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              _getTemperatureStatus(lastData?['Temperature']),
                              style: TextStyle(
                                fontSize: 16,
                                color: _getTemperatureStatus(lastData?['Temperature']) == "Normal"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _buildCard(
                        imagePath: 'assets/images/map_bg.jpg',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MapPage(childId: '',)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 16),
                   AspectRatio(
  aspectRatio: 16 / 9,
  child: _buildCard(
    imagePath: 'assets/images/musicc.jpg',
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MusicPage()),
      );
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Icon(Icons.music_note, color: Colors.blueAccent, size: 32),
        SizedBox(height: 12),
        Text(
          "Music",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
  items: [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(
        hasNotification ? Icons.warning : Icons.warning,
        color: hasNotification ? Colors.red : null,
      ),
      label: 'Alertes',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Room',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.notifications),
      label: 'Notifications',
    ),
  ],
  currentIndex: _selectedIndex,
  selectedItemColor: const Color.fromARGB(204, 42, 145, 255),
  unselectedItemColor: Colors.grey,
  onTap: _onItemTapped,
),


    );
  }
}