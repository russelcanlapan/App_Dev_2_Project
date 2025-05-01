import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = Colors.blue;

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setPrimaryColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        _primaryColor = Colors.red;
        break;
      case 'orange':
        _primaryColor = Colors.orange;
        break;
      case 'yellow':
        _primaryColor = Colors.yellow;
        break;
      case 'green':
        _primaryColor = Colors.green;
        break;
      case 'blue':
        _primaryColor = Colors.blue;
        break;
      case 'purple':
        _primaryColor = Colors.purple;
        break;
      default:
        _primaryColor = Colors.blue;
    }
    notifyListeners();
  }

  ThemeData get theme => _isDarkMode ? _darkTheme : _lightTheme;

  ThemeData get _lightTheme => ThemeData(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    colorScheme: ColorScheme.light(
      primary: _primaryColor,
      onPrimary: Colors.white,
      secondary: Colors.black,
      onSecondary: Colors.white,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
    ),
    iconTheme: IconThemeData(color: Colors.black),
  );

  ThemeData get _darkTheme => ThemeData(
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    colorScheme: ColorScheme.dark(
      primary: _primaryColor,
      onPrimary: Colors.white,
      secondary: Colors.white,
      onSecondary: Colors.black,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
    iconTheme: IconThemeData(color: Colors.white),
  );
} 