import 'package:flutter/material.dart';

class AppController extends ChangeNotifier {

  static AppController instance = AppController(); // aq estanciamos ela mesma

  bool isDArtTheme = false;
  changeTheme(){
    isDArtTheme = !isDArtTheme; // aq falo se ele for diferente de false vira true
    notifyListeners();
  }

}