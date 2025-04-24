import 'package:flutter/material.dart';
import 'pages/home_page/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://meompxrfkofzbxjwjpvr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1lb21weHJma29memJ4andqcHZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU0Njk4MzQsImV4cCI6MjA2MTA0NTgzNH0.GLRSPS_TZ66-W2mSLrnYZzf_belmq32CW157pvJXwLA',
  );
  runApp(const DanceApp());
}

// class DanceApp extends StatelessWidget {
//   const DanceApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'MoovIT',
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//         fontFamily: 'Inter',
//       ),
//       home: const HomePage(),
//     );
//   }
// }

class DanceApp extends StatelessWidget {
  const DanceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'MoovIT',
      home: HomePage(),
    );
  }
}


