import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import '../configuration/config.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> resetPasswordUser() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = "Email cannot be empty.";
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse(resetpasswordUrl);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        showSuccess("Reset password email sent successfully!");
        setState(() => _isLoading = false);
        Navigator.pushNamed(context, "/verificationresetpassword");
      } else {
        setState(() {
          _errorMessage = responseData["message"] ?? "Email not found.";
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = "Error connecting to server.";
        _isLoading = false;
      });
    }
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white, // Fond blanc
          ),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    "Recover Password",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 35),
                  SvgPicture.asset(
                    "assets/icons/undraw_forgot-password_odai.svg",
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: const Text(
                      "Enter your email address below and we'll send you an email with instructions on how to reset your password.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildTextField(),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : resetPasswordUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Recover Password",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200, // Gris clair proche du blanc
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _errorMessage != null ? Colors.red : Colors.transparent,
                width: 2,
              ),
            ),
            width: 280,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                icon: Icon(
                  Icons.email,
                  color: _errorMessage != null ? Colors.red : Colors.black,
                ),
                hintText: "Your Email",
                hintStyle: TextStyle(
                  color: _errorMessage != null ? Colors.redAccent : Colors.black54,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 5),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}
