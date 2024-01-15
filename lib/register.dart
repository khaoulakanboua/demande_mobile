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

  Future<void> registerUser() async {
    final String url = 'http://192.168.56.1:8060/api/auth/signup';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Page'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => registerUser(),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('Register', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RegistrationPage(),
  ));
}
