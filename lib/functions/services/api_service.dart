import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../pages/configuration/config.dart';

class ApiService {
  // Fetch Dashboard Data
  static Future<List<dynamic>> fetchDashboardData() async {
    try {
      final response = await http.get(Uri.parse(fetchDashboardDataUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Connection error: $e');
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Create an alert
  static Future<void> createAlert(int statusId, String alertType, String alertMessage) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/alert'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: json.encode({
        'status_id': statusId,
        'alert_type': alertType,
        'alert_message': alertMessage,
      }),
    );

    if (response.statusCode == 200) {
      print('Alert created successfully');
    } else {
      throw Exception('Failed to create alert: ${response.statusCode}, ${response.body}');
    }
  }

  // Fetch the last data for a specific child
  static Future<Map<String, dynamic>> fetchChildLastData(String childId) async {
    final url = Uri.parse('http://localhost:5000/api/status/last-data/$childId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Error fetching child data');
    }
  }

  // Fetch all alerts from the server
  static Future<List<dynamic>> fetchAlerts() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/api/alert'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load alerts: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Connection error: $e');
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Create an alert if it does not exist already
  static Future<void> createAlertIfNotExists(int statusId, String alertType, String alertMessage) async {
    try {
      final alerts = await fetchAlerts();
      final existingAlert = alerts.any((alert) => alert['status_id'] == statusId);

      if (!existingAlert) {
        await createAlert(statusId, alertType, alertMessage);
        print('New alert created: statusId=$statusId, alertType=$alertType');
      } else {
        print('Alert already exists for statusId=$statusId, alertType=$alertType');
      }
    } catch (e) {
      print('Error while creating alert: $e');
    }
  }

  // Delete a specific alert by its ID
  static Future<void> deleteAlert(int alertId) async {
    final response = await http.delete(Uri.parse('http://localhost:5000/api/alert/$alertId'));

    if (response.statusCode == 200) {
      print('Alert deleted successfully');
    } else {
      throw Exception('Failed to delete alert: ${response.statusCode}');
    }
  }

  // Get current location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
