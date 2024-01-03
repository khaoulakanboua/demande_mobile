import 'package:demande_mobile/ListDemande.dart';
import 'package:demande_mobile/addDemande.dart';
import 'package:demande_mobile/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(), // Change the home property to LoginPage
    );
  }
}
