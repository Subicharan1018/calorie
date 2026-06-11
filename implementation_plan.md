# Connect All API Endpoints to the App

The app currently uses **mock/hardcoded data** across all features. The backend API (`http://100.99.105.51:8100`) is live and documented. This plan replaces all mock calls with real API calls using `ApiClient`, while preserving all UI, models, and UX behaviour.

---

## What Changes

### Overview

| Feature | Current | After |
|---|---|---|
| Ingredient search (Log tab) | `mockVegetables` static list | `GET /ingredients/search?q=` |
| Recipe suggestions | `mockRecipes` static list | `GET /recipes?ingredients=<codes>` |
| Log a meal (recipe detail sheet) | Local `dashboardProvider.addMeal()` | `POST /meals/log` then refresh |
| Dashboard / today summary | Hardcoded `DailySummary` with 1 meal | `GET /meals/today` |
| Delete meal from dashboard | Local state removal | `DELETE /meals/log/{id}` then refresh |
| Barcode lookup | `mockBarcodeProducts` list | `GET /barcode/{barcode}` |
| Log barcode meal | Local `dashboardProvider.addMeal()` | `POST /meals/log` (ingredient code if matched, else synthetic) |
| Weight history (Trends) | `mockWeightLogs` static | `GET /weight?days=90` |
| Log weight | Local `trendsProvider.addWeightLog()` | `POST /weight` then refresh |
| Calorie trend (Trends) | `mockCalorieTrend` static | `GET /meals/history?days=7` aggregated |
| Profile | `mockUserProfile` hardcoded | `GET /profile` + `PUT /profile` |

---

## Proposed Changes

### A. New File — `lib/api/api_client.dart` [NEW]

The `ApiClient` class from the API reference (section 10) — complete Dart implementation of all endpoints using `http` package. Covers:
- `searchIngredients(q, {limit, offset})`
- `getIngredient(code)`
- `getRecipes({ingredients, mealType, limit})`
- `getRecipe(id)`
- `logIngredient({mealType, ingredientCode, quantityG})`
- `logRecipe({mealType, recipeId, servingsEaten})`
- `getTodaySummary({date})`
- `getMealHistory({days, mealType})`
- `deleteLog(logId)`
- `logWeight(kg, {note})`
- `getWeightHistory({days})`
- `deleteWeight(logId)`
- `getProfile()`
- `updateProfile(data)`
- `lookupBarcode(barcode)`
- `isHealthy()`

> [!NOTE]
> The pubspec already has `dio: ^5.4.3` and `pretty_dio_logger`. We'll use the `http` package as shown in the API reference quickstart (already transitively available) OR use Dio. Since `http` is referenced in API_REFERENCE.md and `dio` is already in pubspec, we'll use **Dio** for consistency with what's already declared.

---

### B. Model Updates

#### [MODIFY] `lib/core/models/meal_log.dart`
- Add `fromApiJson()` factory to parse `MealLogOut` response shape from the API.
- Add nullable `recipeId`, `recipeName`, `ingredientCode` fields to match the API response (the current model only has `recipeName`).
- Change `id` from `String` to `int` to match API integers.

#### [MODIFY] `lib/core/models/weight_log.dart`
- Add `fromApiJson()` factory to parse API response.
- Change `id` from `String` to `int`.

#### [MODIFY] `lib/core/models/daily_summary.dart`
- Add `fromApiJson()` factory to parse `DailySummary` response.
- Add `date` field.

#### [NEW] `lib/features/log/models/ingredient.dart`
- New model to represent `IngredientBase` from API (code, name, grup, energy_kcal, protein, carb, fat, fibre, calcium, iron, vitc).
- Replace the current `Vegetable` model usage in search — `Ingredient` maps 1:1 to API search results.

#### [NEW] `lib/features/log/models/api_recipe.dart`
- New model to represent the API `Recipe` shape (id as int, name, description, cuisine, meal_type, prep_mins, cook_mins, servings, energy_kcal, protein, carb, fat, fibre, is_ai, ingredients list).
- The current `Recipe` model is shaped for the old mock data and incompatible with the API.

---

### C. Provider Updates

