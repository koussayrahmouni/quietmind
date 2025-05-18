import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'configuration/config.dart';

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

class _ModifierProfilParentState extends State<ModifierProfilParent> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final url = Uri.parse("$fetchUserProfileUrl${widget.userId}");
    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData["success"] == 1) {
        final userData = responseData["data"];
        setState(() {
          firstNameController.text = userData["firstName"] ?? "";
          lastNameController.text = userData["lastName"] ?? "";
          emailController.text = userData["email"] ?? "";
          phoneController.text = userData["phone"] ?? "";
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              responseData["message"] ?? "Erreur de récupération des données.";
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = "Erreur réseau: $error";
        isLoading = false;
      });
    }
  }

  Future<void> updateUserProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Création du corps de la requête avec les valeurs non vides
    final body = jsonEncode({
      "firstName": firstNameController.text.isNotEmpty ? firstNameController.text : null,
      "lastName": lastNameController.text.isNotEmpty ? lastNameController.text : null,
      "email": emailController.text.isNotEmpty ? emailController.text : null,
      "phone": phoneController.text.isNotEmpty ? phoneController.text : null,
    });

    // Suppression des champs nulls pour ne pas les envoyer
    final filteredBody = jsonDecode(body)..removeWhere((key, value) => value == null);

    final url = Uri.parse("$updateUserProfileUrl${widget.userId}");
    
    try {
      final response = await http.patch(
        url,
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode(filteredBody),
      );
      
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData["success"] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Profil mis à jour avec succès !")),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          errorMessage =
              responseData["message"] ?? "Erreur lors de la mise à jour.";
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = "Erreur réseau: $error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc pour l'écran
      appBar: AppBar(
        title: const Text(
          "Modifier Profil",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFB3CBF2), // AppBar en pastel bleu
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0.5,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFB3CBF2),
                          width: 2,
                        ), // Bordure pastel bleu
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 30.0,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (errorMessage.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        errorMessage,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: firstNameController,
                              decoration: InputDecoration(
                                labelText: "Prénom",
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Color(0xFFB3CBF2),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? "Champ requis" : null,
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: lastNameController,
                              decoration: InputDecoration(
                                labelText: "Nom",
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  color: Color(0xFFB3CBF2),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (value) =>
                                  value!.isEmpty ? "Champ requis" : null,
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: "Email",
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: Color(0xFFB3CBF2),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (value) => value!.contains("@")
                                  ? null
                                  : "Email invalide",
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: phoneController,
                              decoration: InputDecoration(
                                labelText: "Téléphone",
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Color(0xFFB3CBF2),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) =>
                                  value!.isNotEmpty ? null : "Champ requis",
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: updateUserProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xFFB3CBF2,
                                  ), // Bouton pastel bleu
                                  elevation: 5,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Enregistrer",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
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
            ),
    );
  }
}
