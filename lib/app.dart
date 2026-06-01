import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/core/router/router.dart';
import 'package:kalori/core/theme/app_theme.dart';

class KaloriApp extends ConsumerWidget {
  const KaloriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Kalori',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(isDark: false),
      darkTheme: AppTheme.buildTheme(isDark: true),
      routerConfig: router,
    );
  }
}
