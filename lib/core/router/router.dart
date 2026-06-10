import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';
import 'package:kalori/core/providers/shared_prefs_provider.dart';

import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/profile_setup_screen.dart';
import '../../features/home/screens/dashboard_screen.dart';
import '../../features/log/screens/vegetable_input_screen.dart';
import '../../features/log/screens/recipe_suggestions_screen.dart';
import '../../features/trends/screens/trends_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/barcode/barcode_scanner_screen.dart';
import '../../shared/widgets/main_shell.dart';

final firstLaunchProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.getBool('isFirstLaunch') ?? true;
});

CustomTransitionPage<T> _buildPageWithTransition<T>({
  required GoRouterState state,
  required Widget child,
  required SharedAxisTransitionType transitionType,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        secondaryAnimation: CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutCubic),
        transitionType: transitionType,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 280),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _buildPageWithTransition(
          state: state,
          child: const SplashScreen(),
          transitionType: SharedAxisTransitionType.horizontal,
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _buildPageWithTransition(
          state: state,
          child: const OnboardingScreen(),
          transitionType: SharedAxisTransitionType.horizontal,
        ),
      ),
      GoRoute(
        path: '/setup',
        pageBuilder: (context, state) => _buildPageWithTransition(
          state: state,
          child: const ProfileSetupScreen(),
          transitionType: SharedAxisTransitionType.horizontal,
        ),
      ),
      GoRoute(
        path: '/scanner',
        pageBuilder: (context, state) => _buildPageWithTransition(
          state: state,
          child: const BarcodeScannerScreen(),
          transitionType: SharedAxisTransitionType.horizontal,
        ),
      ),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _buildPageWithTransition(
              state: state,
              child: const DashboardScreen(),
              transitionType: SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/log',
            pageBuilder: (context, state) => _buildPageWithTransition(
              state: state,
              child: const VegetableInputScreen(),
              transitionType: SharedAxisTransitionType.scaled,
            ),
            routes: [
              GoRoute(
                path: 'recipes',
                pageBuilder: (context, state) => _buildPageWithTransition(
                  state: state,
                  child: const RecipeSuggestionsScreen(),
                  transitionType: SharedAxisTransitionType.horizontal,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/trends',
            pageBuilder: (context, state) => _buildPageWithTransition(
              state: state,
              child: const TrendsScreen(),
              transitionType: SharedAxisTransitionType.scaled,
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => _buildPageWithTransition(
              state: state,
              child: const ProfileScreen(),
              transitionType: SharedAxisTransitionType.scaled,
            ),
          ),
        ],
      ),
    ],
  );
});
