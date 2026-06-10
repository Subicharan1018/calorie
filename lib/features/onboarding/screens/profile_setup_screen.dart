import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/core/providers/shared_prefs_provider.dart';
import 'package:kalori/core/utils/tdee_calculator.dart';
import 'package:kalori/l10n/app_strings.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  String _gender = 'male';
  int _age = 30;
  double _weight = 70.0;
  double _height = 170.0;
  double _activityMult = 1.2;
  String _weightGoal = 'lose_0.5';

  void _onSave() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setBool('isFirstLaunch', false);
    
    // In production we would save all profile stats here as JSON
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    
    final tdee = TDEECalculator.mifflinStJeor(
      weightKg: _weight,
      heightCm: _height,
      age: _age,
      gender: _gender,
      activityMult: _activityMult,
    );
    
    double deficitGoal = 0;
    if (_weightGoal == 'lose_0.5') deficitGoal = 500;
    if (_weightGoal == 'lose_0.25') deficitGoal = 250;
    
    final targetKcal = tdee - deficitGoal;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(s.isTamil ? 'சுயவிவரம் அமைத்தல்' : 'Set up your profile'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.lg,
            bottom: 100, // padding for FAB
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.isTamil ? 'பாலினம்' : 'Gender', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'male', label: Text(s.isTamil ? 'ஆண்' : 'Male')),
                  ButtonSegment(value: 'female', label: Text(s.isTamil ? 'பெண்' : 'Female')),
                ],
                selected: {_gender},
                onSelectionChanged: (val) => setState(() => _gender = val.first),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text(s.isTamil ? 'வயது: $_age' : 'Age: $_age', style: theme.textTheme.titleMedium),
              Slider(
                value: _age.toDouble(),
                min: 15,
                max: 100,
                divisions: 85,
                label: _age.toString(),
                onChanged: (val) => setState(() => _age = val.toInt()),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text(s.isTamil ? 'உயரம்: ${_height.toInt()} செ.மீ' : 'Height: ${_height.toInt()} cm', style: theme.textTheme.titleMedium),
              Slider(
                value: _height,
                min: 120,
                max: 220,
                divisions: 100,
                label: _height.toStringAsFixed(0),
                onChanged: (val) => setState(() => _height = val),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text(s.isTamil ? 'எடை: ${_weight.toStringAsFixed(1)} கி.கி' : 'Weight: ${_weight.toStringAsFixed(1)} kg', style: theme.textTheme.titleMedium),
              Slider(
                value: _weight,
                min: 40,
                max: 150,
                divisions: 220,
                label: _weight.toStringAsFixed(1),
                onChanged: (val) => setState(() => _weight = val),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text(s.activityLevel, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              DropdownMenu<double>(
                initialSelection: _activityMult,
                width: MediaQuery.of(context).size.width - 2 * AppSpacing.xl,
                onSelected: (val) {
                  if (val != null) setState(() => _activityMult = val);
                },
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: 1.2, label: s.sedentary),
                  DropdownMenuEntry(value: 1.375, label: s.light),
                  DropdownMenuEntry(value: 1.55, label: s.moderate),
                  DropdownMenuEntry(value: 1.725, label: s.active),
                  DropdownMenuEntry(value: 1.9, label: s.veryActive),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(s.isTamil ? 'இலக்கு' : 'Goal', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'lose_0.5', label: Text(s.isTamil ? '-0.5 கி.கி/வாரம்' : '-0.5 kg/wk')),
                  ButtonSegment(value: 'lose_0.25', label: Text(s.isTamil ? '-0.25 கி.கி/வாரம்' : '-0.25 kg/wk')),
                  ButtonSegment(value: 'maintain', label: Text(s.isTamil ? 'பராமரிப்பு' : 'Maintain')),
                ],
                selected: {_weightGoal},
                onSelectionChanged: (val) => setState(() => _weightGoal = val.first),
              ),
              const SizedBox(height: AppSpacing.xl),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      s.isTamil ? 'உங்களது தினசரி இலக்கு: ${targetKcal.toInt()} கலோரி' : 'Your daily target: ${targetKcal.toInt()} kcal',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      s.isTamil ? 'பற்றாக்குறை இலக்கு: -${deficitGoal.toInt()} கலோரி' : 'Deficit target: -${deficitGoal.toInt()} kcal',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: FilledButton(
          onPressed: _onSave,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
          ),
          child: Text(s.saveChanges, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
