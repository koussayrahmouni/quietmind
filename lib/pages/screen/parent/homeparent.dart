import 'package:flutter/material.dart';
import 'package:pidevmobileflutter/pages/screen/parent/drawer_screenparent.dart';
import '../../../functions/dashboard_page.dart';

class Homeparent extends StatelessWidget {
  const Homeparent({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String email = args?['email'] ?? "Unknown";
    final String token = args?['token'] ?? "";
    final String parentId = args?['parentId'] ?? "Unknown";
    final String childId = args?['childId'] ?? "";

    return Scaffold(
      drawer: DrawerScreenparent(
        email: email,
        token: token,
        parentId: parentId,
        childId: childId,
      ),
      appBar: AppBar(
        title: const Text(
          "Quiet Mind",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 8, 143, 164),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Color.fromARGB(255, 27, 50, 194)),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
      ),
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: const DashboardPage(),
      ),
    );
  }
}