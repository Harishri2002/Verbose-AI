import 'package:flutter/material.dart';
import 'package:verbose_ai/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  await dotenv.load();
  await Firebase.initializeApp();
  runApp(const VerboseAIApp());
}
