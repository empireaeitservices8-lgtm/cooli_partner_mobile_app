import 'package:go_router/go_router.dart';

// Authentication Screens
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/partner_registration_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/verification_status_screen.dart';

// Home & Shell
import '../../features/home/screens/main_shell_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';

// Jobs & Ride
import '../../features/jobs/screens/incoming_job_request_screen.dart';
import '../../features/ride/screens/active_ride_screen.dart';
import '../../features/ride/screens/ride_completed_screen.dart';
import '../../features/ride/screens/ride_rating_screen.dart';

// Porter
import '../../features/porter/screens/porter_dashboard_screen.dart';

// Truck
import '../../features/truck/screens/truck_dashboard_screen.dart';
import '../../features/truck/screens/truck_load_details_screen.dart';
import '../../features/truck/screens/truck_bid_screen.dart';
import '../../features/truck/screens/truck_bids_history_screen.dart';

// Vehicles
import '../../features/vehicles/screens/vehicle_details_screen.dart';
import '../../features/vehicles/screens/add_vehicle_screen.dart';

// Documents
import '../../features/documents/screens/documents_dashboard_screen.dart';
import '../../features/documents/screens/document_upload_screen.dart';

// Profile, Support, Safety
import '../../features/profile/screens/bank_account_screen.dart';
import '../../features/profile/screens/ratings_screen.dart';
import '../../features/support/screens/help_center_screen.dart';
import '../../features/safety/screens/safety_center_screen.dart';

import '../../models/models.dart';

/// Centralized Named Routes and GoRouter Configuration for COOLI PARTNER
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash & Onboarding
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final phone = state.extra as String? ?? '+91 98470 12345';
        return OtpScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const PartnerRegistrationScreen(),
    ),
    GoRoute(
      path: '/verification-status',
      builder: (context, state) {
        final phone = state.extra as String?;
        return VerificationStatusScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/select-role',
      builder: (context, state) => const RoleSelectionScreen(),
    ),

    // Main App Shell with Bottom Navigation (Tabs 0 to 4)
    GoRoute(
      path: '/',
      builder: (context, state) => const MainShellScreen(initialTab: 0),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainShellScreen(initialTab: 0),
    ),
    GoRoute(
      path: '/jobs',
      builder: (context, state) => const MainShellScreen(initialTab: 1),
    ),
    GoRoute(
      path: '/earnings',
      builder: (context, state) => const MainShellScreen(initialTab: 2),
    ),
    GoRoute(
      path: '/vehicles',
      builder: (context, state) => const MainShellScreen(initialTab: 3),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const MainShellScreen(initialTab: 4),
    ),

    // Notifications
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    // Incoming Job & Ride Workflow
    GoRoute(
      path: '/jobs/request',
      builder: (context, state) => const IncomingJobRequestScreen(),
    ),
    GoRoute(
      path: '/ride/active',
      builder: (context, state) => const ActiveRideScreen(),
    ),
    GoRoute(
      path: '/ride/completed',
      builder: (context, state) => const RideCompletedScreen(),
    ),
    GoRoute(
      path: '/ride/rating',
      builder: (context, state) => const RideRatingScreen(),
    ),

    // Porter Workflow
    GoRoute(
      path: '/porter',
      builder: (context, state) => const PorterDashboardScreen(),
    ),

    // Truck Marketplace & Bidding
    GoRoute(
      path: '/truck',
      builder: (context, state) => const TruckDashboardScreen(),
    ),
    GoRoute(
      path: '/truck/details',
      builder: (context, state) {
        final load = state.extra as TruckLoad;
        return TruckLoadDetailsScreen(load: load);
      },
    ),
    GoRoute(
      path: '/truck/bid',
      builder: (context, state) {
        final load = state.extra as TruckLoad;
        return TruckBidScreen(load: load);
      },
    ),
    GoRoute(
      path: '/truck/bids',
      builder: (context, state) => const TruckBidsHistoryScreen(),
    ),

    // Vehicles Management
    GoRoute(
      path: '/vehicles/add',
      builder: (context, state) => const AddVehicleScreen(),
    ),
    GoRoute(
      path: '/vehicles/details',
      builder: (context, state) {
        final vehicle = state.extra as Vehicle;
        return VehicleDetailsScreen(vehicle: vehicle);
      },
    ),

    // Document Compliance
    GoRoute(
      path: '/documents',
      builder: (context, state) => const DocumentsDashboardScreen(),
    ),
    GoRoute(
      path: '/documents/upload',
      builder: (context, state) {
        final doc = state.extra as PartnerDocument?;
        return DocumentUploadScreen(existingDocument: doc);
      },
    ),

    // Profile Sub-Pages
    GoRoute(
      path: '/profile/bank',
      builder: (context, state) => const BankAccountScreen(),
    ),
    GoRoute(
      path: '/profile/ratings',
      builder: (context, state) => const RatingsScreen(),
    ),
    GoRoute(
      path: '/profile/support',
      builder: (context, state) => const HelpCenterScreen(),
    ),
    GoRoute(
      path: '/safety',
      builder: (context, state) => const SafetyCenterScreen(),
    ),
  ],
);
