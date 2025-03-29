import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'User/screens/user_login_screen.dart';
import 'User/screens/user_register_screen.dart';
import 'User/screens/user_reset_password_screen.dart';
import 'User/screens/user_registration_success_screen.dart';
import 'User/screens/user_dashboard_screen.dart';
import 'User/screens/user_favorites_screen.dart';

class UserRoutes {
  // Routes pour les utilisateurs
  static const String userLogin = '/user/login';
  static const String userRegister = '/user/register';
  static const String userResetPassword = '/user/reset-password';
  static const String userRegistrationSuccess = '/user/registration-success';
  static const String userDashboard = '/user/dashboard';
  static const String userProfile = '/user/profile';
  static const String userFavorites = '/user/favorites';
  static const String userMessages = '/user/messages';
  static const String userBookings = '/user/bookings';

  // Configuration des routes à intégrer dans GoRouter
  static List<RouteBase> routes = [
    // Routes utilisateurs
    GoRoute(
      path: userLogin,
      builder: (BuildContext context, GoRouterState state) {
        return const UserLoginScreen();
      },
    ),
    GoRoute(
      path: userRegister,
      builder: (BuildContext context, GoRouterState state) {
        return const UserRegisterScreen();
      },
    ),
    GoRoute(
      path: userResetPassword,
      builder: (BuildContext context, GoRouterState state) {
        return const UserResetPasswordScreen();
      },
    ),
    GoRoute(
      path: userRegistrationSuccess,
      builder: (BuildContext context, GoRouterState state) {
        return const UserRegistrationSuccessScreen();
      },
    ),
    GoRoute(
      path: userDashboard,
      builder: (BuildContext context, GoRouterState state) {
        return const UserDashboardScreen();
      },
    ),
    // Route des favoris avec la nouvelle implémentation
    GoRoute(
      path: userFavorites,
      builder: (BuildContext context, GoRouterState state) {
        return const UserFavoritesScreen();
      },
    ),
    GoRoute(
      path: userMessages,
      builder: (BuildContext context, GoRouterState state) {
        return const Scaffold(
          body: Center(child: Text('Mes messages - À implémenter')),
        );
      },
    ),
    GoRoute(
      path: userBookings,
      builder: (BuildContext context, GoRouterState state) {
        return const Scaffold(
          body: Center(child: Text('Mes réservations - À implémenter')),
        );
      },
    ),
  ];
}