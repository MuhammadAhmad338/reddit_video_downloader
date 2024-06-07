// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeProviderController extends ChangeNotifier {
  ThemeData _currentTheme = lightTheme;
  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    _currentTheme = _currentTheme == lightTheme ? darkTheme : lightTheme;
    notifyListeners();
  }
}

final lightTheme = ThemeData.light().copyWith(
  primaryColor: Colors.blue,
  hintColor: Colors.blueAccent,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    color: Colors.blue,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  ),
  tabBarTheme: const TabBarTheme(
    labelColor: Colors.blue,
    unselectedLabelColor: Colors.grey,
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.blue,
    textTheme: ButtonTextTheme.primary,
  ),
  // Add more customizations as needed
);

final darkTheme = ThemeData.dark().copyWith(
  primaryColor: Colors.indigo,
  hintColor: Colors.indigoAccent,
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: const AppBarTheme(
    color: Colors.indigo,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  tabBarTheme: const TabBarTheme(
    labelColor: Colors.indigo,
    unselectedLabelColor: Colors.grey,
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.indigo,
    textTheme: ButtonTextTheme.primary,
  ),
);
