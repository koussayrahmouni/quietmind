import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pidevmobileflutter/pages/screen/parent/modifier_profil_parent.dart';
import '../../configuration/config.dart';

/// Widget personnalisé pour un bouton animé avec effet de scale
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Duration duration;

  const AnimatedButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.backgroundColor,
    required this.padding,
    required this.borderRadius,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  double _scale = 1.0;

  void _onTapDown(_) {
    setState(() {
      _scale = 0.95;
    });
  }

  void _onTapUp(_) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: widget.duration,
        transform: Matrix4.identity()..scale(_scale),
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          padding: widget.padding,
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final String email;
  final String token;

  const ProfileScreen({super.key, required this.email, required this.token});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final url = Uri.parse("$fetchUserUrl${widget.email}");
    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json"
        },
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData["success"] == 1) {
        setState(() {
          userData = responseData["data"];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = responseData["message"] ?? "⚠️ Erreur lors de la récupération du profil.";
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = "❌ Erreur réseau: $error";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc pour l'ensemble de l'écran
        appBar: AppBar(
        title: const Text("Profil",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF22B5C8),
        elevation: 10,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: fetchUserProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB3CBF2),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Réessayer", style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: userData?["profilePicture"] != null
                            ? NetworkImage(userData!["profilePicture"])
                            : const AssetImage('assets/images/profile_placeholder.png') as ImageProvider?,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "${userData?["firstname"] ?? "N/A"} ${userData?["lastName"] ?? "N/A"}",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userData?["email"] ?? "N/A",
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Color(0xFFB3CBF2), width: 1.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              buildProfileDetail(Icons.person, "First Name", userData?["firstname"]),
                              buildProfileDetail(Icons.person, "Last Name", userData?["lastName"]),
                              buildProfileDetail(Icons.phone, "Phone", userData?["phone"]),
                              buildProfileDetail(Icons.badge, "Role", userData?["role"]),
                              const Divider(),
                              buildProfileDetail(Icons.verified_user, "Status", "Active ✅"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedButton(
                               onPressed: () {
                            if (userData?["id"] != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModifierProfilParent(
                                    userId: userData!["id"].toString(),
                                    token: widget.token,
                                  ),
                                ),
                              );
                            }
                          },
                          backgroundColor: const Color(0xFFB3CBF2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          borderRadius: 10,
                          child: const Text(
                            "Modifier le Profil",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget buildProfileDetail(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            value != null ? value.toString() : "N/A",
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
