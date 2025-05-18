import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'drawer_screencaregiver.dart';
import 'dashboard_pagecaregiver.dart';

class Homecaregiver extends StatefulWidget {
  const Homecaregiver({super.key, required String chappiemail, required String token});

  @override
  State<Homecaregiver> createState() => _HomecaregiverState();
}

class _HomecaregiverState extends State<Homecaregiver> with TickerProviderStateMixin {
  late String chappiemail;
  late String token;
  late String caregiverId;
  List<dynamic> children = [];
  bool isLoading = true;
  String errorMessage = '';

  final List<AnimationController> _cardControllers = [];
  final List<Animation<double>> _scaleAnimations = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    chappiemail = args?['email'] ?? "Unknown";
    token = args?['token'] ?? "";
    caregiverId = args?['id'] ?? "";
    fetchChildren();
  }

  Future<void> fetchChildren() async {
    setState(() => isLoading = true);
    final url = Uri.parse('http://localhost:5000/api/children/caregiver/$caregiverId');
    try {
      final response = await http.get(url);
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() => children = responseData['data']);
        _initCardAnimations();
      } else {
        setState(() => errorMessage = responseData['message'] ?? "👉 L'enfant n'a pas de bracelet.");
      }
    } catch (e) {
      setState(() => errorMessage = "👉 L'enfant n'a pas de bracelet. $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _initCardAnimations() {
    // Nettoyer les animations précédentes
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    _cardControllers.clear();
    _scaleAnimations.clear();

    for (int i = 0; i < children.length; i++) {
      final controller = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      );

      final animation = CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      );

      _cardControllers.add(controller);
      _scaleAnimations.add(Tween<double>(begin: 0.8, end: 1.0).animate(animation));

      // Commencer l'animation avec un délai progressif
      Future.delayed(Duration(milliseconds: 300 * i), () {
        if (mounted) controller.forward();
      });
    }
  }

  Widget _buildInfoRow(String label, String value, {Color color = Colors.black87, IconData icon = Icons.info}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF85D1DB)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 12)),
                Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(dynamic child, int index) {
    return AnimatedBuilder(
      animation: _scaleAnimations[index],
      builder: (context, childWidget) {
        return Transform.scale(
          scale: _scaleAnimations[index].value,
          child: childWidget,
        );
      },
      child: Card(
        elevation: 8,
        shadowColor: Colors.blueGrey.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (_, __, ___) => DashboardPageCaregiver(childId: child['id'].toString()),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          },
          borderRadius: BorderRadius.circular(25),
          splashColor: const Color(0xFF85D1DB).withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Hero(
                    tag: 'child-${child['id']}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        "${child['FirstName'] ?? ''} ${child['LastName'] ?? ''}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C6979),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoRow("ÂGE", child['Age']?.toString() ?? "N/A", icon: Icons.cake),
                _buildInfoRow("GENRE", child['Gender'] ?? "N/A", icon: Icons.people_alt_outlined),
                _buildInfoRow("AUTONOMIE", child['AutonomyLevel'] ?? "N/A", icon: Icons.accessibility_new),
                _buildInfoRow("INTÉRÊTS", child['FavoriteInterests'] ?? "N/A", icon: Icons.favorite_border),
                _buildInfoRow("COMMUNICATION", child['ModeOfCommunication'] ?? "N/A", icon: Icons.chat_bubble_outline),
                _buildInfoRow("PRÉFÉRENCES SENSORIELLES", child['SensoryPreferences'] ?? "N/A", icon: Icons.hearing),
                _buildInfoRow("STRATÉGIES D'APAISEMENT", child['CalmingStrategies'] ?? "N/A", icon: Icons.health_and_safety_outlined),
                _buildInfoRow("ALLERGIES", child['AllergiesOrDietaryRestrictions'] ?? "Aucune", color: Colors.redAccent, icon: Icons.warning_amber_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Réessayer', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF85D1DB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            onPressed: fetchChildren,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerScreen(chappiemail: chappiemail, token: token),
      appBar: AppBar(
        title: const Text("Caregiver Home",
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFBFEFE), Color(0xFFB3EBF2), Color(0xFF85D1DB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: isLoading
              ? _buildLoadingAnimation()
              : errorMessage.isNotEmpty
                  ? _buildErrorWidget()
                  : children.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/no_children.png', height: 150),
                              const SizedBox(height: 20),
                              const Text('Aucun enfant trouvé', style: TextStyle(color: Colors.blueGrey, fontSize: 18)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 20, bottom: 100),
                          itemCount: children.length,
                          itemBuilder: (context, index) => _buildChildCard(children[index], index),
                        ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
