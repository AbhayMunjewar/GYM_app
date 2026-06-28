import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'screens/landing_page.dart';
import 'screens/role_selector_screen.dart';
import 'services/auth_service.dart';

// Nutrition Feature
import 'features/nutrition/screens/diet_setup_screen.dart';
import 'features/nutrition/screens/nutrition_dashboard_screen.dart';
import 'features/nutrition/screens/meal_plan_screen.dart';
import 'features/nutrition/screens/grocery_list_screen.dart';
import 'features/nutrition/screens/compliance_screen.dart';
import 'features/nutrition/screens/diet_coach_screen.dart';

// SaaS Tenancy Feature
import 'features/saas/screens/subscription_screen.dart';
import 'features/saas/screens/billing_screen.dart';
import 'features/saas/screens/plan_upgrade_screen.dart';
import 'features/saas/screens/branch_management_screen.dart';
import 'features/saas/screens/tenant_settings_screen.dart';
import 'features/saas/screens/super_admin_dashboard.dart';

// Auth
import 'screens/auth/login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/onboarding_screen.dart';

// Shared
import 'screens/notifications_screen.dart';

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
import 'screens/member/community_feed_screen.dart';
import 'screens/member/profile_settings.dart';
import 'screens/member/member_billing.dart';
import 'screens/member/chat_rooms_screen.dart';
import 'screens/member/chat_detail_screen.dart';

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
import 'screens/owner/owner_billing.dart';
import 'screens/owner/owner_billing_settings.dart';
import 'screens/owner/analytics_reports.dart';
import 'screens/owner/challenges_rewards.dart';
import 'screens/owner/communication_center.dart';
import 'screens/owner/gym_settings.dart';
import 'screens/owner/subscription_plan.dart';

// Sessions
import 'screens/sessions/session_list_screen.dart';
import 'screens/sessions/create_session_screen.dart';
import 'screens/sessions/session_detail_screen.dart';
import 'screens/sessions/member_schedule_screen.dart';
import 'models/workout_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await authService.loadSession();
  runApp(const ProviderScope(child: KineticApp()));
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
    
    // Shared Routes
    GoRoute(path: '/notifications', builder: (context, state) => NotificationsScreen()),
    
    // Member Routes
    GoRoute(path: '/member/dashboard', builder: (context, state) => const MemberDashboard()),
    GoRoute(path: '/member/workout-center', builder: (context, state) => const WorkoutCenter()),
    GoRoute(path: '/member/diet-center', builder: (context, state) => const DietCenter()),
    GoRoute(path: '/member/nutrition-dashboard', builder: (context, state) => const NutritionDashboardScreen()),
    GoRoute(path: '/member/diet-setup', builder: (context, state) => const DietSetupScreen()),
    GoRoute(path: '/member/meal-plan', builder: (context, state) => const MealPlanScreen()),
    GoRoute(path: '/member/grocery-list', builder: (context, state) => const GroceryListScreen()),
    GoRoute(path: '/member/compliance', builder: (context, state) => const ComplianceScreen()),
    GoRoute(path: '/member/diet-coach', builder: (context, state) => const DietCoachScreen()),
    GoRoute(path: '/member/exercise-library', builder: (context, state) => const ExerciseLibrary()),
    GoRoute(path: '/member/ai-buddy', builder: (context, state) => const AIGymBuddy()),
    GoRoute(path: '/member/ai-form-check', builder: (context, state) => const AIFormCheck()),
    GoRoute(path: '/member/progress-tracker', builder: (context, state) => ProgressTracker(memberId: state.extra as String?)),
    GoRoute(path: '/member/membership', builder: (context, state) => const MembershipCenter()),
    GoRoute(path: '/member/challenges', builder: (context, state) => const ChallengesLeaderboard()),
    GoRoute(path: '/member/rewards', builder: (context, state) => const RewardsCenter()),
    GoRoute(path: '/member/community', builder: (context, state) => const CommunityFeedScreen()),
    GoRoute(path: '/member/profile', builder: (context, state) => const ProfileSettings()),
    GoRoute(path: '/member/billing', builder: (context, state) => MemberBillingScreen()),
    GoRoute(path: '/member/chat-rooms', builder: (context, state) => const ChatRoomsScreen()),
    GoRoute(path: '/member/chat/:roomId', builder: (context, state) {
      final roomId = state.pathParameters['roomId']!;
      final targetUser = state.extra as Map<String, dynamic>?;
      return ChatDetailScreen(roomId: roomId, targetUser: targetUser);
    }),
    
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
    GoRoute(path: '/owner/billing', builder: (context, state) => OwnerBillingScreen()),
    GoRoute(path: '/owner/billing/settings', builder: (context, state) => OwnerBillingSettingsScreen()),
    GoRoute(path: '/owner/analytics', builder: (context, state) => const AnalyticsReports()),
    GoRoute(path: '/owner/challenges', builder: (context, state) => const ChallengesRewards()),
    GoRoute(path: '/owner/communication', builder: (context, state) => const CommunicationCenter()),
    GoRoute(path: '/owner/settings', builder: (context, state) => const GymSettings()),
    GoRoute(path: '/owner/subscription', builder: (context, state) => const SubscriptionPlan()),
    
    // SaaS Tenancy Routes
    GoRoute(path: '/owner/saas-subscription', builder: (context, state) => const SaasSubscriptionScreen()),
    GoRoute(path: '/owner/saas-upgrade', builder: (context, state) => const SaasPlanUpgradeScreen()),
    GoRoute(path: '/owner/saas-billing', builder: (context, state) => const SaasBillingScreen()),
    GoRoute(path: '/owner/branches', builder: (context, state) => const SaasBranchManagementScreen()),
    GoRoute(path: '/owner/tenant-settings', builder: (context, state) => const SaasTenantSettingsScreen()),
    GoRoute(path: '/superadmin/dashboard', builder: (context, state) => const SaasSuperAdminDashboardScreen()),
    
    // Sessions
    GoRoute(path: '/owner/sessions', builder: (context, state) => const SessionListScreen()),
    GoRoute(path: '/owner/sessions/create', builder: (context, state) => const CreateSessionScreen()),
    GoRoute(path: '/owner/sessions/detail', builder: (context, state) => SessionDetailScreen(session: state.extra as WorkoutSession)),
    GoRoute(path: '/member/schedule', builder: (context, state) => const MemberScheduleScreen()),
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
