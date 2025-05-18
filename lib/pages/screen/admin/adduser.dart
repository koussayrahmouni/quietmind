import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../configuration/config.dart';

class Adduser extends StatefulWidget {
  final String email;
  final String token;

  const Adduser({super.key, required this.email, required this.token});

  @override
  _AdduserState createState() => _AdduserState();
}

class _AdduserState extends State<Adduser> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  String role = "parents";
  bool isLoading = false;
  final _focusNodes = List.generate(5, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> addUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://localhost:5000/api/users/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          "firstName": firstNameController.text.trim(),
          "lastName": lastNameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text,
          "phone": phoneController.text.trim(),
          "role": role,
          "etat": "active",
        }),
      );

      final responseData = jsonDecode(response.body);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.statusCode == 200
                ? "✅ Utilisateur ajouté avec succès"
                : "❌ ${responseData['message'] ?? 'Erreur inconnue'}",
          ),
          backgroundColor: response.statusCode == 200 ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
        ),
      ));

      if (response.statusCode == 200) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Une erreur est survenue"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int focusIndex,
    bool isPassword = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([_focusNodes[focusIndex], _animationController]),
      builder: (context, child) {
        final hasFocus = _focusNodes[focusIndex].hasFocus;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: hasFocus
                  ? [
                      BoxShadow(
                        color: const Color(0xFFB3CBF2).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: controller,
              focusNode: _focusNodes[focusIndex],
              obscureText: isPassword,
              keyboardType: keyboardType,
              validator: validator,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: hasFocus 
                    ? const Color(0xFF4682B4)
                    : Colors.grey[600]),
                floatingLabelStyle: TextStyle(
                  color: hasFocus 
                      ? const Color(0xFF4682B4)
                      : Colors.grey[600],
                  fontSize: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 18, horizontal: 20),
                errorStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500),
              ),
              cursorColor: const Color(0xFF4682B4),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
          appBar: AppBar(
        title: const Text("Ajouter ",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 68, 138, 255),
        
        elevation: 10,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 3,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: firstNameController,
                            label: "Prénom",
                            icon: Icons.person_outlined,
                            focusIndex: 0,
                            validator: (value) =>
                                value!.isEmpty ? "Champ requis" : null,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: lastNameController,
                            label: "Nom",
                            icon: Icons.person_outline,
                            focusIndex: 1,
                            validator: (value) =>
                                value!.isEmpty ? "Champ requis" : null,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: emailController,
                            label: "Email",
                            icon: Icons.email_outlined,
                            focusIndex: 2,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Champ requis";
                              }
                              final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                              if (!emailRegex.hasMatch(value)) {
                                return "Email invalide";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: passwordController,
                            label: "Mot de passe",
                            icon: Icons.lock_outlined,
                            focusIndex: 3,
                            isPassword: true,
                            validator: (value) => value!.length < 6
                                ? "Au moins 6 caractères"
                                : null,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: phoneController,
                            label: "Téléphone",
                            icon: Icons.phone_iphone_outlined,
                            focusIndex: 4,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Champ requis";
                              }
                              if (!RegExp(r'^[0-9]{8}$').hasMatch(value)) {
                                return "8 chiffres requis";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: role,
                              items: const [
                                DropdownMenuItem(
                                  value: "caregiver",
                                  child: Text("Caregiver",
                                      style: TextStyle(fontSize: 16))),
                                DropdownMenuItem(
                                    value: "parents",
                                    child: Text("Parent",
                                        style: TextStyle(fontSize: 16))),
                              ],
                              onChanged: (value) =>
                                  setState(() => role = value!),
                              icon: const Icon(Icons.arrow_drop_down_circle,
                                  color: Color(0xFF4682B4)),
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                labelText: "Rôle",
                                prefixIcon: const Icon(Icons.group_outlined,
                                    color: Color(0xFF4682B4)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 15),
                              ),
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 30),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Color(0xFF4682B4))
                                : ElevatedButton(
                                    onPressed: addUser,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4682B4),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 40, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                      shadowColor:
                                          const Color(0xFF4682B4).withOpacity(0.3),
                                    ),
                                    child: const Text(
                                      "Ajouter Utilisateur",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}