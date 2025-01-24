import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      await _googleNativeSignIn();
      return;
    }

    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'cn.chessroad.apps.ichess://login_callback',
      );
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  Future<void> _googleNativeSignIn() async {
    // Web Client ID that you registered with Google Cloud.
    const webClientId = '369752755949-mlbr178v2u8o92169a7lbsj064p1cn72.apps.googleusercontent.com';

    // iOS Client ID that you registered with Google Cloud.
    const iosClientId = '369752755949-nfbp5g0qev63bq6lcng6el1fbeqg9n4t.apps.googleusercontent.com';

    // Google sign in on Android will work without providing the Android Client ID registered on Google Cloud.

    final googleSignIn = GoogleSignIn(clientId: iosClientId, serverClientId: webClientId);
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser?.authentication;
    final accessToken = googleAuth?.accessToken;
    final idToken = googleAuth?.idToken;

    if (accessToken == null) throw 'No Access Token found.';
    if (idToken == null) throw 'No ID Token found.';

    await supabase.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken, accessToken: accessToken);
  }

  Future<AuthResponse?> _signInWithApple() async {
    final rawNonce = supabase.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    // add try catch
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) throw 'Could not find ID Token from generated credential.';

      return supabase.auth.signInWithIdToken(provider: OAuthProvider.apple, idToken: idToken, nonce: rawNonce);
    } catch (e) {
      _showMessage('Error: $e');
    }

    return null;
  }

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
            if (Platform.isIOS || Platform.isMacOS) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _signInWithApple, child: const Text('Sign in with Apple')),
            ],
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
