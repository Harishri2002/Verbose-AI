import 'package:flutter/material.dart';
import 'package:verbose_ai/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  await dotenv.load();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env["API_KEY"] ?? '',
      appId: dotenv.env["APP_ID"] ?? '',
      messagingSenderId: dotenv.env["SENDER_ID"] ?? '',
      projectId: "verbose-ai",
      // Other platform-specific options like:
      // authDomain: "YOUR_AUTH_DOMAIN", // For web
      // storageBucket: "YOUR_STORAGE_BUCKET",
      // iosBundleId: "YOUR_IOS_BUNDLE_ID", // For iOS
      // androidClientId: "", // For Android
    ),
  );
  runApp(const VerboseAIApp());
}