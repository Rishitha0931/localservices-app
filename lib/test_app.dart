import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyTestApp());
}

class MyTestApp extends StatelessWidget {
  const MyTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            '✅ It works!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
