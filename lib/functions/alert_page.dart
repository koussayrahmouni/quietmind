import 'package:flutter/material.dart';
import 'services/api_service.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  _AlertPageState createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  List<dynamic> alerts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

  Future<void> fetchAlerts() async {
    try {
      final data = await ApiService.fetchAlerts();
      setState(() {
        alerts = data ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void _deleteAlert(int alertId) async {
    try {
      await ApiService.deleteAlert(alertId);
      setState(() => alerts.removeWhere((alert) => alert['id'] == alertId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alerte supprimée')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final crisisAlerts = alerts.where((a) => 
      (a['message'] ?? '').toString().toLowerCase() == 'crise').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchAlerts),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : crisisAlerts.isEmpty
              ? const Center(child: Text('Aucune alerte de crise trouvée'))
              : ListView.builder(
                  itemCount: crisisAlerts.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final a = crisisAlerts[index];
                    return _buildCrisisCard(a, () => _deleteAlert(a['id']));
                  },
                ),
    );
  }

  Widget _buildCrisisCard(Map<String, dynamic> a, VoidCallback onDelete) {
    final date = DateTime.tryParse(a['date'] ?? '');
    final dateFmt = date != null
        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
        : 'Date inconnue';
    final bpm = a['bpm']?.toString() ?? '-';
    final temp = a['temperature']?.toString() ?? '-';
    final probValue = (a['probability'] ?? 0.0) * 100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade700.withOpacity(0.1),
          border: Border.all(color: Colors.red.shade400, width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade400.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade600, Colors.red.shade900],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.warning, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "⚠️ CRISE EN COURS ⚠️",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🕒 Date       : $dateFmt', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('❤️ BPM        : $bpm', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('🔥 Température: $temp °C', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (probValue / 100).clamp(0.0, 1.0),
                          backgroundColor: Colors.red.shade100,
                          color: Colors.red.shade700,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${probValue.toStringAsFixed(1)} %',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade800,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}