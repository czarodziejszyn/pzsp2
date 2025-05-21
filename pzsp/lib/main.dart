import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart'; // dodaj

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://meompxrfkofzbxjwjpvr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1lb21weHJma29memJ4andqcHZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU0Njk4MzQsImV4cCI6MjA2MTA0NTgzNH0.GLRSPS_TZ66-W2mSLrnYZzf_belmq32CW157pvJXwLA',
  );

  runApp(const DanceApp());
}

final supabase = Supabase.instance.client;

class DanceApp extends StatelessWidget {
  const DanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoovIT',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Inter',
      ),
      home: AuthGate(), // <--- nowy widget
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const HomePage(); // user jest zalogowany
    } else {
      return const LoginPage(); // pokaz logowanie
    }
  }
}
