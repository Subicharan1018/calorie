import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/features/profile/providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Profile'),
            backgroundColor: theme.colorScheme.surface,
            scrolledUnderElevation: 0,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                
                // Section: Your Stats
                Text('Your Stats', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  elevation: AppElevation.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(profile.name),
                        subtitle: Text('${profile.gender.toUpperCase()} · ${profile.age} years'),
                        trailing: const Icon(Icons.edit, size: 20),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.height),
                        title: const Text('Height'),
                        trailing: Text('${profile.height.toInt()} cm', style: theme.textTheme.titleMedium),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.monitor_weight),
                        title: const Text('Current Weight'),
                        trailing: Text('${profile.weight} kg', style: theme.textTheme.titleMedium),
                      ),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.card)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TDEE', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                                Text('${profile.tdee} kcal', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Target', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                                Text('${profile.targetKcal} kcal', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Section: Activity Level
                Text('Activity Level', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment(value: 1.2, label: Text('Sedentary')),
                    ButtonSegment(value: 1.375, label: Text('Light')),
                    ButtonSegment(value: 1.55, label: Text('Mod')),
                  ],
                  selected: {profile.activityMult < 1.3 ? 1.2 : profile.activityMult < 1.5 ? 1.375 : 1.55},
                  onSelectionChanged: (val) => notifier.updateActivity(val.first),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Section: Nutrition Goals
                Text('Nutrition Goals', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  elevation: AppElevation.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 250, label: Text('-0.25 kg/wk')),
                            ButtonSegment(value: 500, label: Text('-0.5 kg/wk')),
                          ],
                          selected: {profile.deficitGoal},
                          onSelectionChanged: (val) => notifier.updateDeficit(val.first),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Section: App
                Text('App Preferences', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  elevation: AppElevation.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Dark Theme'),
                        secondary: const Icon(Icons.dark_mode),
                        value: profile.isDarkMode,
                        onChanged: (val) => notifier.toggleTheme(val),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: const Text('Language'),
                        trailing: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'en', label: Text('Eng')),
                            ButtonSegment(value: 'ta', label: Text('தமிழ்')),
                          ],
                          selected: {profile.language},
                          onSelectionChanged: (val) => notifier.updateLanguage(val.first),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.download),
                        title: const Text('Export Data (CSV)'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting CSV...')));
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: const Text('About Kalori'),
                        trailing: Text('v1.0.0', style: theme.textTheme.labelMedium),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
