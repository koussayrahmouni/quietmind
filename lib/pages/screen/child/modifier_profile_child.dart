import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../configuration/config.dart';

class ModifierProfileChild extends StatefulWidget {
  final Map<String, dynamic> childData;
  final String token;
  final String parentId;

  const ModifierProfileChild({
    super.key,
    required this.childData,
    required this.token,
    required this.parentId,
  });

  @override
  _ModifierProfileChildState createState() => _ModifierProfileChildState();
}

class _ModifierProfileChildState extends State<ModifierProfileChild> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController ageController;
  late TextEditingController genderController;
  late TextEditingController autonomyController;
  late TextEditingController sensoryController;
  late TextEditingController interestsController;
  late TextEditingController communicationController;
  late TextEditingController calmingController;
  late TextEditingController allergiesController;

  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    firstNameController    = TextEditingController(text: widget.childData['FirstName'] ?? '');
    lastNameController     = TextEditingController(text: widget.childData['LastName'] ?? '');
    ageController          = TextEditingController(text: widget.childData['Age']?.toString() ?? '');
    genderController       = TextEditingController(text: widget.childData['Gender'] ?? '');
    autonomyController     = TextEditingController(text: widget.childData['AutonomyLevel'] ?? '');
    sensoryController      = TextEditingController(text: widget.childData['SensoryPreferences'] ?? '');
    interestsController    = TextEditingController(text: widget.childData['FavoriteInterests'] ?? '');
    communicationController= TextEditingController(text: widget.childData['ModeOfCommunication'] ?? '');
    calmingController      = TextEditingController(text: widget.childData['CalmingStrategies'] ?? '');
    allergiesController    = TextEditingController(text: widget.childData['AllergiesOrDietaryRestrictions'] ?? '');
  }

  Future<void> updateChild() async {
    // Essaye plusieurs clés pour récupérer l'id
    final rawId = widget.childData['id'] 
                ?? widget.childData['Id'] 
                ?? widget.childData['child_id'];
    if (rawId == null) {
      setState(() => errorMessage = "⚠️ ID de l'enfant introuvable.");
      return;
    }
    final id = rawId.toString();
    final String apiUrl = "$updateChildUrl/$id";

    final Map<String, dynamic> updatedData = {
      "id": id,
      "parent_id": widget.parentId,
      "FirstName": firstNameController.text,
      "LastName": lastNameController.text,
      "Age": int.tryParse(ageController.text) ?? 0,
      "Gender": genderController.text,
      "AutonomyLevel": autonomyController.text,
      "SensoryPreferences": sensoryController.text,
      "FavoriteInterests": interestsController.text,
      "ModeOfCommunication": communicationController.text,
      "CalmingStrategies": calmingController.text,
      "AllergiesOrDietaryRestrictions": allergiesController.text,
    };

    setState(() => isLoading = true);
    try {
      final resp = await http.patch(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: jsonEncode(updatedData),
      );
      final body = jsonDecode(resp.body);
      if (resp.statusCode == 200 && body["success"] == true) {
        Navigator.pop(context, true);
      } else {
        setState(() => errorMessage = body["message"] ?? "❌ Échec de la mise à jour.");
      }
    } catch (e) {
      setState(() => errorMessage = "❌ Erreur réseau : $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildTextField(TextEditingController c, String label, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: c,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier Profil", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB3CBF2), Color(0xFFDCE6F2)],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          _buildTextField(firstNameController, "Prénom"),
                          _buildTextField(lastNameController, "Nom"),
                          _buildTextField(ageController, "Âge", isNumeric: true),
                          _buildTextField(genderController, "Genre"),
                          _buildTextField(autonomyController, "Autonomie"),
                          _buildTextField(sensoryController, "Préférences sensorielles"),
                          _buildTextField(interestsController, "Intérêts favoris"),
                          _buildTextField(communicationController, "Mode de communication"),
                          _buildTextField(calmingController, "Stratégies d'apaisement"),
                          _buildTextField(allergiesController, "Allergies / Restrictions alimentaires"),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: updateChild,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB3CBF2),
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text("Enregistrer", style: TextStyle(fontSize: 18, color: Colors.white)),
                            ),
                          ),
                          if (errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 15),
                            Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)),
                          ],
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
