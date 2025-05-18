import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../configuration/config.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  bool _firstNameError = false;
  bool _lastNameError = false;
  bool _phoneError = false;
  bool _emailError = false;
  bool _isLoading = false;
  bool _emailExistsError = false;

  String _selectedCountryCode = "+216";

  Future<void> signupUser() async {
    setState(() {
      _firstNameError = firstNameController.text.trim().length < 4;
      _lastNameError = lastNameController.text.trim().length < 4;
      _phoneError = phoneNumberController.text.trim().isEmpty || phoneNumberController.text.length != 8;
      _emailError = !emailController.text.contains("@gmail.com") || emailController.text.trim().isEmpty;
      _emailExistsError = false;
    });

    if (_firstNameError || _lastNameError || _phoneError || _emailError) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    var signupBody = {
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "phone": "$_selectedCountryCode${phoneNumberController.text}",
      "email": emailController.text,
    };

    var response = await http.post(
      Uri.parse(signupUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(signupBody),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup Successful! Check your email.")),
      );
      Navigator.pushNamed(context, "/verificationresetpassword");
    } else if (response.statusCode == 400) {
      setState(() {
        _emailExistsError = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup Failed! Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // Fond blanc
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 30),
                Image.asset(
  "assets/images/omega.jpg",
  width: 200,
  height: 200,
)
,
                const SizedBox(height: 35),
                _buildTextField(Icons.person, "First Name", firstNameController, isError: _firstNameError),
                if (_firstNameError) _errorMessage("Minimum 4 characters required"),
                const SizedBox(height: 10),

                _buildTextField(Icons.person, "Last Name", lastNameController, isError: _lastNameError),
                if (_lastNameError) _errorMessage("Minimum 4 characters required"),
                
                _phoneNumberField(),

                _buildTextField(Icons.email, "Your Email", emailController, isEmail: true, isError: _emailError || _emailExistsError),
                if (_emailError) _errorMessage("Invalid email address"),
                if (_emailExistsError) _errorMessage("Email is already in use"),

                const SizedBox(height: 25),
                _buildSignupButton(),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ", style: TextStyle(color: Colors.black54)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, "/login"),
                      child: const Text("Log in", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : signupUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: _emailExistsError ? Colors.red : Color(0xFFB3CBF2),
        padding: const EdgeInsets.symmetric(horizontal: 91, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            )
          : const Text("Sign up", style: TextStyle(fontSize: 22, color: Colors.white)),
    );
  }

  Widget _errorMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(color: Colors.red, fontSize: 14)),
      ),
    );
  }

  Widget _phoneNumberField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200, // Gris clair
              borderRadius: BorderRadius.circular(10),
              border: _phoneError ? Border.all(color: Colors.red, width: 2) : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButton<String>(
              value: _selectedCountryCode,
              dropdownColor: Colors.grey.shade200,
              style: const TextStyle(color: Colors.black),
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCountryCode = newValue!;
                });
              },
              items: ["+216"].map((String code) => DropdownMenuItem(value: code, child: Text(code))).toList(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: _buildTextField(Icons.phone, "Phone Number", phoneNumberController, keyboardType: TextInputType.number, isError: _phoneError, maxLength: 8)),
        ],
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hintText, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, bool isEmail = false, bool isError = false, int? maxLength}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.grey.shade200, // Gris clair proche du blanc
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }
}
