import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/core/providers/shared_prefs_provider.dart';
import 'package:kalori/core/utils/tdee_calculator.dart';

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
        title: const Text('Set up your profile'),
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
              Text('Gender', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'male', label: Text('Male')),
                  ButtonSegment(value: 'female', label: Text('Female')),
                ],
                selected: {_gender},
                onSelectionChanged: (val) => setState(() => _gender = val.first),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text('Age: $_age', style: theme.textTheme.titleMedium),
              Slider(
                value: _age.toDouble(),
                min: 15,
                max: 100,
                divisions: 85,
                label: _age.toString(),
                onChanged: (val) => setState(() => _age = val.toInt()),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text('Height: ${_height.toInt()} cm', style: theme.textTheme.titleMedium),
              Slider(
                value: _height,
                min: 120,
                max: 220,
                divisions: 100,
                label: _height.toStringAsFixed(0),
                onChanged: (val) => setState(() => _height = val),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text('Weight: ${_weight.toStringAsFixed(1)} kg', style: theme.textTheme.titleMedium),
              Slider(
                value: _weight,
                min: 40,
                max: 150,
                divisions: 220,
                label: _weight.toStringAsFixed(1),
                onChanged: (val) => setState(() => _weight = val),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text('Activity Level', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              DropdownMenu<double>(
                initialSelection: _activityMult,
                onSelected: (val) {
                  if (val != null) setState(() => _activityMult = val);
                },
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 1.2, label: 'Sedentary'),
                  DropdownMenuEntry(value: 1.375, label: 'Light'),
                  DropdownMenuEntry(value: 1.55, label: 'Moderate'),
                  DropdownMenuEntry(value: 1.725, label: 'Active'),
                  DropdownMenuEntry(value: 1.9, label: 'Very Active'),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Goal', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'lose_0.5', label: Text('-0.5 kg/wk')),
                  ButtonSegment(value: 'lose_0.25', label: Text('-0.25 kg/wk')),
                  ButtonSegment(value: 'maintain', label: Text('Maintain')),
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
                      'Your daily target: ${targetKcal.toInt()} kcal',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Deficit: -${deficitGoal.toInt()} kcal',
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
          child: const Text('Save & Continue', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
