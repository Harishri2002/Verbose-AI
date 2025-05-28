import 'package:flutter/material.dart';
import 'package:verbose_ai/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  // This is CRUCIAL - must be first line in main()
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    print("Environment variables loaded successfully");
  } catch (e) {
    print("Warning: Could not load .env file: $e");
    // Continue execution even if .env fails to load
  }

  try {
    // Check if Firebase is already initialized to prevent duplicate app error
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: dotenv.env["API_KEY"] ?? '',
          appId: dotenv.env["APP_ID"] ?? '',
          messagingSenderId: dotenv.env["SENDER_ID"] ?? '',
          projectId: "verbose-ai",
        ),
      );
      print("Firebase initialized successfully");
    } else {
      print("Firebase already initialized");
    }
  } catch (e) {
    print("Firebase initialization error: $e");
    // You might want to show an error dialog or handle this gracefully
    // For now, we'll continue and let the app run without Firebase
  }

  runApp(const VerboseAIApp());
}