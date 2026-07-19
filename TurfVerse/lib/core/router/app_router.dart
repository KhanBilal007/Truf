import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/features/auth/screens/account_settings_screen.dart';
import 'package:turfverse/features/auth/screens/auth_gate_screen.dart';
import 'package:turfverse/features/auth/screens/delete_account_screen.dart';
import 'package:turfverse/features/auth/screens/forgot_password_screen.dart';
import 'package:turfverse/features/auth/screens/login_screen.dart';
import 'package:turfverse/features/auth/screens/signup_screen.dart';
import 'package:turfverse/features/admin/screens/admin_bookings_screen.dart';
import 'package:turfverse/features/admin/screens/admin_dashboard_screen.dart';
import 'package:turfverse/features/admin/screens/admin_open_matches_screen.dart';
import 'package:turfverse/features/admin/screens/admin_reports_screen.dart';
import 'package:turfverse/features/admin/screens/admin_turfs_screen.dart';
import 'package:turfverse/features/admin/screens/admin_users_screen.dart';
import 'package:turfverse/features/compliance/screens/about_app_screen.dart';
import 'package:turfverse/features/compliance/screens/contact_support_screen.dart';
import 'package:turfverse/features/compliance/screens/privacy_policy_screen.dart';
import 'package:turfverse/features/compliance/screens/report_issue_screen.dart';
import 'package:turfverse/features/compliance/screens/terms_screen.dart';
import 'package:turfverse/features/matches/screens/create_open_match_screen.dart';
import 'package:turfverse/features/matches/screens/open_match_detail_screen.dart';
import 'package:turfverse/features/matches/screens/open_matches_screen.dart';
import 'package:turfverse/features/onboarding/onboarding_screen.dart';
import 'package:turfverse/features/owner/screens/add_edit_slot_screen.dart';
import 'package:turfverse/features/owner/screens/add_edit_turf_screen.dart';
import 'package:turfverse/features/owner/screens/owner_bookings_screen.dart';
import 'package:turfverse/features/owner/screens/owner_dashboard_screen.dart';
import 'package:turfverse/features/owner/screens/owner_revenue_screen.dart';
import 'package:turfverse/features/owner/screens/owner_turf_slots_screen.dart';
import 'package:turfverse/features/owner/screens/owner_turfs_screen.dart';
import 'package:turfverse/features/placeholder/placeholder_dashboard_screen.dart';
import 'package:turfverse/features/placeholder/placeholder_login_screen.dart';
import 'package:turfverse/features/player/screens/edit_player_profile_screen.dart';
import 'package:turfverse/features/player/screens/player_dashboard_screen.dart';
import 'package:turfverse/features/player/screens/player_profile_screen.dart';
import 'package:turfverse/features/player/screens/player_stats_placeholder_screen.dart';
import 'package:turfverse/features/role_selection/role_selection_screen.dart';
import 'package:turfverse/features/teams/screens/create_team_screen.dart';
import 'package:turfverse/features/teams/screens/team_detail_screen.dart';
import 'package:turfverse/features/teams/screens/teams_screen.dart';
import 'package:turfverse/features/turf/screens/my_bookings_screen.dart';
import 'package:turfverse/features/turf/screens/turf_detail_screen.dart';
import 'package:turfverse/features/turf/screens/turf_list_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const AuthGateScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.placeholderLogin,
        builder: (context, state) => const PlaceholderLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.placeholderDashboard,
        builder: (context, state) => const PlaceholderDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.accountSettings,
        builder: (context, state) => const AccountSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.deleteAccount,
        builder: (context, state) => const DeleteAccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.playerDashboard,
        builder: (context, state) => const PlayerDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.playerProfile,
        builder: (context, state) => const PlayerProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.editPlayerProfile,
        builder: (context, state) => const EditPlayerProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.playerStats,
        builder: (context, state) => const PlayerStatsPlaceholderScreen(),
      ),
      GoRoute(
        path: AppRoutes.turfs,
        builder: (context, state) => const TurfListScreen(),
      ),
      GoRoute(
        path: AppRoutes.turfDetail,
        builder: (context, state) =>
            TurfDetailScreen(turfId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.myBookings,
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.openMatches,
        builder: (context, state) => const OpenMatchesScreen(),
      ),
      GoRoute(
        path: AppRoutes.createOpenMatch,
        builder: (context, state) => const CreateOpenMatchScreen(),
      ),
      GoRoute(
        path: AppRoutes.openMatchDetail,
        builder: (context, state) =>
            OpenMatchDetailScreen(matchId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.teams,
        builder: (context, state) => const TeamsScreen(),
      ),
      GoRoute(
        path: AppRoutes.createTeam,
        builder: (context, state) => const CreateTeamScreen(),
      ),
      GoRoute(
        path: AppRoutes.teamDetail,
        builder: (context, state) =>
            TeamDetailScreen(teamId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.ownerDashboard,
        builder: (context, state) => const OwnerDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerTurfs,
        builder: (context, state) => const OwnerTurfsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addTurf,
        builder: (context, state) => const AddEditTurfScreen(),
      ),
      GoRoute(
        path: AppRoutes.editTurf,
        builder: (context, state) =>
            AddEditTurfScreen(turfId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.ownerTurfSlots,
        builder: (context, state) =>
            OwnerTurfSlotsScreen(turfId: state.pathParameters['turfId']!),
      ),
      GoRoute(
        path: AppRoutes.addSlot,
        builder: (context, state) =>
            AddEditSlotScreen(turfId: state.pathParameters['turfId']!),
      ),
      GoRoute(
        path: AppRoutes.editSlot,
        builder: (context, state) =>
            AddEditSlotScreen(slotId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.ownerBookings,
        builder: (context, state) => const OwnerBookingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerRevenue,
        builder: (context, state) => const OwnerRevenueScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminTurfs,
        builder: (context, state) => const AdminTurfsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminBookings,
        builder: (context, state) => const AdminBookingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminOpenMatches,
        builder: (context, state) => const AdminOpenMatchesScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminReports,
        builder: (context, state) => const AdminReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: AppRoutes.terms,
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: AppRoutes.contactSupport,
        builder: (context, state) => const ContactSupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.reportIssue,
        builder: (context, state) => const ReportIssueScreen(),
      ),
      GoRoute(
        path: AppRoutes.aboutApp,
        builder: (context, state) => const AboutAppScreen(),
      ),
    ],
  );
});
