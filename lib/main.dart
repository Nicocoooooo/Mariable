import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Supabase - à remplacer par vos clés
  await Supabase.initialize(
    url: 'VOTRE_URL_SUPABASE',
    anonKey: 'VOTRE_CLE_ANONYME_SUPABASE',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mariable',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3CB371), // Vert moyen
          primary: const Color(0xFF1A4D2E), // Vert foncé
          secondary: const Color(0xFFF5EFE6), // Beige clair
          tertiary: const Color(0xFFAB886D), // Brun clair
        ),
        useMaterial3: true,
        fontFamily: 'Montserrat', // À remplacer par votre police préférée
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mariable')),
      body: const Center(child: Text('Bienvenue sur Mariable')),
    );
  }
}
