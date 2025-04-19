import 'package:flutter/material.dart';
import 'package:verbose_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:verbose_ai/features/auth/presentation/screens/signup_screen.dart';
import 'package:verbose_ai/features/text_standardization/presentation/screens/history_screen.dart';
import 'package:verbose_ai/features/text_standardization/presentation/screens/home_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String history = '/history';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomeScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    history: (context) => const HistoryScreen(),
  };
}
