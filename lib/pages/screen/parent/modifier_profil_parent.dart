import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../configuration/config.dart';

// Assurez-vous d'ajouter dans pubspec.yaml :
// flutter:
//   assets:
//     - assets/images/images22.jpeg

class ModifierProfilParent extends StatefulWidget {
  final String userId;
  final String token;

  const ModifierProfilParent({
    super.key,
    required this.userId,
    required this.token,
  });

  @override
  _ModifierProfilParentState createState() => _ModifierProfilParentState();
}

class _ModifierProfilParentState extends State<ModifierProfilParent>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = true;
  String errorMessage = '';
  bool _isButtonPressed = false;
  int _currentIndex = 1; // Profil sélectionné par défaut

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    fetchUserProfile().then((_) => _controller.forward());
  }

  Future<void> fetchUserProfile() async {
    final url = Uri.parse('$fetchUserProfileUrl${widget.userId}');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      });
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == 1) {
        setState(() {
          firstNameController.text = data['data']['firstName'] ?? '';
          lastNameController.text = data['data']['lastName'] ?? '';
          emailController.text = data['data']['email'] ?? '';
          phoneController.text = data['data']['phone'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Erreur récupération des données.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur réseau: $e';
        isLoading = false;
      });
    }
  }

  Future<void> updateUserProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final Map<String, dynamic> payload = {};
    if (firstNameController.text.isNotEmpty) payload['firstName'] = firstNameController.text;
    if (lastNameController.text.isNotEmpty) payload['lastName'] = lastNameController.text;
    if (emailController.text.isNotEmpty) payload['email'] = emailController.text;
    if (phoneController.text.isNotEmpty) payload['phone'] = phoneController.text;

    final url = Uri.parse('$updateUserProfileUrl${widget.userId}');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès ✅')),
        );
        Navigator.pop(context, true);
      } else {
        setState(() => errorMessage = data['message'] ?? 'Erreur mise à jour.');
      }
    } catch (e) {
      setState(() => errorMessage = 'Erreur réseau: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildForm() {
    if (isLoading) return _buildShimmer();
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          margin: const EdgeInsets.all(0),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildField(firstNameController, 'Prénom', Icons.person),
                  const SizedBox(height: 20),
                  _buildField(lastNameController, 'Nom', Icons.person_outline),
                  const SizedBox(height: 20),
                  _buildField(emailController, 'Email', Icons.email,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  _buildField(phoneController, 'Téléphone', Icons.phone,
                      keyboardType: TextInputType.phone),
                  if (errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(errorMessage,
                        style: TextStyle(color: Colors.red.shade700)),
                  ],
                  const SizedBox(height: 30),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v!.isEmpty ? 'Champ requis' : null,
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(
        4,
        (_) => Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isButtonPressed = true),
      onTapUp: (_) async {
        setState(() => _isButtonPressed = false);
        await updateUserProfile();
      },
      child: AnimatedScale(
        scale: _isButtonPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.save),
          label: const Text('Enregistrer'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      extendBodyBehindAppBar: false,
     appBar: AppBar(
        title: const Text("Modifier Profil",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF22B5C8),
        elevation: 10,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/images22.jpeg',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildForm(),
            ),
          ),
        ],
      ),

    );
  }
}
