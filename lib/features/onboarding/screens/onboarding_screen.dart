import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/features/onboarding/widgets/onboarding_slide.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingSlideData> _slides = [
    const OnboardingSlideData(
      title: 'Your vegetables.\nYour recipes.',
      subtitle: 'Pick the local vegetables in your kitchen and let AI suggest South Indian recipes tailored for you.',
      illustration: _PlaceholderIllustration(icon: Icons.grass, color: Colors.green),
    ),
    const OnboardingSlideData(
      title: 'Calories from your\nown kitchen.',
      subtitle: 'We use verified ICMR-NIN nutritional data so you know exactly what is in your sambar, poriyal, and kootu.',
      illustration: _PlaceholderIllustration(icon: Icons.soup_kitchen, color: Colors.orange),
    ),
    const OnboardingSlideData(
      title: 'Set your target.\nWe track the rest.',
      subtitle: 'Establish your daily calorie deficit based on your goals and easily visualize your progress every day.',
      illustration: _PlaceholderIllustration(icon: Icons.track_changes, color: Colors.purple),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go('/setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _currentIndex == _slides.length - 1;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/setup'),
                child: Text(
                  'Skip setup',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                itemBuilder: (context, index) {
                  return OnboardingSlide(data: _slides[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        height: 8,
                        width: _currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: _onNext,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(120, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                    child: Text(isLast ? 'Set up profile' : 'Next'),
                  )
                  .animate(target: isLast ? 1 : 0)
                  .shimmer(duration: 1000.ms, color: Colors.white24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder illustration wrapper
class _PlaceholderIllustration extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _PlaceholderIllustration({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 80, color: color),
    );
  }
}
