import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../configuration/config.dart';
import 'modifier_profil_parent.dart';

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

  void _onTapDown(_) => setState(() => _scale = 0.95);
  void _onTapUp(_) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

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
            color: widget.backgroundColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: widget.padding,
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

class ProfileparentScreen extends StatefulWidget {
  final String email;
  final String token;

  const ProfileparentScreen({super.key, required this.email, required this.token});

  @override
  _ProfileparentScreenState createState() => _ProfileparentScreenState();
}

class _ProfileparentScreenState extends State<ProfileparentScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final url = Uri.parse("$baseUrl/api/users/email/${widget.email}");
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

  Widget buildProfileDetail(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
          const Spacer(),
          Text(value != null ? value.toString() : "N/A", style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 8, 143, 164),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 206, 10, 10)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile Parent',
          style: TextStyle(color: Color.fromARGB(255, 174, 9, 9)),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/images22.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blurred overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.white)))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              backgroundImage: userData?["profilePicture"] != null
                                  ? NetworkImage(userData!["profilePicture"])
                                  : const AssetImage('assets/images/profile_placeholder.png') as ImageProvider?,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "${userData?["firstname"] ?? ""} ${userData?["lastName"] ?? ""}",
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              userData?["email"] ?? "",
                              style: const TextStyle(fontSize: 16, color: Colors.white70),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  buildProfileDetail(Icons.person, "Prénom", userData?["firstname"]),
                                  buildProfileDetail(Icons.person, "Nom", userData?["lastName"]),
                                  buildProfileDetail(Icons.phone, "Téléphone", userData?["phone"]),
                                  buildProfileDetail(Icons.badge, "Rôle", userData?["role"]),
                                  buildProfileDetail(Icons.verified_user, "Statut", "Actif ✅"),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            AnimatedButton(
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
                              borderRadius: 15,
                              child: const Text(
                                "Modifier le Profil",
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
