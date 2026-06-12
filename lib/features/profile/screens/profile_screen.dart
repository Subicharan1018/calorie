import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/features/profile/providers/profile_provider.dart';
import 'package:kalori/core/providers/language_provider.dart';
import 'package:kalori/shared/widgets/friendly_error.dart';
import 'package:kalori/l10n/app_strings.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    ProfileState profile,
    ProfileNotifier notifier,
    AppStrings s,
  ) {
    final nameController = TextEditingController(text: profile.name);
    final ageController = TextEditingController(text: profile.age.toString());
    final heightController = TextEditingController(text: profile.height.toInt().toString());
    final weightController = TextEditingController(text: profile.weight.toString());
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(s.isTamil ? 'சுயவிவரத்தைத் திருத்து' : 'Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: s.isTamil ? 'பெயர்' : 'Name',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: s.isTamil ? 'வயது' : 'Age',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: s.isTamil ? 'உயரம் (செ.மீ)' : 'Height (cm)',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: s.isTamil ? 'எடை (கி.கி)' : 'Weight (kg)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.isTamil ? 'ரத்து' : 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newAge = int.tryParse(ageController.text) ?? profile.age;
                final newHeight = double.tryParse(heightController.text) ?? profile.height;
                final newWeight = double.tryParse(weightController.text) ?? profile.weight;
                
                notifier.updateProfile(
                  name: nameController.text,
                  age: newAge,
                  height: newHeight,
                  weight: newWeight,
                );
                
                Navigator.pop(context);
              },
              child: Text(s.isTamil ? 'சேமி' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    final profileAsync = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => FriendlyErrorView(
          error: err,
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (profile) {
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(s.profile),
                backgroundColor: theme.colorScheme.surface,
                scrolledUnderElevation: 0,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    // Section: Your Stats
                    Text(s.yourStats, style: theme.textTheme.titleMedium),
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
                            subtitle: Text(s.isTamil 
                                ? '${profile.gender == 'male' ? 'ஆண்' : 'பெண்'} · ${profile.age} வயது'
                                : '${profile.gender.toUpperCase()} · ${profile.age} years'),
                            trailing: const Icon(Icons.edit, size: 20),
                            onTap: () => _showEditProfileDialog(context, ref, profile, notifier, s),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.height),
                            title: Text(s.isTamil ? 'உயரம்' : 'Height'),
                            trailing: Text(s.isTamil ? '${profile.height.toInt()} செ.மீ' : '${profile.height.toInt()} cm', style: theme.textTheme.titleMedium),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.monitor_weight),
                            title: Text(s.isTamil ? 'தற்போதைய எடை' : 'Current Weight'),
                            trailing: Text(s.isTamil ? '${profile.weight} கி.கி' : '${profile.weight} kg', style: theme.textTheme.titleMedium),
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
                                    Text(s.tdeePerDay, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                                    Text(s.isTamil ? '${profile.tdee} கலோரி' : '${profile.tdee} kcal', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(s.isTamil ? 'இலக்கு' : 'Target', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                                    Text(s.isTamil ? '${profile.targetKcal} கலோரி' : '${profile.targetKcal} kcal', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
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
                    Text(s.activityLevel, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedButton<double>(
                      segments: [
                        ButtonSegment(value: 1.2, label: Text(s.isTamil ? 'உழைப்பற்ற' : 'Sedentary')),
                        ButtonSegment(value: 1.375, label: Text(s.isTamil ? 'மிதமான' : 'Light')),
                        ButtonSegment(value: 1.55, label: Text(s.isTamil ? 'சாதாரண' : 'Moderate')),
                      ],
                      selected: {profile.activityMult < 1.3 ? 1.2 : profile.activityMult < 1.5 ? 1.375 : 1.55},
                      onSelectionChanged: (val) => notifier.updateActivity(val.first),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Section: Nutrition Goals
                    Text(s.nutritionGoals, style: theme.textTheme.titleMedium),
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
                              segments: [
                                ButtonSegment(value: 250, label: Text(s.isTamil ? '-0.25 கி.கி/வாரம்' : '-0.25 kg/wk')),
                                ButtonSegment(value: 500, label: Text(s.isTamil ? '-0.5 கி.கி/வாரம்' : '-0.5 kg/wk')),
                              ],
                              selected: {profile.deficitGoal},
                              onSelectionChanged: (val) => notifier.updateDeficit(val.first),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Section: App Preferences
                    Text(s.isTamil ? 'பயன்பாட்டு விருப்பங்கள்' : 'App Preferences', style: theme.textTheme.titleMedium),
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
                            title: Text(s.isTamil ? 'இருண்ட தீம்' : 'Dark Theme'),
                            secondary: const Icon(Icons.dark_mode),
                            value: profile.isDarkMode,
                            onChanged: (val) => notifier.toggleTheme(val),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.language),
                            title: Text(s.language),
                            trailing: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(value: 'en', label: Text('Eng')),
                                ButtonSegment(value: 'ta', label: Text('தமிழ்')),
                              ],
                              selected: {profile.language},
                              onSelectionChanged: (val) {
                                notifier.updateLanguage(val.first);
                                ref.read(languageProvider.notifier).state = Locale(val.first);
                              },
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.download),
                            title: Text(s.exportData),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    s.isTamil ? 'தரவை ஏற்றுமதி செய்கிறது...' : 'Exporting CSV...',
                                  ),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.info),
                            title: Text(s.isTamil ? 'கலோரி செயலியை பற்றி' : 'About Kalori'),
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
          );
        },
      ),
    );
  }
}
