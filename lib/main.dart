import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://vwijwkddpjjjjshxfqup.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3aWp3a2Rkc'
        'GpqampzaHhmcXVwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxMzI4NDIsImV4cCI6MjA1MTcwODg0Mn0'
        '.uL7ymiItomtT3_wXmegVSkvTeCPRpbL4w83NyLOa7ak',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
    home: const MyHomePage(),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    supabase.auth.onAuthStateChange.listen((data) => setState(() => _userEmail = data.session?.user.email));
  }

  Future<void> _signInWithGoogle() async {
    // if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
    //   return;
    // }

    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'cn.chessroad.apps.ichess://login_callback',
      );
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  void _signInWithApple() {}

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    setState(() => _userEmail = null);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text('Flutter Demo Home Page'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(_userEmail ?? 'Not signed in'),
          const SizedBox(height: 16),
          if (_userEmail == null) ...[
            ElevatedButton(onPressed: _signInWithGoogle, child: const Text('Sign in with Google')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _signInWithApple, child: const Text('Sign in with Apple')),
          ] else ...[
            ElevatedButton(onPressed: _signOut, child: const Text('Sign out')),
          ],
        ],
      ),
    ),
  );

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
