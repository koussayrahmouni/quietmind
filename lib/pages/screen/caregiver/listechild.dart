import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../../configuration/config.dart';

class Listechild extends StatefulWidget {
  final String email;
  final String token;

  const Listechild({super.key, required this.email, required this.token});

  @override
  _ListechildState createState() => _ListechildState();
}

class _ListechildState extends State<Listechild> {
  List<dynamic> children = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    if (widget.token.isEmpty) {
      setState(() {
        errorMessage = "❌ Token invalide ou expiré";
        isLoading = false;
      });
    } else {
      fetchChildren();
    }
  }

  Future<void> fetchChildren() async {
    try {
      final response = await http.get(
        Uri.parse(fetchChildrenUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          children = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = data['message'] ?? "⚠️ Erreur lors du chargement des enfants.";
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

  Future<bool> _confirmDelete(BuildContext context, String userId) async {
    return await showDialog<bool>( 
      context: context, 
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_forever, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                const Text("Supprimer l'enfant", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("Cette action est irréversible. Confirmer la suppression ?",
                  textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text("Annuler"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ) ?? false;
  }

  Widget _buildDetailItem(IconData icon, String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color ?? Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87
                )),
                Text(value, style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.grey),
            title: Container(height: 16, color: Colors.grey),
            subtitle: Container(height: 14, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _errorMessageWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                height: 1.4
              )),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: fetchChildren,
            icon: const Icon(Icons.refresh),
            label: const Text("Réessayer"),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _childrenList() {
    return RefreshIndicator(
      onRefresh: fetchChildren,
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: children.length,
        itemBuilder: (context, index) {
          final user = children[index];
          final userId = (user['_id'] ?? user['id']).toString();

          return Dismissible(
            key: Key(userId),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) => _confirmDelete(context, userId),
            onDismissed: (direction) => deleteUser(userId),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    user['FirstName']?.isNotEmpty == true
                                        ? user['FirstName'][0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    "${user['FirstName']?.toString() ?? ''} ${user['LastName']?.toString() ?? ''}",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildDetailItem(Icons.cake, "Âge", user['Age']?.toString() ?? 'N/A'),
                            _buildDetailItem(Icons.people, "Genre", user['Gender']?.toString() ?? 'N/A'),
                            _buildDetailItem(Icons.assessment, "Autonomie", user['AutonomyLevel']?.toString() ?? 'N/A'),
                            _buildDetailItem(Icons.favorite, "Intérêts", user['FavoriteInterests']?.toString() ?? 'N/A'),
                            _buildDetailItem(Icons.accessibility, "Communication", user['ModeOfCommunication']?.toString() ?? 'N/A'),
                            _buildDetailItem(Icons.warning, "Allergies", user['AllergiesOrDietaryRestrictions']?.toString() ?? 'Aucune', color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8
                  ),
                  leading: Hero(
                    tag: 'avatar-$userId',
                    child: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        user['FirstName']?.isNotEmpty == true
                            ? user['FirstName'][0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  title: Text("${user['FirstName']?.toString() ?? ''} ${user['LastName']?.toString() ?? ''}",
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text("Âge: ${user['Age']?.toString() ?? 'N/A'}"),
                
                ),
              ),
            )
            .animate(delay: (100 * index).ms)
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.2, curve: Curves.easeOut),
          );
        },
      ),
    );
  }

  // Add the deleteUser method here
Future<void> deleteUser(String userId) async {
  final url = Uri.parse('http://localhost:5000/api/children/$userId');
  try {
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      setState(() {
        children.removeWhere((user) => user['_id'] == userId || user['id'].toString() == userId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Enfant supprimé avec succès")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? "Erreur lors de la suppression")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur réseau: $e")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text("Enfants ",
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
              Theme.of(context).colorScheme.surface
            ],
          ),
        ),
        child: isLoading
            ? _shimmerLoading()
            : errorMessage.isNotEmpty
                ? _errorMessageWidget()
                : children.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.child_friendly, 
                              size: 80, 
                              color: Theme.of(context).disabledColor),
                            const SizedBox(height: 20),
                            Text("Aucun enfant trouvé",
                              style: TextStyle(
                                color: Theme.of(context).disabledColor,
                                fontSize: 18
                              )),
                          ],
                        ),
                      )
                    : _childrenList(),
      ),
    );
  }
}
