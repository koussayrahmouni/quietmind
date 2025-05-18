import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section des cartes de statistiques
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  title: 'B.P',
                  value: '120/80',
                  status: 'Normal',
                  color: Colors.blue,
                  icon: Icons.favorite,
                ),
                _buildStatCard(
                  title: 'Sound',
                  value: '42dB',
                  status: 'Normal',
                  color: Colors.orange,
                  icon: Icons.hearing,
                ),
                _buildStatCard(
                  title: 'Temperature',
                  value: '36.5°C',
                  status: 'Normal',
                  color: Colors.red,
                  icon: Icons.thermostat,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Titre de la section hebdomadaire
            const Text(
              'Weekly',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Graphique hebdomadaire (simulé avec des barres)
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBar(40, Colors.blue),
                    _buildBar(60, Colors.orange),
                    _buildBar(80, Colors.red),
                    _buildBar(20, Colors.green),
                    _buildBar(100, Colors.purple),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section des statistiques supplémentaires
            const Text(
              'Usage Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoBox(
                  title: 'Max',
                  value: '150dB',
                  color: Colors.pinkAccent,
                  icon: Icons.arrow_upward,
                ),
                _buildInfoBox(
                  title: 'Download',
                  value: '42%',
                  color: Colors.green,
                  icon: Icons.download,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date de la dernière mise à jour
            const Text(
              '1 Week ago',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour créer une carte de statistique
  Widget _buildStatCard({
    required String title,
    required String value,
    required String status,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                status,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour afficher les informations supplémentaires (Max, Download)
  Widget _buildInfoBox({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 5),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour créer une barre du graphique
  Widget _buildBar(double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(height: 5),
        Text('${height.toInt()}', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
