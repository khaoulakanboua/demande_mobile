import 'dart:convert';
import 'package:demande_mobile/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  Future<void> registerUser() async {
    final String url = 'http://192.168.8.195:8060/api/auth/signup';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text,
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'email': emailController.text,
          'phoneNumber': phoneNumberController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Registration successful, navigate to the login page
        print('Registration successful');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        // Handle registration error (e.g., show an error message)
        print('Registration failed: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error during registration: $e');
    }
  }

  void navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Page'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 5),
              Text(
                'Create an Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              buildTextField(
                controller: usernameController,
                labelText: 'Username',
                icon: Icons.person,
              ),
              SizedBox(height: 5),
              buildTextField(
                controller: firstNameController,
                labelText: 'First Name',
                icon: Icons.person,
              ),
              SizedBox(height: 5),
              buildTextField(
                controller: lastNameController,
                labelText: 'Last Name',
                icon: Icons.person,
              ),
              SizedBox(height: 5),
              buildTextField(
                controller: emailController,
                labelText: 'Email',
                icon: Icons.email,
              ),
              SizedBox(height: 5),
              buildTextField(
                controller: phoneNumberController,
                labelText: 'Phone Number',
                icon: Icons.phone,
              ),
              SizedBox(height: 5),
              buildTextField(
                controller: passwordController,
                labelText: 'Password',
                icon: Icons.lock,
                isPassword: true,
                isPasswordVisible: isPasswordVisible,
                togglePasswordVisibility: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => registerUser(),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF54408C),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Register', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 10), // Ajout d'un espace de 10 pixels
              TextButton(
                onPressed: () => navigateToLogin(),
                child: Text('Already have an Account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? togglePasswordVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey), // Bordure désactivée
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue), // Bordure activée
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: togglePasswordVisibility,
              )
            : null,
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RegistrationPage(),
  ));
}
