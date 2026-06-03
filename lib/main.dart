import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'screens/landing_page.dart';
import 'screens/auth/login_signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/onboarding_profile_screen.dart';
import 'screens/member/member_dashboard.dart';
import 'screens/member/workout_center_screen.dart';
import 'screens/member/diet_center_screen.dart';
import 'screens/member/progress_tracker_screen.dart';
import 'screens/member/rewards_center_screen.dart';
import 'screens/member/profile_settings_screen.dart';
import 'screens/trainer/trainer_dashboard_screen.dart';
import 'screens/trainer/client_management_screen.dart';
import 'screens/trainer/workout_assignment_screen.dart';
import 'screens/trainer/exercise_library_screen.dart';
import 'screens/trainer/diet_assignment_screen.dart';
import 'screens/trainer/trainer_profile_screen.dart';
import 'screens/owner/owner_dashboard_screen.dart';
import 'screens/owner/analytics_reports_screen.dart';
import 'screens/owner/billing_payments_screen.dart';
import 'screens/owner/subscription_plan_management_screen.dart';
import 'screens/owner/attendance_management_screen.dart';
import 'screens/owner/communication_center_screen.dart';
import 'screens/owner/notifications_center_screen.dart';
import 'screens/owner/gym_settings_screen.dart';

void main() {
  runApp(const KineticApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const LoginSignupScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingProfileScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const MemberDashboard(),
    ),
    GoRoute(
      path: '/workout-center',
      builder: (context, state) => const WorkoutCenterScreen(),
    ),
    GoRoute(
      path: '/diet-center',
      builder: (context, state) => const DietCenterScreen(),
    ),
    GoRoute(
      path: '/progress',
      builder: (context, state) => const ProgressTrackerScreen(),
    ),
    GoRoute(
      path: '/rewards',
      builder: (context, state) => const RewardsCenterScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileSettingsScreen(),
    ),
    GoRoute(
      path: '/trainer-dashboard',
      builder: (context, state) => const TrainerDashboardScreen(),
    ),
    GoRoute(
      path: '/trainer/clients',
      builder: (context, state) => const ClientManagementScreen(),
    ),
    GoRoute(
      path: '/trainer/assign',
      builder: (context, state) => const WorkoutAssignmentScreen(),
    ),
    GoRoute(
      path: '/trainer/library',
      builder: (context, state) => const ExerciseLibraryScreen(),
    ),
    GoRoute(
      path: '/owner-dashboard',
      builder: (context, state) => const OwnerDashboardScreen(),
    ),
    GoRoute(
      path: '/owner/analytics',
      builder: (context, state) => const AnalyticsReportsScreen(),
    ),
    GoRoute(
      path: '/owner/billing',
      builder: (context, state) => const BillingPaymentsScreen(),
    ),
    GoRoute(
      path: '/owner/subscriptions',
      builder: (context, state) => const SubscriptionPlanManagementScreen(),
    ),
    GoRoute(
      path: '/trainer/diet-assign',
      builder: (context, state) => const DietAssignmentScreen(),
    ),
    GoRoute(
      path: '/trainer/profile',
      builder: (context, state) => const TrainerProfileScreen(),
    ),
    GoRoute(
      path: '/owner/attendance',
      builder: (context, state) => const AttendanceManagementScreen(),
    ),
    GoRoute(
      path: '/owner/communications',
      builder: (context, state) => const CommunicationCenterScreen(),
    ),
    GoRoute(
      path: '/owner/notifications',
      builder: (context, state) => const NotificationsCenterScreen(),
    ),
    GoRoute(
      path: '/owner/settings',
      builder: (context, state) => const GymSettingsScreen(),
    ),
  ],
);

class KineticApp extends StatelessWidget {
  const KineticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kinetic AI',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
