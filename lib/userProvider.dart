import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? token;
  String? username;

  void setUser(String token, String username) {
    this.token = token;
    this.username = username;
    notifyListeners();
  }
}
