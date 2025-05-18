import 'package:flutter/material.dart';
import 'package:pidevmobileflutter/pages/screen/admin/drawer_screenadmin.dart';

class DrawerScreenparent extends StatefulWidget {
  final String email;
  final String token;
  final String parentId;
  final String childId;

  const DrawerScreenparent({
    super.key,
    required this.email,
    required this.token,
    required this.parentId,
    required this.childId,
  });

  @override
  _DrawerScreenparentState createState() => _DrawerScreenparentState();
}

class _DrawerScreenparentState extends State<DrawerScreenparent> with SingleTickerProviderStateMixin {
  String selectedItem = "Profile Parent";
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _animationController.forward();
  }

  void setSelectedItem(String item) {
    setState(() {
      selectedItem = item;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6BAED9), Color(0xFFB3CDE0)],
            stops: [0.3, 0.7],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Animated Header
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  accountName: Text(
                    widget.email,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 2,
                          offset: Offset(1, 1),
                        )
                      ],
                    ),
                  ),
                  accountEmail: null,
                  currentAccountPicture: Hero(
                    tag: 'parent-avatar',
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.3),
                      radius: 30,
                      child: const ClipOval(
                        child: Image(
                          image: AssetImage('assets/images/Group.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 20),
                itemCount: 2,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.3),
                  indent: 20,
                  endIndent: 20,
                ),
                itemBuilder: (context, index) {
                  final items = [
                    {
                      'text': "Profile Parent",
                      'icon': Icons.person,
                      'route': "/profileparent",
                    },
                    {
                      'text': "Profile Child",
                      'icon': Icons.child_care,
                      'route': "/profilechild",
                    },
                  ];
                  
                  return AnimatedDrawerItem(
                    text: items[index]['text'] as String,
                    icon: items[index]['icon'] as IconData,
                    selected: selectedItem == items[index]['text'],
                    onTap: () {
                      setSelectedItem(items[index]['text'] as String);
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        items[index]['route'] as String,
                        arguments: {
                          "email": widget.email,
                          "token": widget.token,
                          "parentId": widget.parentId,
                          "childId": widget.childId,
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Animated Logout Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Log Out'),
                        content: const Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                "/login",
                                (route) => false,
                              );
                            },
                            child: const Text('Log Out'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.15),
                        ],
                      ),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white),
                      title: const Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedDrawerItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const AnimatedDrawerItem({
    required this.text,
    required this.icon,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected 
                  ? Colors.white.withOpacity(0.5)
                  : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            gradient: selected
                ? LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 20),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (selected)
                const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const AnimatedButton({
    required this.child,
    required this.onPressed,
    super.key,
  });

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}