import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalori/core/providers/language_provider.dart';

class AppStrings {
  final Locale locale;
  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    final container = ProviderScope.containerOf(context, listen: false);
    final locale = container.read(languageProvider);
    return AppStrings(locale);
  }

  bool get isTamil => locale.languageCode == 'ta';

  // Navigation
  String get home => isTamil ? 'முகப்பு' : 'Home';
  String get log => isTamil ? 'பதிவு' : 'Log';
  String get trends => isTamil ? 'போக்குகள்' : 'Trends';
  String get profile => isTamil ? 'சுயவிவரம்' : 'Profile';

  // Home Screen
  String get remaining => isTamil ? 'மீதமுள்ளது' : 'remaining';
  String get kcalRemaining => isTamil ? 'கலோரி மீதம்' : 'kcal remaining';
  String get protein => isTamil ? 'புரதம்' : 'Protein';
  String get carbs => isTamil ? 'கார்ப்ஸ்' : 'Carbs';
  String get fat => isTamil ? 'கொழுப்பு' : 'Fat';
  String get breakfast => isTamil ? 'காலை உணவு · Kaalaai Saapadu' : 'Breakfast';
  String get lunch => isTamil ? 'மதிய உணவு · Madiyam Saapadu' : 'Lunch';
  String get snack => isTamil ? 'சிற்றுண்டி · Maaalai Tiffin' : 'Snack';
  String get dinner => isTamil ? 'இரவு உணவு · Iravu Saapadu' : 'Dinner';
  String get noMealsLogged => isTamil ? 'உணவுகள் எதுவும் பதிவு செய்யப்படவில்லை' : 'No meals logged yet';
  String get tapPlusToLog => isTamil ? 'இன்றைய முதல் உணவை பதிவு செய்ய + தட்டவும்' : 'Tap + to log your first meal today';
  String get addBreakfast => isTamil ? 'காலை உணவு சேர்' : 'Add Breakfast';
  String get addLunch => isTamil ? 'மதிய உணவு சேர்' : 'Add Lunch';
  String get addSnack => isTamil ? 'சிற்றுண்டி சேர்' : 'Add Snack';
  String get addDinner => isTamil ? 'இரவு உணவு சேர்' : 'Add Dinner';
  String get micronutrients => isTamil ? 'நுண்ணூட்டச்சத்துக்கள்' : 'Micronutrients';
  String get iron => isTamil ? 'இரும்புச்சத்து (Iron)' : 'Iron';
  String get calcium => isTamil ? 'கால்சியம் (Calcium)' : 'Calcium';
  String get vitaminC => isTamil ? 'வைட்டமின் சி (Vitamin C)' : 'Vitamin C';
  String get fibre => isTamil ? 'நார்ச்சத்து (Fibre)' : 'Fibre';
  String get dailyRequirement => isTamil ? 'தினசரி தேவை' : 'Daily Requirement';

  // Log Screen
  String get whatVegetablesDoYouHave => isTamil ? 'உங்களிடம் என்ன காய்கறிகள் உள்ளன?' : 'What vegetables do you have?';
  String get wellFindRecipes => isTamil ? 'அதற்கேற்ற தென்னிந்திய உணவு வகைகளைக் கண்டறிவோம்' : 'We\'ll find South Indian recipes that match';
  String get searchVegetables => isTamil ? 'காய்கறிகளைத் தேடவும்...' : 'Search vegetables...';
  String get selectedVegetables => isTamil ? 'தேர்ந்தெடுக்கப்பட்ட காய்கறிகள்' : 'Selected Vegetables';
  String get searchAndAddAbove => isTamil ? 'காய்கறிகளைத் தேடி மேலே சேர்க்கவும்' : 'Search and add vegetables above';
  String get vegetablesSelected => isTamil ? 'காய்கறிகள் தேர்ந்தெடுக்கப்பட்டுள்ளன' : 'vegetables selected';
  String get findRecipes => isTamil ? 'உணவு வகைகளைக் கண்டுபிடி →' : 'Find Recipes →';
  
  // Categories
  String get leafyGreen => isTamil ? 'கீரை வகை (Leafy Green)' : 'Leafy Green';
  String get root => isTamil ? 'கிழங்கு வகை (Root)' : 'Root';
  String get gourd => isTamil ? 'காய் வகை (Gourd)' : 'Gourd';
  String get legume => isTamil ? 'பயறு வகை (Legume)' : 'Legume';
  String get grain => isTamil ? 'தானிய வகை (Grain)' : 'Grain';

  String get recipesFor => isTamil ? 'உங்களுக்கான உணவு வகைகள்' : 'Recipes for';
  String get showingRecipes => isTamil ? 'காட்டப்படும் உணவு வகைகள்' : 'Showing recipes';
  String get fromAISuggestions => isTamil ? 'செயற்கை நுண்ணறிவு பரிந்துரைகள்' : 'from AI suggestions';
  String get aiGenerating => isTamil ? 'செயற்கை நுண்ணறிவு பரிந்துரைக்கிறது...' : 'Asking AI for recipes...';
  String get parsingRecipes => isTamil ? 'பரிந்துரைகளை பகுப்பாய்வு செய்கிறது...' : 'Parsing recipes...';
  String get noRecipesFound => isTamil ? 'உணவுகள் எதுவும் கிடைக்கவில்லை' : 'No recipes found';
  String get aiGeneratingNew => isTamil ? 'புதிய பரிந்துரைகளை உருவாக்குகிறது' : 'No recipes found — AI is generating new ones';
  String get lowestCal => isTamil ? 'குறைந்த கலோரி' : 'Lowest Cal';
  String get bestProtein => isTamil ? 'அதிக புரதம்' : 'Best Protein';
  String get bestMatch => isTamil ? 'சிறந்த பொருத்தம்' : 'Best Match';
  String get servingSize => isTamil ? 'பரிமாறும் அளவு' : 'Serving Size';
  String get logThisMeal => isTamil ? 'இந்த உணவை பதிவுசெய்' : 'Log This Meal';
  String get icmrVerified => isTamil ? 'ICMR-NIN சரிபார்க்கப்பட்டது' : 'ICMR-NIN verified';
  String get aiGenerated => isTamil ? 'AI-உருவாக்கியது, சரிபார்க்கவும்' : 'AI-generated, verify before use';
  String get scanBarcode => isTamil ? 'பார்கோடு ஸ்கேன் செய்' : 'Scan Barcode';
  String get pointCameraAtBarcode => isTamil ? 'கேமராவை பார்கோடுக்கு நேராக வைக்கவும்' : 'Point camera at barcode';
  String get productNotFound => isTamil ? 'தயாரிப்பு கண்டறியப்படவில்லை' : 'Product not found';
  String get productFound => isTamil ? 'தயாரிப்பு கண்டறியப்பட்டது' : 'Product found';

  // Trends Screen
  String get calorieTrend => isTamil ? 'கலோரி போக்கு' : 'Calorie Trend';
  String get weightProgress => isTamil ? 'எடை முன்னேற்றம்' : 'Weight Progress';
  String get target => isTamil ? 'இலக்கு' : 'Target';
  String get deficit => isTamil ? 'பற்றாக்குறை' : 'Deficit';
  String get surplus => isTamil ? 'அதிகப்படியானது' : 'Surplus';
  String get logWeight => isTamil ? 'எடையை பதிவு செய்' : 'Log Weight';
  String get lastLogged => isTamil ? 'கடைசியாக பதிவு செய்யப்பட்டது' : 'Last logged';
  String get lostKg => isTamil ? 'எடை குறைந்துள்ளது' : 'Lost';
  String get gainedKg => isTamil ? 'எடை அதிகரித்துள்ளது' : 'Gained';
  String get maintained => isTamil ? 'அதே எடை பராமரிக்கப்படுகிறது' : 'Maintained';

  // Profile Screen
  String get yourStats => isTamil ? 'உங்கள் புள்ளிவிவரங்கள்' : 'Your Stats';
  String get activityLevel => isTamil ? 'உடல் செயல்பாடு நிலை' : 'Activity Level';
  String get nutritionGoals => isTamil ? 'ஊட்டச்சத்து இலக்குகள்' : 'Nutrition Goals';
  String get app => isTamil ? 'செயலி அமைப்புகள்' : 'App';
  String get tdeePerDay => isTamil ? 'தினசரி TDEE' : 'TDEE';
  String get dailyDeficitTarget => isTamil ? 'தினசரி பற்றாக்குறை இலக்கு' : 'Daily deficit target';
  
  String get sedentary => isTamil ? 'குறைந்த உழைப்பு (Sedentary)' : 'Sedentary';
  String get light => isTamil ? 'மிதமான உழைப்பு (Light)' : 'Light';
  String get moderate => isTamil ? 'சாதாரண உழைப்பு (Moderate)' : 'Moderate';
  String get active => isTamil ? 'அதிக உழைப்பு (Active)' : 'Active';
  String get veryActive => isTamil ? 'மிக அதிக உழைப்பு (Very Active)' : 'Very Active';
  
  String get autoMacros => isTamil ? 'தானியங்கி மேக்ரோஸ்' : 'Auto (40C/30P/30F)';
  String get customMacros => isTamil ? 'தனிப்பயன் மேக்ரோஸ்' : 'Custom';
  String get darkTheme => isTamil ? 'இருண்ட தீம்' : 'Dark Theme';
  String get lightTheme => isTamil ? 'ஒளிரும் தீம்' : 'Light Theme';
  String get systemTheme => isTamil ? 'கணினி தீம்' : 'System Theme';
  String get language => isTamil ? 'மொழி (Language)' : 'Language';
  String get exportData => isTamil ? 'தரவை ஏற்றுமதி செய் (CSV)' : 'Export Data (CSV)';
  String get about => isTamil ? 'செயலியைப் பற்றி' : 'About Kalori';
  String get recalculate => isTamil ? 'மீண்டும் கணக்கிடு' : 'Recalculate';
  String get saveChanges => isTamil ? 'சேமிக்கவும்' : 'Save & Continue';

  // Barcode Scanner
  String get barcodeScannerTitle => isTamil ? 'பார்கோடு ஸ்கேனர்' : 'Barcode Scanner';
  String get pointCamera => isTamil ? 'கேமராவை பார்கோடுக்கு நேராக பொருத்தவும்' : 'Point camera at barcode';
  String get scanningProduct => isTamil ? 'தயாரிப்பை ஸ்கேன் செய்கிறது...' : 'Scanning product...';
  String get productFoundTitle => isTamil ? 'தயாரிப்பு கண்டறியப்பட்டது' : 'Product Found';
  String get logProduct => isTamil ? 'தயாரிப்பை பதிவு செய்' : 'Log This Product';
  String get tryAgain => isTamil ? 'மீண்டும் முயலவும்' : 'Try Again';

  // Empty States
  String get emptyMealsHeadline => isTamil ? 'உணவுகள் எதுவும் இல்லை' : 'No meals logged yet';
  String get emptyMealsSub => isTamil ? 'இன்றைய உணவை பதிவு செய்ய + பட்டனை தட்டவும்' : 'Tap the + button to log your first meal today.';
  String get emptyWeightHeadline => isTamil ? 'எடை பதிவுகள் இல்லை' : 'No weight logs';
  String get emptyWeightSub => isTamil ? 'உங்கள் எடையைக் கண்காணிக்க முதலில் பதிவு செய்யவும்' : 'Start logging your weight to track your progress.';
  String get emptyRecipesHeadline => isTamil ? 'உணவு வகைகள் எதுவும் இல்லை' : 'No recipes found';
  String get emptyRecipesSub => isTamil ? 'செயற்கை நுண்ணறிவு புதிய உணவு வகைகளை உருவாக்குகிறது' : 'AI is generating new recipes for your selection.';
  String get emptyTrendsHeadline => isTamil ? 'போக்குகள் இன்னும் தயாராகவில்லை' : 'No logs yet';
  String get emptyTrendsSub => isTamil ? 'இன்றைய உணவை பதிவு செய்து வரைபடத்தைக் காணவும்' : 'Start logging meals to see your trend charts.';

  // Errors
  String get networkError => isTamil ? 'இணைய இணைப்பு இல்லை. Tailscale இணைப்பை சரிபார்க்கவும்.' : 'Can\'t reach server · Check your Tailscale connection';
  String get retryButton => isTamil ? 'மீண்டும் முயற்சி செய்' : 'Retry';
  String get apiError => isTamil ? 'பயன்பாட்டு பிழை நிகழ்ந்துள்ளது' : 'API error occurred';
  String get validationError => isTamil ? 'மதிப்பு தவறானது' : 'Validation error';
  String get emptySearchResult => isTamil ? 'முடிவுகள் எதுவும் இல்லை. பொதுவான பெயரை தேடவும்' : 'No results found. Try searching by common name.';

  // Nutrition Label Scanner Strings
  String get scanNutritionLabel => isTamil ? 'ஊட்டச்சத்து லேபிளை ஸ்கேன் செய்' : 'Scan Nutrition Label';
  String get uploadLabelPhoto => isTamil ? 'லேபிள் படத்தை பதிவேற்று' : 'Upload Label Photo';
  String get analyzingLabel => isTamil ? 'ஊட்டச்சத்து லேபிளை பகுப்பாய்வு செய்கிறது...' : 'Analyzing nutrition label...';
  String get productNotFoundScanLabelPrompt => isTamil
      ? 'தயாரிப்பு கண்டறியப்படவில்லை. ஊட்டச்சத்து லேபிளை ஸ்கேன் செய்ய விரும்புகிறீர்களா?'
      : 'Product not found. Would you like to scan its nutrition label?';
  String get scanLabelOption => isTamil ? 'லேபிளை ஸ்கேன் செய்' : 'Scan Label';
  String get labelScanFailed => isTamil
      ? 'ஊட்டச்சத்து லேபிளைப் பகுப்பாய்வு செய்ய முடியவில்லை. தயவுசெய்து மீண்டும் முயற்சிக்கவும்.'
      : 'Could not analyze nutrition label. Please try again.';
}

