import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kalori/core/utils/tdee_calculator.dart';
import 'package:kalori/api/api_client.dart';

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
  final double targetKcalApi;

  int get tdee => TDEECalculator.mifflinStJeor(
    weightKg: weight,
    heightCm: height,
    age: age,
    gender: gender,
    activityMult: activityMult,
  ).toInt();

  int get targetKcal => targetKcalApi > 0 ? targetKcalApi.toInt() : (tdee - deficitGoal);

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
    required this.targetKcalApi,
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
    double? targetKcalApi,
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
      targetKcalApi: targetKcalApi ?? this.targetKcalApi,
    );
  }

  factory ProfileState.fromApi(Map<String, dynamic> json, bool isDarkMode, String language) {
    final String sex = json['sex'] as String? ?? 'male';
    final String level = json['activity_level'] as String? ?? 'moderate';
    final String goalStr = json['goal'] as String? ?? 'maintain';

    double activityMult = 1.55;
    if (level == 'sedentary') {
      activityMult = 1.2;
    } else if (level == 'light') {
      activityMult = 1.375;
    } else if (level == 'moderate') {
      activityMult = 1.55;
    } else if (level == 'active') {
      activityMult = 1.725;
    } else if (level == 'very_active') {
      activityMult = 1.90;
    }

    int deficitGoal = 0;
    if (goalStr == 'lose') {
      deficitGoal = 500;
    } else if (goalStr == 'gain') {
      deficitGoal = -500;
    }

    return ProfileState(
      name: json['name'] as String? ?? 'User',
      gender: sex,
      age: json['age'] as int? ?? 28,
      weight: (json['weight_kg'] as num?)?.toDouble() ?? 70.0,
      height: (json['height_cm'] as num?)?.toDouble() ?? 170.0,
      activityMult: activityMult,
      deficitGoal: deficitGoal,
      isDarkMode: isDarkMode,
      language: language,
      targetKcalApi: (json['target_kcal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ProfileNotifier extends AsyncNotifier<ProfileState> {
  @override
  Future<ProfileState> build() async {
    final apiMap = await ApiClient.getProfile();
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    final lang = prefs.getString('language') ?? 'en';
    
    return ProfileState.fromApi(apiMap, isDark, lang);
  }

  Future<void> updateActivity(double mult) async {
    final current = state.value;
    if (current == null) {
      return;
    }
    
    String level = 'moderate';
    if (mult <= 1.2) {
      level = 'sedentary';
    } else if (mult <= 1.4) {
      level = 'light';
    } else if (mult <= 1.6) {
      level = 'moderate';
    } else if (mult <= 1.8) {
      level = 'active';
    } else {
      level = 'very_active';
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedApi = await ApiClient.updateProfile({
        'activity_level': level,
      });
      return ProfileState.fromApi(updatedApi, current.isDarkMode, current.language);
    });
  }

  Future<void> updateDeficit(int deficit) async {
    final current = state.value;
    if (current == null) {
      return;
    }

    String goal = 'maintain';
    if (deficit > 0) {
      goal = 'lose';
    } else if (deficit < 0) {
      goal = 'gain';
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedApi = await ApiClient.updateProfile({
        'goal': goal,
      });
      return ProfileState.fromApi(updatedApi, current.isDarkMode, current.language);
    });
  }

  Future<void> toggleTheme(bool isDark) async {
    final current = state.value;
    if (current == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    state = AsyncValue.data(current.copyWith(isDarkMode: isDark));
  }

  Future<void> updateLanguage(String lang) async {
    final current = state.value;
    if (current == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    state = AsyncValue.data(current.copyWith(language: lang));
  }

  Future<void> updateProfile({
    String? name,
    String? gender,
    int? age,
    double? weight,
    double? height,
  }) async {
    final current = state.value;
    if (current == null) {
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedApi = await ApiClient.updateProfile({
        if (name != null) 'name': name,
        if (gender != null) 'sex': gender,
        if (age != null) 'age': age,
        if (weight != null) 'weight_kg': weight,
        if (height != null) 'height_cm': height,
      });
      return ProfileState.fromApi(updatedApi, current.isDarkMode, current.language);
    });
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, ProfileState>(() => ProfileNotifier());
