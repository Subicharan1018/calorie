class TDEECalculator {
  static double mifflinStJeor({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required double activityMult,
  }) {
    double bmr;
    if (gender == 'male') {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }
    return bmr * activityMult;
  }
}
