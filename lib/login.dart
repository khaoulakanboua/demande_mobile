import 'dart:convert';
import 'package:demande_mobile/ListDemande.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> loginUser() async {
    final String url = 'http://192.168.1.3:8060/api/auth/signin';

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
         print('Login success: ${jwtToken}');
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );

        // Store the token in a secure storage (e.g., flutter_secure_storage)
        // Handle successful login (e.g., navigate to a new screen)
        //Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // Handle login error (e.g., show an error message)
        print('Login failed: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error during login: $e');
    }
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
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => loginUser(),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LoginPage(),
  ));
}
