import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalori/core/providers/shared_prefs_provider.dart';

import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/profile_setup_screen.dart';
import '../../features/home/screens/dashboard_screen.dart';
import '../../features/log/screens/vegetable_input_screen.dart';
import '../../features/log/screens/recipe_suggestions_screen.dart';
import '../../features/trends/screens/trends_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/widgets/main_shell.dart';

final firstLaunchProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.getBool('isFirstLaunch') ?? true;
});

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/setup', builder: (_, __) => const ProfileSetupScreen()),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const DashboardScreen()),
          GoRoute(
            path: '/log',
            builder: (_, __) => const VegetableInputScreen(),
            routes: [
              GoRoute(
                path: 'recipes',
                builder: (_, __) => const RecipeSuggestionsScreen(),
              ),
            ],
          ),
          GoRoute(path: '/trends', builder: (_, __) => const TrendsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});