#### [MODIFY] `lib/features/home/providers/dashboard_provider.dart`
- Convert to `AsyncNotifier<DailySummary>` (was sync `Notifier`).
- `build()` → calls `ApiClient.getTodaySummary()`.
- `deleteMeal(int id)` → calls `ApiClient.deleteLog(id)` then refreshes.
- `addMeal()` method removed — logging now goes through the log providers, which then invalidate this provider.

#### [MODIFY] `lib/features/log/providers/vegetable_search_provider.dart`
- `searchResultsProvider` → `FutureProvider.autoDispose` calling `ApiClient.searchIngredients(q)`.
- Selected items type changes from `List<Vegetable>` to `List<Ingredient>`.

#### [MODIFY] `lib/features/log/providers/recipe_suggestions_provider.dart`
- Call `ApiClient.getRecipes(ingredients: codes.join(','))` instead of filtering `mockRecipes`.
- Remove the fake 3.5s delay.

#### [MODIFY] `lib/features/trends/providers/trends_provider.dart`
- `build()` → async, calls `ApiClient.getWeightHistory()` and `ApiClient.getMealHistory(days: 7)`.
- `addWeightLog()` → calls `ApiClient.logWeight(kg)` then refreshes.
- Convert to `AsyncNotifier<TrendsState>`.

#### [MODIFY] `lib/features/profile/providers/profile_provider.dart`
- `build()` → calls `ApiClient.getProfile()` (auto-creates on first GET).
- `updateProfile()` → calls `ApiClient.updateProfile(data)`.
- Convert to `AsyncNotifier<ProfileState>`.

---

### D. Screen / Widget Updates

#### [MODIFY] `lib/features/log/screens/vegetable_input_screen.dart`
- Update to use `Ingredient` model instead of `Vegetable`.
- `searchResultsProvider` now returns `AsyncValue<List<Ingredient>>` — add loading skeleton and error state.

#### [MODIFY] `lib/features/log/screens/recipe_suggestions_screen.dart`
- Update to use `ApiRecipe` model instead of the old `Recipe` model.
- Update card display to use `energy_kcal / servings` for per-serving calories.
- Remove import of `mock_data.dart` (used for Tamil name lookup).

#### [MODIFY] `lib/features/log/widgets/recipe_detail_sheet.dart`
- Accept `ApiRecipe` instead of old `Recipe`.
- On "Log Meal": call `ApiClient.logRecipe()` → then `ref.invalidate(dashboardProvider)`.

#### [MODIFY] `lib/features/barcode/barcode_scanner_screen.dart`
- `_onSimulateScan()` → calls `ApiClient.lookupBarcode(barcode)` instead of searching `mockBarcodeProducts`.
- On "Log Product": call `ApiClient.logIngredient()` with synthesised ingredient code or fallback approach → then `ref.invalidate(dashboardProvider)`.
- Update `BarcodeProduct` model to use API response fields.

#### [MODIFY] `lib/features/trends/widgets/weight_log_sheet.dart`
- On save: call `ApiClient.logWeight(kg)` via `trendsProvider.notifier.addWeightLog()`.

#### [MODIFY] `lib/features/profile/screens/profile_screen.dart`
- Wrap in `AsyncValue` consumer to show loading/error states.
- On update: call `ApiClient.updateProfile()`.

---

### E. Dependency / Config

#### [MODIFY] `pubspec.yaml`
- Add `http: ^1.2.0` (if using http) OR confirm Dio is used.
- Since Dio is already listed, we'll use **Dio** throughout `ApiClient`.

> [!IMPORTANT]
> The base URL `http://100.99.105.51:8100` is a Tailscale IP. This must be reachable from the device running the app. No change needed from a code perspective — it will just work if the device is on the Tailscale network.

---

## Verification Plan

### Manual Verification
1. Launch app → Dashboard should show today's real meal logs from the API.
2. Log tab → search "chicken" → real ICMR results appear.
3. Select ingredients → "Find Recipes" → real recipes from API appear.
4. Tap a recipe → detail sheet → "Log Meal" → dashboard ring updates.
5. Barcode screen → simulate scan → real product info from Open Food Facts.
6. Trends tab → real weight history and calorie trend charts.
7. Profile tab → real profile data loaded; update saves to API.
8. Delete a meal from dashboard → disappears from API and UI.

### Automated Build Check
```bash
flutter analyze
flutter build apk --debug
```
