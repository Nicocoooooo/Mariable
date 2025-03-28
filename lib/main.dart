import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/logger.dart';
import 'utils/supabase_test.dart';
import 'routes_partner_admin.dart';
// Import des écrans
import 'Home/HomeScreen.dart';
import 'Bouquet/bouquetHomeScreen.dart';  // Import de l'écran Bouquet
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'DetailsScreen/comparison_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Supabase
  AppLogger.info('Initializing Supabase...');
  try {
    await Supabase.initialize(
      url: 'https://wrdychfyhctekddzysen.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndyZHljaGZ5aGN0ZWtkZHp5c2VuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg1OTgwNDQsImV4cCI6MjA1NDE3NDA0NH0.8GVSqkqq0se3BhXO47hgZkaI4zUF5cmKPQso11jdWSk',
    );

    await Future.delayed(const Duration(seconds: 1)); // Ajout d'un délai

    AppLogger.info('Supabase initialized successfully');

    // Tester la connexion à Supabase
    final isConnected = await SupabaseTest.testConnection();
    if (isConnected) {
      AppLogger.info('Supabase connection test successful');

      // Tester l'accès aux tables
      final tableResults = await SupabaseTest.testTables();
      tableResults.forEach((table, isAccessible) {
        if (isAccessible) {
          AppLogger.info('Table $table is accessible');
        } else {
          AppLogger.warning('Table $table is not accessible');
        }
      });
    } else {
      AppLogger.warning('Supabase connection test failed');
    }
  } catch (e) {
    AppLogger.error('Failed to initialize Supabase', e);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ComparisonProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Création d'un TextTheme de base avec Lato
    final TextTheme latoTextTheme = GoogleFonts.latoTextTheme();

    // Création d'un TextTheme personnalisé avec Playfair Display pour les titres
    final TextTheme customTextTheme = latoTextTheme.copyWith(
      // Utiliser Playfair Display pour les titres principaux
      displayLarge: GoogleFonts.playfairDisplay(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2B2B2B),
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2B2B2B),
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2B2B2B),
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2B2B2B),
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2B2B2B),
      ),
      // Text styles spécifiques pour les titrages
      titleLarge: GoogleFonts.playfairDisplay(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2B2B2B),
      ),
    );

    return MaterialApp.router(
      title: 'Mariable',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],

      theme: ThemeData(
        // Couleurs selon la DA
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF524B46), // Couleur accent
          primary: const Color(0xFF524B46), // Couleur accent comme primaire
          secondary: const Color(0xFFFFF3E4), // Beige
          surface: Colors.white,
          onSurface: const Color(0xFF2B2B2B), // Gris texte
        ),
        // Typographie avec Playfair Display pour les titres
        textTheme: customTextTheme,
        // Autres customisations
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF524B46),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        // Style des cartes
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        // Style des champs de formulaire
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false, // Supprime le bandeau "Debug"
      routerConfig: _router,
    );
  }
}

// Configuration du routeur
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    // Route pour l'écran Bouquet
    GoRoute(
      path: '/bouquet',
      builder: (context, state) => const BouquetHomeScreen(),
    ),
    // Vous pourrez ajouter d'autres routes plus tard
    ...PartnerAdminRoutes.routes,
  ],
);
