import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../configuration/config.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _emailError = false;
  bool _passwordError = false;
  bool _invalidCredentials = false;

  Future<void> loginUser() async {
    setState(() {
      _emailError = !_isValidEmail(_emailController.text.trim());
      _passwordError = _passwordController.text.trim().length < 6;
      _invalidCredentials = false;
    });

    if (_emailError || _passwordError) return;

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final url = Uri.parse(loginUrl);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == 1) {
        String role = responseData['user']?['role']?.toString().toLowerCase().trim() ?? "";
        String token = responseData['token'] ?? "";
        String id = responseData['user']['id'].toString();

        if (role.endsWith("s")) {
          role = role.substring(0, role.length - 1);
        }

        switch (role) {
          case "caregiver":
            Navigator.pushNamed(context, "/homecaregiver",
                arguments: {"email": email, "token": token, "id": id});
            break;
          case "parent":
            Navigator.pushNamed(context, "/homeparent",
                arguments: {"email": email, "token": token, "parentId": id});
            break;
          case "admin":
            Navigator.pushNamed(context, "/homesuperadmin",
                arguments: {"email": email, "token": token, "id": id});
            break;
          default:
            showErrorPopup("Rôle invalide : accès refusé !");
        }
      } else {
        setState(() {
          _invalidCredentials = true;
        });
        showErrorPopup("Email ou mot de passe incorrect.");
      }
    } catch (error) {
      showErrorPopup("Erreur de connexion au serveur.");
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(email);
  }

  void showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Erreur",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white, // Arrière-plan blanc
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      "Log in",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black), // Texte noir pour contraste
                    ),
                    const SizedBox(height: 30),
               Image.asset(
  "assets/images/omega.jpg",
  width: 200,
  height: 200,
),

                    const SizedBox(height: 30),
                    _buildTextField(Icons.email, "Your Email", _emailController,
                        isError: _emailError),
                    _buildTextField(Icons.lock, "Password", _passwordController,
                        isPassword: true, isError: _passwordError),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, "/resetpassword"),
                        child: const Text("Forgot password?",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Color(0xFF0E4950))),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _invalidCredentials
                              ? Colors.red
                              : const Color(0xFFB3CBF2), // Couleur bouton
                          padding: const EdgeInsets.symmetric(
                              horizontal: 110, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 5,
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            color: _invalidCredentials
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ",
                            style: TextStyle(color: Colors.black)),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, "/signup"),
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Color(0xFF0E4950)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hintText,
      TextEditingController controller,
      {bool isPassword = false, bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black54),
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none),
          errorText: isError
              ? (hintText == "Your Email"
                  ? "Email invalide"
                  : "Au moins 6 caractères")
              : null,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        style: const TextStyle(color: Colors.black),
        
      ),
    );
  }
}
