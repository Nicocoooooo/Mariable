import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentImageIndex = 0;
  late Timer _imageRotationTimer;
  bool _isReady = false;

  // Liste des images d'intro
  final List<String> _introImages = [
    'assets/images/Intro1.jpg',
    'assets/images/Intro7.jpg',
    'assets/images/Intro3.jpg',
    'assets/images/Intro6.jpg',
  ];

  @override
  void initState() {
    super.initState();
    
    // Débuter la rotation d'images toutes les 5 secondes
    _imageRotationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _introImages.length;
      });
    });
    
    // Marquer comme prêt après un court délai pour permettre à l'utilisateur de continuer manuellement
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _isReady = true;
      });
    });
  }

  @override
  void dispose() {
    _imageRotationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer les couleurs du thème
    final Color accentColor = Theme.of(context).colorScheme.primary; // #524B46
    final Color beige = Theme.of(context).colorScheme.secondary; // #FFF3E4

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image d'arrière-plan avec animation CrossFade
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            child: Image.asset(
              _introImages[_currentImageIndex],
              key: ValueKey<int>(_currentImageIndex),
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          
          // Dégradé pour assurer la lisibilité du logo
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4],
              ),
            ),
          ),
          
          // Logo SVG en haut
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: SvgPicture.asset(
                  'assets/images/logoMariable.svg',
                  height: 240,
                  width: 800,
                ),
              ),
            ),
          ),
          
          // Bouton pour continuer (uniquement visible après un délai)
          if (_isReady)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Naviguer vers l'écran d'accueil principal avec GoRouter
                    context.go('/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Commencer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          
          // Indicateurs de pages
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _introImages.length,
                  (index) => Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentImageIndex
                          ? accentColor
                          : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}