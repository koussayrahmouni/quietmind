import 'package:flutter/material.dart';
import 'package:pidevmobileflutter/pages/screen/admin/listeuser.dart';
import 'package:pidevmobileflutter/pages/screen/caregiver/ProfilecaregiverScreen.dart';
import 'package:pidevmobileflutter/pages/screen/caregiver/listechild.dart';
import 'package:pidevmobileflutter/pages/screen/child/addchild.dart';

class DrawerScreen extends StatefulWidget {
  final String chappiemail;
  final String token;

  const DrawerScreen({
    super.key,
    required this.chappiemail,
    required this.token,
  });

  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
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
            colors: [Color(0xFF22B5C8), Color(0xFF7986CB)],
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
        widget.chappiemail,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      accountEmail: null,
      currentAccountPicture: const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person, color: Color(0xFF5C6BC0)),
      ),
    );
  }

  Widget _buildMenuItems() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildMenuItem(
          context,
          title: "Profile",
          icon: Icons.person_outlined,
          selectedIcon: Icons.person,
          route: () => ProfileScreen(
            email: widget.chappiemail,
            token: widget.token,
          ),
        ),
        _buildMenuItem(
          context,
          title: "Children",
          icon: Icons.child_care_outlined,
          selectedIcon: Icons.child_care,
          route: () => Listechild(
            email: widget.chappiemail,
            token: widget.token,
          ),
        ),
        _buildMenuItem(
          context,
          title: "Add child",
          icon: Icons.person_add_outlined,
          selectedIcon: Icons.person_add,
          route: () => AddChildScreen(
            email: widget.chappiemail,
            token: widget.token,
          ),
        ),
        _buildMenuItem(
          context,
          title: "Parent",
          icon: Icons.group_outlined,
          selectedIcon: Icons.group,
          route: () => Listeusers(
            email: widget.chappiemail,
            token: widget.token,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
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
