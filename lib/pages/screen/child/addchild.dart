import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../configuration/config.dart';

class AddChildScreen extends StatefulWidget {
  final String email;
  final String token;

  const AddChildScreen({super.key, required this.email, required this.token});

  @override
  _AddChildScreenState createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  // Controllers
  TextEditingController lastNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  // Dropdown values
  String? _selectedGender;
  String? _selectedAutonomyLevel;
  static const String defaultValue = "Non spécifié";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

Future<void> addChild() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  // Create a map to hold the child data
  final Map<String, dynamic> childData = {
    "LastName": lastNameController.text.trim(),
    "FirstName": firstNameController.text.trim(),
    "Age": int.tryParse(ageController.text) ?? 0,
    "Gender": _selectedGender ?? defaultValue,
    "AutonomyLevel": _selectedAutonomyLevel ?? defaultValue,
    "AllergiesOrDietaryRestrictions": null, // Ensure this field can accept NULL
    "parent_id": null, // Ensure this field can accept NULL or provide a valid parent ID
    "created_at": DateTime.now().toIso8601String(), // Use proper datetime format
  };

  try {
    final response = await http.post(
      Uri.parse(addChildUrl), // Your API endpoint URL
      headers: {
        "Authorization": "Bearer ${widget.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode(childData),
    );

    // Check if the request was successful (status code 201: Created)
    if (response.statusCode == 201) {
      _showSuccessFeedback();
      await Future.delayed(const Duration(milliseconds: 1500));
      Navigator.pop(context);
    } else {
      // Log the error response for debugging
      print("Error Response Body: ${response.body}");
      final errorMessage = jsonDecode(response.body)['message'] ?? 'Unknown error';
      _showErrorFeedback(errorMessage);
    }
  } catch (error) {
    // Log any exception that might occur during the request
    print("Error: $error");
    _showErrorFeedback("Erreur réseau. Vérifiez votre connexion.");
  } finally {
    setState(() => _isLoading = false);
  }
}


  void _showSuccessFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text("Enfant ajouté avec succès !"),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        validator: (value) => value == null || value.trim().isEmpty ? "$label est requis" : null,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? selectedValue,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        ),
        items: items.map((value) => DropdownMenuItem(
          value: value,
          child: Text(value, style: const TextStyle(fontSize: 16)),
        )).toList(),
        onChanged: onChanged,
        dropdownColor: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        icon: const Icon(Icons.arrow_drop_down, size: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
        title: const Text("Enfant ",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF22B5C8),
        elevation: 10,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField("Nom", lastNameController, icon: Icons.person_outline),
                    const SizedBox(height: 12),
                    _buildTextField("Prénom", firstNameController, icon: Icons.person_pin_circle_outlined),
                    const SizedBox(height: 12),
                    _buildTextField("Âge", ageController, icon: Icons.cake_outlined, isNumber: true),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      label: "Genre",
                      icon: Icons.transgender,
                      selectedValue: _selectedGender,
                      items: const ["Homme", "Femme"],
                      onChanged: (value) => setState(() => _selectedGender = value),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      label: "Niveau d'autonomie",
                      icon: Icons.accessibility_new,
                      selectedValue: _selectedAutonomyLevel,
                      items: const ["Indépendant", "Assistance partielle", "Dépendant"],
                      onChanged: (value) => setState(() => _selectedAutonomyLevel = value),
                    ),
                    const SizedBox(height: 32),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB3CBF2)))
                          : ElevatedButton(
                              onPressed: addChild,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB3CBF2),
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 2,
                                shadowColor: Colors.blue[100],
                              ),
                              child: const Text("AJOUTER L'ENFANT",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                  color: Colors.white,
                                ),
                              ),
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
