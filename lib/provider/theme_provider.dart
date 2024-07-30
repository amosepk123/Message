import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.dark;
  bool get isDakMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyThemes {
  static final darkTheme = ThemeData(
      appBarTheme: AppBarTheme(color: Colors.grey),
      scaffoldBackgroundColor: Colors.grey.shade900,
      primaryColor: Colors.black,
      colorScheme: ColorScheme.dark(),
      iconTheme: IconThemeData(color: Colors.purple.shade200, opacity: 0.8));
  static final lightTheme = ThemeData(
    appBarTheme: AppBarTheme(color: Colors.grey),
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.white,
    colorScheme: ColorScheme.light(),
  );
}
