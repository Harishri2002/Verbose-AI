import 'package:flutter/material.dart';
import 'package:verbose_ai/config/routes.dart';
import 'package:verbose_ai/config/theme.dart';
import 'package:verbose_ai/features/text_standardization/presentation/screens/home_screen.dart';

class VerboseAIApp extends StatelessWidget {
  const VerboseAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verbose AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
