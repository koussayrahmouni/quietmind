import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'modifier_profile_child.dart';
import '../../configuration/config.dart';

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
  void _onTapDown(_)   => setState(() => _scale = 0.95);
  void _onTapUp(_)     => setState(() => _scale = 1.0);
  void _onTapCancel()  => setState(() => _scale = 1.0);

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

class ProfileChild extends StatefulWidget {
  final String token;
  final String parentId;

  const ProfileChild({
    super.key,
    required this.token,
    required this.parentId, required email,
  });

  @override
  _ProfileChildState createState() => _ProfileChildState();
}

class _ProfileChildState extends State<ProfileChild> {
  List<dynamic> children = [];
  bool isLoading = true;
  String errorMessage = '';
  int _selectedIndex = 0; // ← Index de la barre de menu

  @override
  void initState() {
    super.initState();
    fetchChildren();
  }

  Future<void> fetchChildren() async {
    setState(() => isLoading = true);
    final apiUrl = "$fetchChildrenUrlll${widget.parentId}/children";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() => children = data["data"]);
      } else {
        setState(() => errorMessage = data['message'] ?? "❌ Erreur de récupération");
      }
    } catch (e) {
      setState(() => errorMessage = "❌ Erreur réseau: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Ici, en fonction de l’index, tu peux naviguer ou modifier le contenu.
      // Exemple :
      // if (index == 0) navigate to home...
    });
  }

  Widget buildDetail(String label, dynamic value, {Color color = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value?.toString() ?? "N/A", style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget buildChildCard(dynamic child) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFB3CBF2), width: 1.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "${child['FirstName']} ${child['LastName']}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),

              buildDetail("👶 Âge", child["Age"]),
              buildDetail("⚧ Genre", child["Gender"]),
              buildDetail("🧩 Autonomie", child["AutonomyLevel"]),
              buildDetail("🎨 Intérêts", child["FavoriteInterests"]),
              buildDetail("🗣 Communication", child["ModeOfCommunication"]),
              buildDetail("🏁 Préférences sensorielles", child["SensoryPreferences"]),
              buildDetail("🌿 Stratégies d’apaisement", child["CalmingStrategies"]),
              buildDetail("🛑 Allergies", child["AllergiesOrDietaryRestrictions"], color: Colors.redAccent),

              const SizedBox(height: 20),
              AnimatedButton(
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ModifierProfileChild(
                        childData: child,
                        token: widget.token,
                        parentId: widget.parentId,
                      ),
                    ),
                  );
                  if (result == true) fetchChildren();
                },
                backgroundColor: const Color(0xFFB3CBF2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                borderRadius: 15,
                child: const Text("Modifier", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profil des Enfants",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFB3CBF2),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/image01.jpeg"),
                      fit: BoxFit.cover,
                      opacity: 0.3,
                    ),
                  ),
                  child: children.length == 1
                      ? LayoutBuilder(builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 60),
                                  buildChildCard(children[0]),
                                  const SizedBox(height: 60),
                                ],
                              ),
                            ),
                          );
                        })
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: children.length,
                          itemBuilder: (c, i) => buildChildCard(children[i]),
                        ),
                ),
      // ← Barre de menu en bas
      /*
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFB3CBF2),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Enfants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),*/
    );
  }
}
