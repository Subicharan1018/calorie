import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/core/utils/tdee_calculator.dart';
import 'package:kalori/mock/mock_data.dart';

class ProfileState {
  final String name;
  final String gender;
  final int age;
  final double weight;
  final double height;
  final double activityMult;
  final int deficitGoal;
  final bool isDarkMode;
  final String language;

  int get tdee => TDEECalculator.mifflinStJeor(
    weightKg: weight,
    heightCm: height,
    age: age,
    gender: gender,
    activityMult: activityMult,
  ).toInt();

  int get targetKcal => tdee - deficitGoal;

  const ProfileState({
    required this.name,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.activityMult,
    required this.deficitGoal,
    required this.isDarkMode,
    required this.language,
  });

  ProfileState copyWith({
    String? name,
    String? gender,
    int? age,
    double? weight,
    double? height,
    double? activityMult,
    int? deficitGoal,
    bool? isDarkMode,
    String? language,
  }) {
    return ProfileState(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      activityMult: activityMult ?? this.activityMult,
      deficitGoal: deficitGoal ?? this.deficitGoal,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return ProfileState(
      name: mockUserProfile.name,
      gender: mockUserProfile.gender,
      age: mockUserProfile.age,
      weight: mockUserProfile.weightKg,
      height: mockUserProfile.heightCm,
      activityMult: 1.55, // moderate
      deficitGoal: mockUserProfile.deficitTarget,
      isDarkMode: false,
      language: 'en',
    );
  }

  void updateActivity(double mult) => state = state.copyWith(activityMult: mult);
  void updateDeficit(int deficit) => state = state.copyWith(deficitGoal: deficit);
  void toggleTheme(bool isDark) => state = state.copyWith(isDarkMode: isDark);
  void updateLanguage(String lang) => state = state.copyWith(language: lang);
  
  void updateProfile({
    String? name,
    String? gender,
    int? age,
    double? weight,
    double? height,
  }) {
    state = state.copyWith(
      name: name,
      gender: gender,
      age: age,
      weight: weight,
      height: height,
    );
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() => ProfileNotifier());
