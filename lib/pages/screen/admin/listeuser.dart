import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../configuration/config.dart';  // Assurez-vous que vous avez configuré ces variables correctement

class Listeusers extends StatefulWidget {
  final String email;
  final String token;

  const Listeusers({super.key, required this.email, required this.token});

  @override
  _ListeusersState createState() => _ListeusersState();
}

class _ListeusersState extends State<Listeusers> {
  List<dynamic> users = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // Fonction pour récupérer la liste des utilisateurs
  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(fetchUsersUrl),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['data'] != null) {
        setState(() {
          users = data['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "⚠️ Erreur: ${data['message'] ?? 'Impossible de charger les utilisateurs'}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "❌ Erreur réseau: $e";
        isLoading = false;
      });
    }
  }

  // Fonction pour affecter un enfant à un parent
  Future<void> _assignChild(String childId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse(assignChildUrll),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"parent_id": userId, "child_id": childId}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Enfant affecté avec succès")),
        );
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Erreur lors de l'affectation")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur réseau: $e")),
      );
    }
  }

  // Fonction pour supprimer l'affectation d'un enfant
  Future<void> _unassignChild(Map<String, dynamic> child) async {
    final String url = "$unassignChildUrll${child['id']}";

    final body = {
      'LastName': child['LastName'],
      'FirstName': child['FirstName'],
      'Age': child['Age'],
      'Gender': child['Gender'],
      'AutonomyLevel': child['AutonomyLevel'],
      'SensoryPreferences': child['SensoryPreferences'],
      'FavoriteInterests': child['FavoriteInterests'],
      'ModeOfCommunication': child['ModeOfCommunication'],
      'CalmingStrategies': child['CalmingStrategies'],
      'AllergiesOrDietaryRestrictions': child['AllergiesOrDietaryRestrictions'],
      'parent_id': null,
    };

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Affectation supprimée avec succès")),
        );
        setState(() {});
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Erreur lors de la suppression")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur réseau: $e")),
      );
    }
  }

  // Fonction pour afficher les enfants d'un parent
  void _showChildrenPopup(String userId, String userName) async {
    List<dynamic> children = [];

    try {
      final response = await http.get(
        Uri.parse(showChildrenPopupUrl),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['data'] != null) {
        children = data['data'];
      }
    } catch (e) {
      print("Erreur réseau: $e");
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (popupContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(15),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "Enfants de $userName",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFFB3CBF2),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: children.map((child) {
                      bool isAssigned = child['parent_id'] != null;
                      final last = child['LastName'] ?? '';
                      final first = child['FirstName'] ?? '';
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("👤 Nom: $last"),
                              Text("👤 Prénom: $first"),
                              const SizedBox(height: 10),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (isAssigned) {
                                      await _unassignChild(child);
                                    } else {
                                      await _assignChild(child['id'].toString(), userId);
                                    }
                                    Navigator.pop(context);
                                    _showChildrenPopup(userId, userName);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isAssigned
                                        ? Colors.red
                                        : const Color(0xFFB3CBF2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: Text(
                                    isAssigned
                                        ? 'Supprimer l\'affectation de $last $first'
                                        : 'Affecter à $userName',
                                    style: const TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Fermer", style: TextStyle(color: Color(0xFFB3CBF2), fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget pour afficher les erreurs
  Widget _errorMessageWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 18)),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: fetchUsers,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("Réessayer"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB3CBF2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
             appBar: AppBar(
        title: const Text("Parents",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 68, 138, 255),
        
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
            colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 211, 213, 214)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? _errorMessageWidget()
                : users.isEmpty
                    ? const Center(child: Text("📭 Aucun utilisateur trouvé.", style: TextStyle(fontSize: 18)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                            child: ListTile(
                              tileColor: Colors.white.withOpacity(0.9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              title: Text(
                                "👤 ${user['firstName'] ?? 'Nom inconnu'} ${user['lastName'] ?? ''}",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              subtitle: Text(
                                "📧 ${user['email'] ?? 'Non disponible'}\n🎭 ${user['role'] ?? 'Non spécifié'}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFFB3CBF2)),
                                onPressed: () => _showChildrenPopup(user['id'].toString(), user['firstName'] ?? ''),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
