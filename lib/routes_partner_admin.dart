import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'tests/test_page.dart';

class PartnerAdminRoutes {
  // Routes pour les partenaires
  static const String partnerLogin = '/partner/login';
  static const String partnerRegister = '/partner/register';
  static const String partnerDashboard = '/partner/dashboard';
  static const String partnerProfile = '/partner/profile';
  static const String partnerDocuments = '/partner/documents';
  static const String partnerMessages = '/partner/messages';
  static const String partnerStats = '/partner/stats';
  static const String partnerOffers = '/partner/offers';

  // Routes pour les admins
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminPartnersList = '/admin/partners';
  static const String adminPartnerEdit = '/admin/partners/:id';
  static const String adminStats = '/admin/stats';

  // Route de test
  static const String testPage = '/test';

  // Configuration des routes à intégrer dans GoRouter
  static List<RouteBase> routes = [
    // Route de test
    GoRoute(
      path: testPage,
      builder: (BuildContext context, GoRouterState state) {
        return const TestPage();
      },
    ),

    // Routes partenaires
    GoRoute(
      path: partnerLogin,
      builder: (BuildContext context, GoRouterState state) {
        return const Scaffold(
            body: Center(child: Text('Écran de connexion partenaire')));
      },
    ),
    GoRoute(
      path: partnerRegister,
      builder: (BuildContext context, GoRouterState state) {
        return const Scaffold(
            body: Center(child: Text('Écran d\'inscription partenaire')));
      },
    ),
    GoRoute(
      path: partnerDashboard,
      builder: (BuildContext context, GoRouterState state) {
        return const Scaffold(
            body: Center(child: Text('Tableau de bord partenaire')));
      },
    ),

    // Routes admins
    GoRoute(
      path: adminLogin,
      builder: (BuildContext context, GoRouterState state) {
        return const Scaffold(
            body: Center(child: Text('Écran de connexion admin')));
      },
    ),
    GoRoute(
      path: adminDashboard,
      builder: (BuildContext context, GoRouterState state) {
        return const Scaffold(
            body: Center(child: Text('Tableau de bord admin')));
      },
    ),
  ];
}
