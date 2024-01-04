import 'dart:convert';
import 'package:demande_mobile/ListDemande.dart';
import 'package:demande_mobile/UserListDemande.dart';
import 'package:demande_mobile/register.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> loginUser() async {
    final String url = 'http://192.168.8.195:8060/api/auth/signin';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Assuming the server returns a JWT in the response
        String jwtToken = responseData['accessToken'];
         String username = responseData['username'];
        print('Login success: ${jwtToken}');
        final prefs = await SharedPreferences.getInstance();
         prefs.setString('token', jwtToken);
         prefs.setString('username', username);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserListPage()),
        );
      } else {
        // Handle login error (e.g., show an error message)
        print('Login failed: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error during login: $e');
    }
  }

  void navigateToRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => loginUser(),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Login', style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => navigateToRegistration(),
              child: Text('Don\'t have an account? Register here'),
            ),
          ],
        ),
      ),
    );
  }
}


