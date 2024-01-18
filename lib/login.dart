import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:demande_mobile/ListDemande.dart';
import 'package:demande_mobile/UserListDemande.dart';
import 'package:demande_mobile/register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  Future<void> loginUser() async {
    final String url = 'http://192.168.1.2:8060/api/auth/signin';

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

        String jwtToken = responseData['accessToken'];
        String username = responseData['username'];
        int id = responseData['id'];
        List<dynamic> roles = responseData['roles'];

        print('Login success: ${jwtToken}');
        print('User roles: $roles');

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', jwtToken);
        prefs.setString('username', username);
        prefs.setInt('id', id);
        prefs.setStringList(
            'roles', roles.map((role) => role.toString()).toList());

        // Navigate based on user roles
        if (roles.contains('ROLE_ADMIN')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        } else if (roles.contains('ROLE_USER')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserListPage()),
          );
        } else {
          // Handle other roles or navigate to a default page
          print('Unknown user role. Navigating to a default page.');
          // You can navigate to a default page or display an error message here.
        }
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text(
                'Welcome Back to School Event!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/graduated.png',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 30),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your username',
                    prefixIcon: Icon(Icons.person),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: ElevatedButton(
                  onPressed: () => loginUser(),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF54408C),
                    minimumSize: Size(double.infinity, 50),
                  ),
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
      ),
    );
  }
}
