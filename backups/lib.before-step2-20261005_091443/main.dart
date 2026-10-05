import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_screen.dart';

const supabaseUrl = 'https://gviacnlbgzvybkytkorm.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd2aWFjbmxiZ3p2eWJreXRrb3JtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg0NTQyMDQsImV4cCI6MjEwNDAzMDIwNH0.m81FSVdrgg8n-1k1h-6z7soR7UPD6m5otV-JMgBT5yM';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const HodhodMessengerApp());
}

class HodhodMessengerApp extends StatelessWidget {
  const HodhodMessengerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hodhod Messenger',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black, brightness: Brightness.light),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.black87),
          hintStyle: const TextStyle(color: Colors.black45),
          prefixIconColor: Colors.black54, suffixIconColor: Colors.black54,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black26)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black26)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 1.4)),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}
