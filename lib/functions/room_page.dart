import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> with TickerProviderStateMixin {
  bool light = false;
  bool store = false;
  bool ventilateur = false;
  late AnimationController _fanController;

  final int roomId = 1;
  final String baseUrl = "http://localhost:5000/api/room";

  @override
  void initState() {
    super.initState();
    _fanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _fanController.dispose();
    super.dispose();
  }

  Future<void> updateRoomField(String field, int value) async {
    final url = Uri.parse('$baseUrl/$roomId/$field');
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({field: value}),
      );

      if (response.statusCode == 200) {
        print("✅ $field updated: ${response.body}");
      } else {
        print("❌ Failed to update $field: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Error updating $field: $e");
    }
  }

  void toggleSwitch(String field, bool value) {
    setState(() {
      if (field == 'light') {
        light = value;
      } else if (field == 'store') {
        store = value;
      } else if (field == 'ventilateur') {
        ventilateur = value;
        value ? _fanController.repeat() : _fanController.stop();
      }
    });
    updateRoomField(field, value ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Room",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF22B5C8),
        elevation: 10,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildAnimatedControlTile(
                context,
                label: "Light",
                value: light,
                icon: Icons.lightbulb_outline,
                activeColor: Colors.amber.shade300,
                onChanged: (val) => toggleSwitch("light", val),
              ),
              _buildAnimatedControlTile(
                context,
                label: "Blinds",
                value: store,
                icon: Icons.blinds_closed,
                activeColor: Colors.blueGrey.shade400,
                onChanged: (val) => toggleSwitch("store", val),
              ),
              _buildAnimatedControlTile(
                context,
                label: "Fan",
                value: ventilateur,
                icon: Icons.toys,
                activeColor: Colors.teal.shade400,
                onChanged: (val) => toggleSwitch("ventilateur", val),
                fanAnimation: RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0)
                      .animate(_fanController),
                ), // ← virgule et parenthèse fermante ajoutées ici
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedControlTile(
    BuildContext context, {
    required String label,
    required bool value,
    required IconData icon,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
    Widget? fanAnimation,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: value
            ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: value ? 6 : 3,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: value
                  ? [
                      activeColor.withOpacity(0.1),
                      activeColor.withOpacity(0.05)
                    ]
                  : [Colors.white, Colors.white],
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: value ? activeColor : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: fanAnimation ??
                      Icon(icon,
                          color: value ? Colors.white : Colors.grey.shade700),
                ),
                if (fanAnimation != null && value) fanAnimation,
              ],
            ),
            title: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: value ? activeColor : Colors.grey.shade800,
              ),
            ),
            trailing: Transform.scale(
              scale: 1.2,
              child: Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: activeColor,
                activeTrackColor: activeColor.withOpacity(0.4),
                inactiveThumbColor: Colors.grey.shade600,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            ),
            onTap: () => onChanged(!value),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }
}
