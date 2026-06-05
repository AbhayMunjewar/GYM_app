import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'screens/landing_page.dart';
import 'screens/role_selector_screen.dart';
import 'services/auth_service.dart';

// Auth
import 'screens/auth/login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/onboarding_screen.dart';

// Member
import 'screens/member/member_dashboard.dart';
import 'screens/member/workout_center.dart';
import 'screens/member/diet_center.dart';
import 'screens/member/exercise_library.dart';
import 'screens/member/ai_gym_buddy.dart';
import 'screens/member/ai_form_check.dart';
import 'screens/member/progress_tracker.dart';
import 'screens/member/membership_center.dart';
import 'screens/member/challenges_leaderboard.dart';
import 'screens/member/rewards_center.dart';
import 'screens/member/profile_settings.dart';

// Trainer
import 'screens/trainer/trainer_dashboard.dart';
import 'screens/trainer/client_management.dart';
import 'screens/trainer/schedule_calendar.dart';
import 'screens/trainer/workout_assignment.dart';
import 'screens/trainer/diet_assignment.dart';
import 'screens/trainer/trainer_profile.dart';

// Owner
import 'screens/owner/owner_dashboard.dart';
import 'screens/owner/members_management.dart';
import 'screens/owner/attendance_management.dart';
import 'screens/owner/trainer_management.dart';
import 'screens/owner/billing_payments.dart';
import 'screens/owner/analytics_reports.dart';
import 'screens/owner/challenges_rewards.dart';
import 'screens/owner/communication_center.dart';
import 'screens/owner/gym_settings.dart';
import 'screens/owner/subscription_plan.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await authService.loadSession();
  runApp(const KineticApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingPage()),
    GoRoute(path: '/role-selector', builder: (context, state) => const RoleSelectorScreen()),
    
    // Auth Routes
    GoRoute(path: '/auth/login', builder: (context, state) => LoginScreen(targetRoute: state.extra as String? ?? '/member/dashboard')),
    GoRoute(path: '/auth/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(path: '/auth/onboarding', builder: (context, state) => const OnboardingScreen()),
    
    // Member Routes
    GoRoute(path: '/member/dashboard', builder: (context, state) => const MemberDashboard()),
    GoRoute(path: '/member/workout-center', builder: (context, state) => const WorkoutCenter()),
    GoRoute(path: '/member/diet-center', builder: (context, state) => const DietCenter()),
    GoRoute(path: '/member/exercise-library', builder: (context, state) => const ExerciseLibrary()),
    GoRoute(path: '/member/ai-buddy', builder: (context, state) => const AIGymBuddy()),
    GoRoute(path: '/member/ai-form-check', builder: (context, state) => const AIFormCheck()),
    GoRoute(path: '/member/progress-tracker', builder: (context, state) => const ProgressTracker()),
    GoRoute(path: '/member/membership', builder: (context, state) => const MembershipCenter()),
    GoRoute(path: '/member/challenges', builder: (context, state) => const ChallengesLeaderboard()),
    GoRoute(path: '/member/rewards', builder: (context, state) => const RewardsCenter()),
    GoRoute(path: '/member/profile', builder: (context, state) => const ProfileSettings()),
    
    // Trainer Routes
    GoRoute(path: '/trainer/dashboard', builder: (context, state) => const TrainerDashboard()),
    GoRoute(path: '/trainer/clients', builder: (context, state) => const ClientManagement()),
    GoRoute(path: '/trainer/schedule', builder: (context, state) => const ScheduleCalendar()),
    GoRoute(path: '/trainer/workout-assign', builder: (context, state) => const WorkoutAssignment()),
    GoRoute(path: '/trainer/diet-assign', builder: (context, state) => const DietAssignment()),
    GoRoute(path: '/trainer/profile', builder: (context, state) => const TrainerProfile()),
    
    // Owner Routes
    GoRoute(path: '/owner/dashboard', builder: (context, state) => const OwnerDashboard()),
    GoRoute(path: '/owner/members', builder: (context, state) => const MembersManagement()),
    GoRoute(path: '/owner/attendance', builder: (context, state) => const AttendanceManagement()),
    GoRoute(path: '/owner/trainers', builder: (context, state) => const TrainerManagement()),
    GoRoute(path: '/owner/billing', builder: (context, state) => const BillingPayments()),
    GoRoute(path: '/owner/analytics', builder: (context, state) => const AnalyticsReports()),
    GoRoute(path: '/owner/challenges', builder: (context, state) => const ChallengesRewards()),
    GoRoute(path: '/owner/communication', builder: (context, state) => const CommunicationCenter()),
    GoRoute(path: '/owner/settings', builder: (context, state) => const GymSettings()),
    GoRoute(path: '/owner/subscription', builder: (context, state) => const SubscriptionPlan()),
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
