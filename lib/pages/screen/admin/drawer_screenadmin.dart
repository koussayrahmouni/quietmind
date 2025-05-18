import 'package:flutter/material.dart';
import 'package:pidevmobileflutter/pages/screen/admin/ProfileAdminScreen.dart';
import 'package:pidevmobileflutter/pages/screen/admin/adduser.dart';
import 'package:pidevmobileflutter/pages/screen/admin/listeCaregiver%20.dart';
import 'package:pidevmobileflutter/pages/screen/admin/listeuser.dart';
import 'package:pidevmobileflutter/pages/screen/child/addchild.dart';

class DrawerScreenadmin extends StatefulWidget {
  final String email;
  final String token;

  const DrawerScreenadmin({super.key, required this.email, required this.token});

  @override
  _DrawerScreenadminState createState() => _DrawerScreenadminState();
}

class _DrawerScreenadminState extends State<DrawerScreenadmin> {
  String selectedItem = "Profile";

  void setSelectedItem(String item) {
    setState(() {
      selectedItem = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
           
            colors: [Color.fromARGB(255, 68, 138, 255), Colors.lightBlue],
          ),
        ),
        child: Column(
          children: <Widget>[
            _buildHeader(),
            Expanded(child: _buildMenuItems()),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(color: Colors.transparent),
      margin: EdgeInsets.zero,
      accountName: Text(
        widget.email,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      accountEmail: null,
      currentAccountPicture: const CircleAvatar(
        backgroundImage: AssetImage('assets/images/Group.jpg'),
        radius: 30,
      ),
    );
  }

  Widget _buildMenuItems() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildMenuItem(
          title: "Profile",
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          route: () => ProfileadminScreen(email: widget.email, token: widget.token),
        ),
        _buildMenuItem(
          title: "Parents",
          icon: Icons.group_outlined,
          selectedIcon: Icons.group,
          route: () => Listeusers(email: widget.email, token: widget.token),
        ),
        _buildMenuItem(
          title: "Caregivers",
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          route: () => ListeCaregiver(email: widget.email, token: widget.token),
        ),
        _buildMenuItem(
          title: "Add Parent or Caregiver",
          icon: Icons.person_add_outlined,
          selectedIcon: Icons.person_add,
          route: () => Adduser(email: widget.email, token: widget.token),
        ),
        _buildMenuItem(
          title: "Add Child",
          icon: Icons.child_care_outlined,
          selectedIcon: Icons.child_care,
          route: () => AddChildScreen(email: widget.email, token: widget.token),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required IconData selectedIcon,
    required Widget Function() route,
  }) {
    final isSelected = selectedItem == title;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: Colors.white.withOpacity(isSelected ? 1 : 0.8),
          size: 26,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(isSelected ? 1 : 0.8),
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.chevron_right, color: Colors.white)
            : null,
        onTap: () {
          setSelectedItem(title);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => route()),
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.logout, size: 20),
          label: const Text("LOG OUT"),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.redAccent.withOpacity(0.9),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            shadowColor: Colors.redAccent.withOpacity(0.3),
          ),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/login",
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}
