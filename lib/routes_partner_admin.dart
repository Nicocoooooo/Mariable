import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'tests/test_page.dart';
import 'Partner/screens/partner_login_screen.dart';
import 'Partner/screens/partner_register_screen.dart';
import 'Partner/screens/partner_reset_password_screen.dart';
import 'Partner/screens/partner_registration_success_screen.dart';
import 'Partner/screens/partner_dashboard_screen.dart';
import 'Partner/screens/partner_profile_screen.dart';
import 'Partner/screens/partner_documents_screen.dart';
import 'Partner/screens/partner_document_view_screen.dart';
import 'Partner/screens/partner_messages_screen.dart';
import 'Partner/screens/partner_stats_screen.dart';
import 'Partner/screens/partner_offers_screen.dart';
import 'Partner/screens/partner_offer_form_screen.dart';
import 'Admin/screens/admin_login_screen.dart';
import 'Admin/screens/admin_dashboard_screen.dart';
import 'Admin/screens/admin_partners_list_screen.dart';
import 'Admin/screens/admin_partner_edit_screen.dart';
import 'Admin/screens/admin_validations_screen.dart';
import 'Admin/screens/admin_stats_screen.dart';
import 'Admin/screens/admin_new_screen.dart';
import 'Admin/screens/admin_reports_screen.dart';
import 'Admin/screens/admin_user_analytics_screen.dart';
import 'Admin/screens/admin_partner_analytics_screen.dart';
import 'Admin/screens/admin_reservation_analytics_screen.dart';

class PartnerAdminRoutes {
  // Routes pour les partenaires
  static const String partnerLogin = '/partner/login';
  static const String partnerRegister = '/partner/register';
  static const String partnerResetPassword = '/partner/reset-password';
  static const String partnerRegistrationSuccess =
      '/partner/registration-success';
  static const String partnerDashboard = '/partner/dashboard';
  static const String partnerProfile = '/partner/profile';
  static const String partnerDocuments = '/partner/documents';
  static const String partnerMessages = '/partner/messages';
  static const String partnerStats = '/partner/stats';
  static const String partnerOffers = '/partner/offers';
  static const String partnerAddOffer = '/partner/offers/add';
  static const String partnerEditOffer = '/partner/offers/edit/:id';
  static const String partnerReservations = '/partner/reservations';

  // Routes pour les admins
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminPartnersList = '/admin/partners';
  static const String adminPartnerEdit = '/admin/partners/:id';
  static const String adminStats = '/admin/stats';
  static const String adminValidations = '/admin/validations';
  static const String adminSettings = '/admin/settings';
  static const String adminAddNew = '/admin/admins/new';
  static const String adminReports = '/admin/reports';
  static const String adminUserAnalytics = '/admin/analytics/users';
  static const String adminPartnerAnalytics = '/admin/analytics/partners';
  static const String adminReservationAnalytics =
      '/admin/analytics/reservations';

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
        return const PartnerLoginScreen();
      },
    ),
    GoRoute(
      path: partnerRegister,
      builder: (BuildContext context, GoRouterState state) {
        return const PartnerRegisterScreen();
      },
    ),
    GoRoute(
      path: partnerResetPassword,
      builder: (BuildContext context, GoRouterState state) {
        return const PartnerResetPasswordScreen();
      },
    ),
    GoRoute(
      path: partnerRegistrationSuccess,
      builder: (BuildContext context, GoRouterState state) {
        return const PartnerRegistrationSuccessScreen();
      },
    ),
    GoRoute(
      path: partnerDashboard,
      builder: (BuildContext context, GoRouterState state) {
        return const PartnerDashboardScreen();
      },
    ),
    GoRoute(
      path: partnerProfile,
      builder: (BuildContext context, GoRouterState state) {
        return const PartnerProfileScreen();
      },
    ),
    GoRoute(
      path: partnerDocuments,
      builder: (BuildContext context, GoRouterState state) {
        return const PartnerDocumentsScreen();
      },
    ),
    GoRoute(
      path: '/partner/documents/:id',
      builder: (BuildContext context, GoRouterState state) {
        final documentId = state.pathParameters['id']!;
        return PartnerDocumentViewScreen(documentId: documentId);
      },
    ),
    GoRoute(
      path: partnerMessages,
      builder: (BuildContext context, GoRouterState state) {
        return const PartnerMessagesScreen();
      },
    ),
    GoRoute(
      path: partnerStats,
      builder: (BuildContext context, GoRouterState state) {
        return const PartnerStatsScreen();
      },
    ),
    GoRoute(
      path: partnerOffers,
      builder: (BuildContext context, GoRouterState state) {
        return const PartnerOffersScreen();
      },
    ),
    GoRoute(
      path: partnerAddOffer,
      builder: (BuildContext context, GoRouterState state) {
        return const PartnerOfferFormScreen();
      },
    ),
    GoRoute(
      path: '/partner/offers/edit/:id',
      builder: (BuildContext context, GoRouterState state) {
        final offerId = state.pathParameters['id']!;
        return PartnerOfferFormScreen(offerId: offerId);
      },
    ),
    GoRoute(
      path: partnerReservations,
      builder: (BuildContext context, GoRouterState state) {
        return const Scaffold(
          body: Center(child: Text('Réservations - À implémenter')),
        );
      },
    ),

    // Routes admins
    GoRoute(
      path: adminLogin,
      builder: (BuildContext context, GoRouterState state) {
        return const AdminLoginScreen();
      },
    ),
    GoRoute(
      path: adminDashboard,
      builder: (BuildContext context, GoRouterState state) {
        return const AdminDashboardScreen();
      },
    ),
    GoRoute(
      path: adminAddNew,
      builder: (BuildContext context, GoRouterState state) {
        return const AdminNewScreen();
      },
    ),
    GoRoute(
      path: adminPartnersList,
      builder: (BuildContext context, GoRouterState state) {
        return const AdminPartnersListScreen();
      },
    ),
    GoRoute(
      path: '/admin/partners/:id',
      builder: (BuildContext context, GoRouterState state) {
        final partnerId = state.pathParameters['id']!;
        // Si l'ID est "new", on est en mode création
        final isNewPartner = partnerId == 'new';
        return AdminPartnerEditScreen(
          partnerId: partnerId,
          isNewPartner: isNewPartner,
        );
      },
    ),
    GoRoute(
      path: adminValidations,
      builder: (BuildContext context, GoRouterState state) {
        return const AdminValidationsScreen();
      },
    ),
    GoRoute(
      path: adminStats,
      builder: (BuildContext context, GoRouterState state) {
        return const AdminStatsScreen();
      },
    ),
    GoRoute(
      path: adminSettings,
      builder: (BuildContext context, GoRouterState state) {
        return const Scaffold(
          body: Center(
              child: Text('Paramètres d\'administration - À implémenter')),
        );
      },
    ),
    GoRoute(
      path: adminReports,
      builder: (BuildContext context, GoRouterState state) {
        return const AdminReportsScreen();
      },
    ),
    GoRoute(
      path: adminUserAnalytics,
      builder: (BuildContext context, GoRouterState state) {
        return const AdminUserAnalyticsScreen();
      },
    ),
    GoRoute(
      path: adminPartnerAnalytics,
      builder: (BuildContext context, GoRouterState state) {
        return const AdminPartnerAnalyticsScreen();
      },
    ),
    GoRoute(
      path: adminReservationAnalytics,
      builder: (BuildContext context, GoRouterState state) {
        return const AdminReservationAnalyticsScreen();
      },
    ),
  ];
}
