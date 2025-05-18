import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../configuration/config.dart';


class ListeCaregiver extends StatefulWidget {
  final String email;
  final String token;

  const ListeCaregiver({super.key, required this.email, required this.token});

  @override
  _ListeCaregiverState createState() => _ListeCaregiverState();
}

class _ListeCaregiverState extends State<ListeCaregiver> {
  List<dynamic> caregivers = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchCaregivers();
  }

  Future<void> fetchCaregivers() async {
    try {
      final response = await http.get(
        Uri.parse(fetchCaregiversUrl),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['data'] != null) {
        setState(() {
          caregivers = data['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              "⚠️ Erreur: ${data['message'] ?? 'Impossible de charger les caregivers'}";
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

  Future<void> _unassignChild(String childId, String caregiverId, BuildContext popupContext) async {
      final url = "$unassignChildUrl$childId/$caregiverId";
    try {
      final response = await http.delete(Uri.parse(url));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Affectation supprimée avec succès")),
        );
        setState(() {}); // Rafraîchir l'UI
      } else {
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

  Future<void> _assignChild(String childId, String caregiverId, BuildContext popupContext) async {
    try {
      final response = await http.post(
        Uri.parse(assignChildUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"childId": childId, "caregiverId": caregiverId}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enfant affecté au caregiver avec succès")),
        );
        setState(() {}); // Rafraîchir l'UI
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

  Future<List<String>> _fetchAssignedChildren(String caregiverId) async {
    final url = "$fetchAssignedChildrenUrl$caregiverId";
    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['data'] != null) {
        return List<String>.from(data['data'].map((child) => child['id'].toString()));
      }
    } catch (e) {
      print("Erreur réseau lors de la récupération des enfants: $e");
    }
    return [];
  }

  bool _isChildAssigned(String childId, List<String> assignedChildren) {
    return assignedChildren.contains(childId);
  }

  void _showChildrenPopup(String caregiverId, String caregiverName) async {
    
    List<dynamic> children = [];
    List<String> assignedChildren = await _fetchAssignedChildren(caregiverId);

    try {
      final response = await http.get(Uri.parse(showChildrenPopupUrl));
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
                    "Enfants de $caregiverName",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFFB3CBF2), // Couleur pour le titre
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: children.map((child) {
                      bool isAssigned = _isChildAssigned(child['id'].toString(), assignedChildren);
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("👤 Nom: ${child['LastName'] ?? 'N/A'}"),
                              Text("👤 Prénom: ${child['FirstName'] ?? 'N/A'}"),
                              Text("🎂 Âge: ${child['Age'] ?? 'N/A'}"),
                              Text("⚧ Sexe: ${child['Gender'] ?? 'N/A'}"),
                              Text("🧩 Autonomie: ${child['AutonomyLevel'] ?? 'N/A'}"),
                              Text("🎨 Intérêts: ${child['FavoriteInterests'] ?? 'N/A'}"),
                              Text("🗣 Communication: ${child['ModeOfCommunication'] ?? 'N/A'}"),
                              Text("🧘 Stratégies de calme: ${child['CalmingStrategies'] ?? 'N/A'}"),
                              Text("🚫 Allergies: ${child['AllergiesOrDietaryRestrictions'] ?? 'N/A'}"),
                              const SizedBox(height: 10),
                              Center(
                                child: StatefulBuilder(
                                  builder: (popupContext, setStatePopup) {
                                    return ElevatedButton(
                                      onPressed: () async {
                                        if (isAssigned) {
                                          await _unassignChild(
                                            child['id'].toString(),
                                            caregiverId,
                                            popupContext,
                                          );
                                        } else {
                                          await _assignChild(
                                            child['id'].toString(),
                                            caregiverId,
                                            popupContext,
                                          );
                                        }
                                        setStatePopup(() {
                                          isAssigned = !isAssigned;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isAssigned ? Colors.red : const Color(0xFFB3CBF2),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: Text(
                                        isAssigned ? "Supprimer l'affectation" : "Affecter à $caregiverName",
                                        style: const TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                    );
                                  },
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

  Widget _errorMessageWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 18)),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: fetchCaregivers,
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
        title: const Text("Caregivers ",
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
                : caregivers.isEmpty
                    ? const Center(child: Text("📭 Aucun caregiver trouvé.", style: TextStyle(fontSize: 18)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: caregivers.length,
                        itemBuilder: (context, index) {
                          final caregiver = caregivers[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                            child: ListTile(
                              tileColor: Colors.white.withOpacity(0.9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              title: Text(
                                "👤 ${caregiver['firstName'] ?? 'Nom inconnu'} ${caregiver['lastName'] ?? ''}",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              subtitle: Text(
                                "📧 ${caregiver['email']}\n📞 ${caregiver['phone'] ?? 'Non disponible'}\n🎭 ${caregiver['role'] ?? 'Non disponible'}\n🔵 ${caregiver['etat'] ?? 'Non spécifié'}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFFB3CBF2)),
                                onPressed: () => _showChildrenPopup(caregiver['id'].toString(), caregiver['firstName']),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
