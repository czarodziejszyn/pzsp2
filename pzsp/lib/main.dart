import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart'; // <--- nowy import
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'controllers/auth_controller.dart'; // <--- nowy import, utwórz ten plik

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://meompxrfkofzbxjwjpvr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1lb21weHJma29memJ4andqcHZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU0Njk4MzQsImV4cCI6MjA2MTA0NTgzNH0.GLRSPS_TZ66-W2mSLrnYZzf_belmq32CW157pvJXwLA',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: const DanceApp(),
    ),
  );
}

class DanceApp extends StatelessWidget {
  const DanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoovIT',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Inter',
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
