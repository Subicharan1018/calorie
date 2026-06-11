# Nutrition Tracker — API Reference

> **Base URL:** `http://100.99.105.51:8100`
> **Interactive Docs:** http://100.99.105.51:8100/docs
> **Data Source:** ICMR-NIN Indian Food Composition Tables 2017 (542 foods, 35 nutrients)
> **All nutrient values are per 100 g edible portion** unless noted otherwise.

---

## Table of Contents

1. [Health Check](#1-health-check)
2. [Ingredients](#2-ingredients)
3. [Recipes](#3-recipes)
4. [Meals (Food Log)](#4-meals-food-log)
5. [Weight](#5-weight)
6. [Profile](#6-profile)
7. [Barcode Lookup](#7-barcode-lookup)
8. [Recommendations](#8-recommendations)
9. [Data Models](#9-data-models)
10. [Error Handling](#10-error-handling)
11. [Flutter Integration Quickstart](#11-flutter-integration-quickstart)

---

## 1. Health Check

Verify the API and database are reachable. Call this on app launch.

```
GET /health
```

**Response 200**
```json
{
  "status": "ok",
  "service": "nutrition-tracker-api",
  "database": "connected"
}
```

**Flutter:**
```dart
final res = await http.get(Uri.parse('$baseUrl/health'));
if (res.statusCode != 200) throw Exception('Server unreachable');
```

---

## 2. Ingredients

### 2.1 Search Ingredients

Full-text search across English names, scientific names, regional language names, and tags.

```
GET /ingredients/search
```

| Parameter | Type    | Required | Default | Description |
|-----------|---------|----------|---------|-------------|
| `q`       | string  | ✅       | —       | Search term (1–100 chars) |
| `limit`   | integer | ❌       | `20`    | Max results (1–100) |
| `offset`  | integer | ❌       | `0`     | Pagination offset |

**Response 200**
```json
{
  "results": [
    {
      "code": "D075",
      "name": "Tomato, ripe, hybrid",
      "grup": "Other Vegetables",
      "energy_kcal": 79.0,
      "protein": 0.76,
      "carb": 3.2,
      "fat": 0.25,
      "fibre": 1.58,
      "calcium": 0.0089,
      "iron": 0.00022,
      "vitc": 0.02527
    }
  ],
  "total": 3,
  "query": "tomato"
}
```

```bash
curl "http://100.99.105.51:8100/ingredients/search?q=chicken&limit=5"
```

**Flutter:**
```dart
Future<Map<String, dynamic>> searchIngredients(String q, {int limit = 20}) async {
  final uri = Uri.parse('$baseUrl/ingredients/search')
      .replace(queryParameters: {'q': q, 'limit': '$limit'});
  final res = await http.get(uri);
  if (res.statusCode == 200) return jsonDecode(res.body);
  throw Exception('Search failed');
}
```

---

### 2.2 Get Ingredient by Code

Returns the full 35-field nutrition panel.

```
GET /ingredients/{code}
```

| Parameter | Type   | Description |
|-----------|--------|-------------|
| `code`    | string | IFCT code e.g. `D075`, `A013`, `N001` (case-insensitive) |

**Response 200**
```json
{
  "code": "D075",
  "name": "Tomato, ripe, hybrid",
  "scie": "Lycopersicon esculentum Mill.",
  "grup": "Other Vegetables",
  "tags": "vegetable veg",
  "lang": "Tamatar",
  "energy_kcal": 79.0,
  "water": 93.93,
  "protein": 0.76,
  "fat": 0.25,
  "carb": 3.2,
  "fibre": 1.58,
  "calcium": 0.0089,
  "iron": 0.00022,
  "sodium": 0.0046,
  "potassium": 0.237,
  "vita_rae": 0.0422,
  "vitc": 0.02527,
  "fat_sat": 0.035,
  "fat_mono": 0.038,
  "fat_poly": 0.104,
  "sugars": 2.63
}
```

**Response 404:** `{ "detail": "Ingredient 'XYZ' not found" }`

```bash
curl "http://100.99.105.51:8100/ingredients/D075"
```

---

## 3. Recipes

### 3.1 List / Filter Recipes

Recipes ranked by how many requested ingredient codes they use.

```
GET /recipes
```

| Parameter     | Type    | Required | Default | Description |
|---------------|---------|----------|---------|-------------|
| `ingredients` | string  | ❌       | —       | Comma-separated IFCT codes e.g. `D075,A013,B005` |
| `meal_type`   | string  | ❌       | —       | `breakfast`, `lunch`, `dinner`, `snack` |
| `limit`       | integer | ❌       | `10`    | Max results (1–50) |
| `offset`      | integer | ❌       | `0`     | Pagination offset |

**Response 200**
```json
{
  "total": 5,
  "results": [
    {
      "id": 1,
      "name": "Masala Oats Upma",
      "description": "Quick oat upma with mustard, curry leaves, onion and tomato.",
      "cuisine": "Indian",
      "meal_type": "breakfast",
      "prep_mins": 5,
      "cook_mins": 10,
      "servings": 2,
      "energy_kcal": 1453.72,
      "protein": 42.3,
      "carb": 210.5,
      "fat": 28.1,
      "fibre": 18.4,
      "is_ai": false,
      "ingredients": [
        {
          "ingredient_code": "A001",
          "ingredient_name": "Oats, rolled",
          "quantity_g": 80.0,
          "notes": "rolled oats"
        }
      ]
    }
  ]
}
```

> **Note:** `energy_kcal` is the **total for all servings**. Divide by `servings` to get per-serving value.

```bash
# All breakfast recipes
curl "http://100.99.105.51:8100/recipes?meal_type=breakfast"

# Recipes matching your fridge contents
curl "http://100.99.105.51:8100/recipes?ingredients=D075,A013,B005&limit=5"
```

---

### 3.2 Get Recipe by ID

```
GET /recipes/{recipe_id}
```

**Response 200** — same shape as items in the list above
**Response 404:** `{ "detail": "Recipe 42 not found" }`

---

## 4. Meals (Food Log)

### 4.1 Log a Meal

Record a food entry. Nutrition is auto-computed and stored.
Provide **either** `ingredient_code + quantity_g` **or** `recipe_id`.

```
POST /meals/log
```

| Field             | Type    | Required | Description |
|-------------------|---------|----------|-------------|
| `meal_type`       | string  | ✅       | `breakfast`, `lunch`, `dinner`, `snack` |
| `ingredient_code` | string  | ⚠️       | IFCT code. Required if not using recipe. |
| `quantity_g`      | float   | ⚠️       | Grams eaten. Required with `ingredient_code`. |
| `recipe_id`       | integer | ⚠️       | Recipe ID. Required if not using ingredient. |
| `servings_eaten`  | float   | ❌       | Servings consumed (default: `1.0`) |

**Example — raw ingredient:**
```json
{
  "meal_type": "lunch",
  "ingredient_code": "A013",
  "quantity_g": 200
}
```

**Example — recipe:**
```json
{
  "meal_type": "dinner",
  "recipe_id": 7,
  "servings_eaten": 1.5
}
```

**Response 201**
```json
{
  "id": 3,
  "logged_at": "2026-06-10T16:06:28.239485Z",
  "meal_type": "lunch",
  "source": "manual",
  "ingredient_code": "A013",
  "ingredient_name": "Rice, raw, brown",
  "quantity_g": 200.0,
  "recipe_id": null,
  "recipe_name": null,
  "servings_eaten": 1.0,
  "energy_kcal": 2960.0,
  "protein": 18.32,
  "carb": 149.6,
  "fat": 2.48,
  "fibre": 8.86
}
```

**Response 404** — ingredient or recipe not found
**Response 422** — validation error (missing required fields)

```bash
curl -X POST http://100.99.105.51:8100/meals/log \
  -H "Content-Type: application/json" \
  -d '{"meal_type":"lunch","ingredient_code":"A013","quantity_g":200}'
```

---

### 4.2 Get Today's Summary

All meal logs for a date + summed daily nutrition. Powers the Dashboard.

```
GET /meals/today
```

| Parameter | Type   | Required | Default | Description |
|-----------|--------|----------|---------|-------------|
| `date`    | string | ❌       | today   | ISO date `YYYY-MM-DD` |

**Response 200**
```json
{
  "date": "2026-06-10",
  "total_energy_kcal": 3083.0,
  "total_protein": 19.67,
  "total_carb": 153.66,
  "total_fat": 3.18,
  "total_fibre": 11.52,
  "logs": [
    {
      "id": 1,
      "logged_at": "2026-06-10T16:06:28Z",
      "meal_type": "breakfast",
      "source": "manual",
      "ingredient_code": "D076",
      "ingredient_name": "Tomato, ripe, local",
      "quantity_g": 150.0,
      "energy_kcal": 123.0,
      "protein": 1.35,
      "carb": 4.06,
      "fat": 0.71,
      "fibre": 2.66
    }
  ]
}
```

```bash
curl "http://100.99.105.51:8100/meals/today"
curl "http://100.99.105.51:8100/meals/today?date=2026-06-09"
```

---

### 4.3 Get Meal History

```
GET /meals/history
```

| Parameter   | Type    | Required | Default | Description |
|-------------|---------|----------|---------|-------------|
| `days`      | integer | ❌       | `7`     | Past N days (1–90) |
| `meal_type` | string  | ❌       | —       | Filter by meal type |

**Response 200** — Array of `MealLogOut` objects (most recent first)

---

### 4.4 Delete a Meal Log Entry

```
DELETE /meals/log/{log_id}
```

**Response 204** — Success (no body)
**Response 404** — Entry not found

---

## 5. Weight

### 5.1 Log Weight

```
POST /weight
```

| Field       | Type   | Required | Description |
|-------------|--------|----------|-------------|
| `weight_kg` | float  | ✅       | Kilograms (10–500) |
| `note`      | string | ❌       | Optional note e.g. `"morning, fasted"` |

**Example:** `{ "weight_kg": 72.5, "note": "morning" }`

**Response 201**
```json
{
  "id": 1,
  "logged_at": "2026-06-10T16:06:28.317281Z",
  "weight_kg": 72.5,
  "note": "morning"
}
```

---

### 5.2 Get Weight History

Powers the Trends screen.

```
GET /weight
```

| Parameter | Type    | Required | Default | Description |
|-----------|---------|----------|---------|-------------|
| `days`    | integer | ❌       | `90`    | Past N days (7–365) |

**Response 200**
```json
{
  "logs": [
    { "id": 1, "logged_at": "2026-06-10T16:06:28Z", "weight_kg": 72.5, "note": "morning" }
  ],
  "current_weight_kg": 72.5,
  "change_7d": null,
  "change_30d": null
}
```

| Field           | Description |
|-----------------|-------------|
| `current_weight_kg` | Most recent entry (`null` if none) |
| `change_7d`     | kg delta vs 7 days ago. Positive = gained, negative = lost. `null` if no baseline. |
| `change_30d`    | Same but 30-day window |

---

### 5.3 Delete Weight Entry

```
DELETE /weight/{log_id}
```

**Response 204** — Success
**Response 404** — Not found

---

## 6. Profile

Single-user profile. Auto-created on first GET.

### 6.1 Get Profile

```
GET /profile
```

**Response 200**
```json
{
  "id": 1,
  "name": "Subi",
  "age": 28,
  "sex": "male",
  "height_cm": 175.0,
  "weight_kg": 72.5,
  "activity_level": "moderate",
  "goal": "maintain",
  "target_kcal": 2610.0,
  "updated_at": null
}
```

---

### 6.2 Update Profile

All fields optional. `target_kcal` is **auto-computed via Mifflin-St Jeor** if sex + weight + height + age are all set and `target_kcal` is not sent.

```
PUT /profile
```

| Field            | Type    | Values |
|------------------|---------|--------|
| `name`           | string  | any |
| `age`            | integer | years |
| `sex`            | string  | `"male"`, `"female"`, `"other"` |
| `height_cm`      | float   | cm |
| `weight_kg`      | float   | kg |
| `activity_level` | string  | `"sedentary"`, `"light"`, `"moderate"`, `"active"`, `"very_active"` |
| `goal`           | string  | `"lose"`, `"maintain"`, `"gain"` |
| `target_kcal`    | float   | overrides computed TDEE |

**TDEE Multipliers**

| Level       | Multiplier |
|-------------|------------|
| sedentary   | 1.20 |
| light       | 1.375 |
| moderate    | 1.55 |
| active      | 1.725 |
| very_active | 1.90 |

**Response 200** — same as GET, with `target_kcal` auto-filled

```bash
curl -X PUT http://100.99.105.51:8100/profile \
  -H "Content-Type: application/json" \
  -d '{"name":"Subi","age":28,"sex":"male","height_cm":175,"weight_kg":72.5,"activity_level":"moderate","goal":"maintain"}'
```

---

## 7. Barcode Lookup

Looks up packaged food. Results cached in PostgreSQL for 30 days.
Indian brands (Parle, Haldiram, ITC, Amul, MTR…) are well-covered.

```
GET /barcode/{barcode}
```

| Parameter | Type   | Description |
|-----------|--------|-------------|
| `barcode` | string | EAN-13, EAN-8, or UPC-A digits |

**Response 200**
```json
{
  "barcode": "8901063152732",
  "product_name": "Parle-G Biscuits",
  "brand": "Parle",
  "quantity": "100g",
  "serving_size": "25g",
  "image_url": "https://images.openfoodfacts.org/...",
  "ingredients_text": "Wheat flour, sugar, ...",
  "nutrition_grades": "d",
  "energy_kcal": 462.0,
  "protein": 6.7,
  "carb": 73.0,
  "fat": 15.7,
  "fat_sat": 7.5,
  "fibre": 1.2,
  "sugars": 18.0,
  "sodium": 0.38,
  "source": "openfoodfacts"
}
```

| `source` value    | Meaning |
|-------------------|---------|
| `"openfoodfacts"` | Fetched live from Open Food Facts API |
| `"cache"`         | Served from local PostgreSQL (faster, same data) |

| `nutrition_grades` | Meaning |
|--------------------|---------|
| `a` | Best (healthiest) |
| `e` | Worst |

**Response 404** — Product not found in Open Food Facts

```bash
curl "http://100.99.105.51:8100/barcode/8901063152732"
```

---

## 8. Recommendations

Zero-ML, zero-external-API daily meal recommendation engine.
Scores every ingredient in the ICMR-NIN database against **your personal nutrient gaps**
(yesterday's intake vs. ICMR-NIN 2020 RDA targets) and returns a ranked list bucketed
into meal slots. Results are cached in PostgreSQL — first call of the day computes them,
every subsequent call is instant.

### 8.1 Get Today's Recommendations

```
GET /recommendations/today
```

| Parameter      | Type    | Required | Default | Description |
|----------------|---------|----------|---------|-------------|
| `date`         | date    | ❌       | today   | Date to recommend for (`YYYY-MM-DD`) |
| `force_refresh`| boolean | ❌       | `false` | Recompute even if cached. Use after logging meals. |

**Response 200**
```json
{
  "date": "2026-06-11",
  "generated_at": "2026-06-11T09:19:55.689342Z",
  "breakfast": [
    {
      "item_type": "ingredient",
      "item_id": "A009",
      "item_name": "Quinoa",
      "food_group": "Cereals and Millets",
      "meal_slot": "breakfast",
      "suggested_g": 150.0,
      "suggested_servings": null,
      "addresses": "protein,fibre",
      "top_nutrient": "protein",
      "energy_kcal": 2061.0,
      "protein": 19.7,
      "carb": 80.5,
      "fat": 8.2,
      "fibre": 22.0,
      "score": 1.9587,
      "is_primary": true,
      "reason": "Rich in Protein, Fibre · Not eaten recently · Vegetarian"
    }
  ],
  "lunch": [ ... ],
  "dinner": [ ... ],
  "snack": [ ... ]
}
```

| Field              | Type    | Notes |
|--------------------|---------|-------|
| `item_type`        | string  | `"ingredient"` or `"recipe"` |
| `item_id`          | string  | IFCT code (ingredient) or integer string (recipe) |
| `item_name`        | string  | Display name |
| `food_group`       | string? | IFCT food group, or `"Recipe"` |
| `meal_slot`        | string  | `breakfast`, `lunch`, `dinner`, `snack` |
| `suggested_g`      | float?  | Serving size in grams (ingredients only) |
| `suggested_servings` | float? | Servings (recipes only) |
| `addresses`        | string? | Comma-separated nutrients this item fills, e.g. `"iron,vitc,calcium"` |
| `top_nutrient`     | string? | The single biggest gap this item addresses |
| `energy_kcal`      | float?  | Pre-scaled to `suggested_g` / `suggested_servings` |
| `protein`          | float?  | Pre-scaled |
| `carb`             | float?  | Pre-scaled |
| `fat`              | float?  | Pre-scaled |
| `fibre`            | float?  | Pre-scaled |
| `score`            | float   | Composite gap-fill score (higher = better) |
| `is_primary`       | bool    | `true` = top pick for this meal slot |
| `reason`           | string  | Human-readable reason for Flutter display card |

**Scoring algorithm:**
- Computes your personal RDA from ICMR-NIN 2020 using profile sex, weight, activity, goal
- Gap = yesterday's actual intake − RDA (negative = deficit)
- Each ingredient scored: `Σ (nutrient_weight × contribution_to_gap)`
- **Diversity bonus:** +20% if food group not eaten yesterday
- **Recency penalty:** −15% per log in last 3 days (floor 10%)
- **Sodium cap:** high-sodium items penalised when yesterday's sodium > 2000 mg
- Max 5 per slot, max 2 items per food group per slot

```bash
# Default — today's recommendations
curl "http://100.99.105.51:8100/recommendations/today"

# Force recompute after logging a meal
curl "http://100.99.105.51:8100/recommendations/today?force_refresh=true"
```

---

### 8.2 Force Refresh Recommendations

Same as `GET /today?force_refresh=true` but as a POST. Use after a logging session.

```
POST /recommendations/refresh
```

**Response 200** — same shape as `GET /today`

```bash
curl -X POST "http://100.99.105.51:8100/recommendations/refresh"
```

---

### 8.3 Get Nutrient Gap Snapshot

Returns yesterday's actual intake vs. ICMR-NIN 2020 RDA.
Negative gap = deficit (ate less than needed). Positive = surplus or over limit (sodium).
Use this to power **"You were low on X yesterday"** cards in Flutter.

```
GET /recommendations/gaps
```

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `date`    | date | ❌       | yesterday | Day to query (`YYYY-MM-DD`) |

**Response 200**
```json
{
  "gap_date": "2026-06-10",
  "message": null,
  "gap_energy_kcal": 129.0,
  "gap_protein": -52.53,
  "gap_fat": 0.0,
  "gap_fibre": -18.48,
  "gap_calcium": -999.96,
  "gap_iron": -18.998,
  "gap_zinc": -16.996,
  "gap_vitc": -79.959,
  "gap_vita_rae": -999.999,
  "gap_vitd": -15.0,
  "gap_thiamine": -1.399,
  "gap_riboflavin": -2.0,
  "gap_niacin": -15.992,
  "gap_vitb6": -1.899,
  "gap_folate": -300.0,
  "gap_vitb12": -0.989,
  "gap_sodium": 0.0,
  "gap_potassium": -3499.296,
  "gap_magnesium": -439.792,
  "actual_energy_kcal": 3083.0,
  "actual_protein": 19.67,
  "actual_fat": 3.18,
  "actual_calcium": 0.037,
  "actual_iron": 0.00249
}
```

> **Unit note for gap fields:** Same unit as the RDA column — e.g. `gap_protein` is in **g**, `gap_iron` is in **g** (×1000 for mg), `gap_energy_kcal` is in **kcal**.

**Response when no meal data exists:**
```json
{
  "gap_date": "2026-06-10",
  "message": "No meal data logged for this date yet. Log meals and call /recommendations/today to generate a gap snapshot."
}
```

```bash
# Yesterday's gaps
curl "http://100.99.105.51:8100/recommendations/gaps"

# Specific date
curl "http://100.99.105.51:8100/recommendations/gaps?date=2026-06-10"
```

---

## 9. Data Models

### IngredientBase (search card fields)

| Field        | Type   | Unit |
|--------------|--------|------|
| `code`       | string | IFCT code |
| `name`       | string | English name |
| `grup`       | string | food group |
| `energy_kcal`| float? | kcal/100g |
| `protein`    | float? | g/100g |
| `carb`       | float? | g/100g |
| `fat`        | float? | g/100g |
| `fibre`      | float? | g/100g |
| `calcium`    | float? | **g**/100g — multiply ×1000 for mg |
| `iron`       | float? | **g**/100g — multiply ×1000 for mg |
| `vitc`       | float? | **g**/100g — multiply ×1000 for mg |

> **Unit note:** Minerals and vitamins from ICMR-NIN are stored in g/100g (the raw CSV unit). In the UI multiply by 1000 to show mg.

### IngredientDetail (all IngredientBase fields +)

`water`, `ash`, `phosphorus`, `sodium`, `potassium`, `magnesium`, `zinc`,
`copper`, `manganese`, `selenium`, `iodine`, `vita_rae`, `vitd`, `vite`,
`vitk`, `thiamine`, `riboflavin`, `niacin`, `vitb6`, `folate`, `vitb12`,
`pantothenic`, `biotin`, `fat_sat`, `fat_mono`, `fat_poly`, `cholesterol`,
`sugars`, `starch`, `tags`, `scie`, `lang`

### MealLogOut

| Field             | Type     | Notes |
|-------------------|----------|-------|
| `id`              | integer  | |
| `logged_at`       | datetime | ISO 8601 UTC |
| `meal_type`       | string   | breakfast/lunch/dinner/snack |
| `source`          | string   | `manual`, `recipe`, `barcode` |
| `ingredient_code` | string?  | null if recipe log |
| `ingredient_name` | string?  | display name |
| `quantity_g`      | float?   | null if recipe log |
| `recipe_id`       | integer? | null if ingredient log |
| `recipe_name`     | string?  | display name |
| `servings_eaten`  | float?   | null if ingredient log |
| `energy_kcal`     | float?   | already scaled to quantity eaten |
| `protein`         | float?   | already scaled |
| `carb`            | float?   | already scaled |
| `fat`             | float?   | already scaled |
| `fibre`           | float?   | already scaled |

### DailySummary

| Field               | Type  |
|---------------------|-------|
| `date`              | date  |
| `total_energy_kcal` | float |
| `total_protein`     | float |
| `total_carb`        | float |
| `total_fat`         | float |
| `total_fibre`       | float |
| `logs`              | MealLogOut[] |

### RecommendationOut

| Field               | Type    | Notes |
|---------------------|---------|-------|
| `item_type`         | string  | `"ingredient"` or `"recipe"` |
| `item_id`           | string  | IFCT code or recipe id |
| `item_name`         | string  | |
| `food_group`        | string? | |
| `meal_slot`         | string  | `breakfast`, `lunch`, `dinner`, `snack` |
| `suggested_g`       | float?  | Grams at recommended serving (ingredients) |
| `suggested_servings`| float?  | Servings (recipes) |
| `addresses`         | string? | Comma-separated nutrient keys e.g. `"iron,vitc"` |
| `top_nutrient`      | string? | Single most-addressed nutrient |
| `energy_kcal`       | float?  | Pre-scaled to suggested serving |
| `protein`           | float?  | Pre-scaled |
| `carb`              | float?  | Pre-scaled |
| `fat`               | float?  | Pre-scaled |
| `fibre`             | float?  | Pre-scaled |
| `score`             | float   | Composite gap-fill score |
| `is_primary`        | bool    | Top-ranked pick for this slot |
| `reason`            | string  | Display string e.g. `"Rich in Iron · Not eaten recently"` |

### NutrientGapOut

| Field              | Type    | Notes |
|--------------------|---------|-------|
| `gap_date`         | date    | Date of the gap snapshot |
| `message`          | string? | Non-null only when no meal data exists |
| `gap_energy_kcal`  | float?  | kcal. Negative = deficit |
| `gap_protein`      | float?  | g. Negative = deficit |
| `gap_iron`         | float?  | g (×1000 for mg). Negative = deficit |
| `gap_calcium`      | float?  | g (×1000 for mg). Negative = deficit |
| `gap_vitc`         | float?  | g (×1000 for mg). Negative = deficit |
| `gap_sodium`       | float?  | g. **Positive = over 2000 mg limit (bad)** |
| `actual_energy_kcal` | float? | Actual kcal logged yesterday |
| `actual_protein`   | float?  | Actual g logged yesterday |
| *(+ all other gap\_\* and actual\_\* fields for 19 nutrients)* | | |

> **ICMR-NIN 2020 RDA Targets used by the engine**
>
> | Nutrient | Men (sedentary) | Women (sedentary) | Unit |
> |----------|----------------|-------------------|------|
> | Energy   | 2110 | 1662 | kcal |
> | Protein  | 0.83 × kg BW | 0.83 × kg BW | g |
> | Calcium  | 1000 | 1000 | mg |
> | Iron     | 19 | 29 | mg |
> | Vitamin C | 80 | 65 | mg |
> | Vitamin A | 1000 | 840 | µg |
> | Sodium   | ≤ 2000 | ≤ 2000 | mg (limit) |
>
> Activity adjusts energy (×1.0→×1.64) and protein (×1.0→×1.32). Goal adjusts energy (−300 lose / +300 gain).

---

## 10. Error Handling

All errors return JSON:

```json
{ "detail": "Human-readable message" }
```

| Code | Meaning |
|------|---------|
| `200` | Success |
| `201` | Created |
| `204` | Deleted (no body) |
| `404` | Not found |
| `422` | Validation error — bad request body |
| `500` | Server error — check `/health` |

**422 detail shape:**
```json
{
  "detail": [
    { "loc": ["body", "quantity_g"], "msg": "Field required", "type": "missing" }
  ]
}
```

---

## 11. Flutter Integration Quickstart

### pubspec.yaml

```yaml
dependencies:
  http: ^1.2.0
```

### lib/api/api_client.dart

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://100.99.105.51:8100';

  // ── Ingredients ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> searchIngredients(
    String q, {int limit = 20, int offset = 0}
  ) async {
    final uri = Uri.parse('$baseUrl/ingredients/search').replace(
      queryParameters: {'q': q, 'limit': '$limit', 'offset': '$offset'},
    );
    return _get(uri);
  }

  static Future<Map<String, dynamic>> getIngredient(String code) =>
      _get(Uri.parse('$baseUrl/ingredients/$code'));

  // ── Recipes ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getRecipes({
    String? ingredients,
    String? mealType,
    int limit = 10,
    int offset = 0,
  }) async {
    final params = <String, String>{'limit': '$limit', 'offset': '$offset'};
    if (ingredients != null) params['ingredients'] = ingredients;
    if (mealType != null) params['meal_type'] = mealType;
    return _get(Uri.parse('$baseUrl/recipes').replace(queryParameters: params));
  }

  static Future<Map<String, dynamic>> getRecipe(int id) =>
      _get(Uri.parse('$baseUrl/recipes/$id'));

  // ── Meal Log ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> logIngredient({
    required String mealType,
    required String ingredientCode,
    required double quantityG,
  }) =>
      _post('$baseUrl/meals/log', {
        'meal_type': mealType,
        'ingredient_code': ingredientCode,
        'quantity_g': quantityG,
      }, expected: 201);

  static Future<Map<String, dynamic>> logRecipe({
    required String mealType,
    required int recipeId,
    double servingsEaten = 1.0,
  }) =>
      _post('$baseUrl/meals/log', {
        'meal_type': mealType,
        'recipe_id': recipeId,
        'servings_eaten': servingsEaten,
      }, expected: 201);

  static Future<Map<String, dynamic>> getTodaySummary({String? date}) {
    final params = date != null ? {'date': date} : <String, String>{};
    return _get(Uri.parse('$baseUrl/meals/today').replace(queryParameters: params));
  }

  static Future<List<dynamic>> getMealHistory({int days = 7, String? mealType}) async {
    final params = <String, String>{'days': '$days'};
    if (mealType != null) params['meal_type'] = mealType;
    final uri = Uri.parse('$baseUrl/meals/history').replace(queryParameters: params);
    final res = await http.get(uri);
    _assertOk(res);
    return jsonDecode(res.body);
  }

  static Future<void> deleteLog(int logId) async {
    final res = await http.delete(Uri.parse('$baseUrl/meals/log/$logId'));
    if (res.statusCode != 204) throw Exception('Delete failed: ${res.statusCode}');
  }

  // ── Weight ────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> logWeight(
    double kg, {String? note}
  ) =>
      _post('$baseUrl/weight', {
        'weight_kg': kg,
        if (note != null) 'note': note,
      }, expected: 201);

  static Future<Map<String, dynamic>> getWeightHistory({int days = 90}) =>
      _get(Uri.parse('$baseUrl/weight').replace(
        queryParameters: {'days': '$days'},
      ));

  static Future<void> deleteWeight(int logId) async {
    final res = await http.delete(Uri.parse('$baseUrl/weight/$logId'));
    if (res.statusCode != 204) throw Exception('Delete failed: ${res.statusCode}');
  }

  // ── Profile ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile() =>
      _get(Uri.parse('$baseUrl/profile'));

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    _assertOk(res);
    return jsonDecode(res.body);
  }

  // ── Barcode ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> lookupBarcode(String barcode) async {
    final res = await http.get(Uri.parse('$baseUrl/barcode/$barcode'));
    if (res.statusCode == 404) return null;
    _assertOk(res);
    return jsonDecode(res.body);
  }

  // ── Recommendations ───────────────────────────────────────────
  /// Fetch today's recommendations. [forceRefresh] recomputes from scratch
  /// (call after logging a meal session).
  static Future<Map<String, dynamic>> getRecommendations({
    DateTime? date,
    bool forceRefresh = false,
  }) async {
    final params = <String, String>{
      if (date != null) 'date': date.toIso8601String().substring(0, 10),
      if (forceRefresh) 'force_refresh': 'true',
    };
    return _get(Uri.parse('$baseUrl/recommendations/today')
        .replace(queryParameters: params.isNotEmpty ? params : null));
  }

  /// Force-regenerate today's recommendations (POST version).
  static Future<Map<String, dynamic>> refreshRecommendations() async {
    final res = await http.post(Uri.parse('$baseUrl/recommendations/refresh'));
    _assertOk(res);
    return jsonDecode(res.body);
  }

  /// Fetch the nutrient gap snapshot for [date] (defaults to yesterday).
  /// Returns null if no meal data has been logged for that date yet.
  static Future<Map<String, dynamic>?> getNutrientGaps({DateTime? date}) async {
    final params = <String, String>{
      if (date != null) 'date': date.toIso8601String().substring(0, 10),
    };
    final res = await http.get(
      Uri.parse('$baseUrl/recommendations/gaps')
          .replace(queryParameters: params.isNotEmpty ? params : null),
    );
    if (res.statusCode == 404) return null;
    _assertOk(res);
    return jsonDecode(res.body);
  }

  // ── Health ────────────────────────────────────────────────────
  static Future<bool> isHealthy() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>> _get(Uri uri) async {
    final res = await http.get(uri);
    _assertOk(res);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> _post(
    String url,
    Map<String, dynamic> body, {
    int expected = 200,
  }) async {
    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    _assertOk(res, expected: expected);
    return jsonDecode(res.body);
  }

  static void _assertOk(http.Response res, {int expected = 200}) {
    if (res.statusCode != expected) {
      throw Exception('API ${res.statusCode}: ${res.body}');
    }
  }
}
```

### Replacing mock_data.dart

| Mock call | Real API call |
|-----------|---------------|
| `MockData.getIngredients(q)` | `ApiClient.searchIngredients(q)` |
| `MockData.getRecipes(type)` | `ApiClient.getRecipes(mealType: type)` |
| `MockData.getTodayLogs()` | `ApiClient.getTodaySummary()` |
| `MockData.logFood(code, g)` | `ApiClient.logIngredient(mealType: ..., ingredientCode: code, quantityG: g)` |
| `MockData.getProfile()` | `ApiClient.getProfile()` |
| `MockData.getWeightHistory()` | `ApiClient.getWeightHistory()` |
| `MockData.getRecommendations()` | `ApiClient.getRecommendations()` |
| `MockData.refreshRecs()` | `ApiClient.refreshRecommendations()` |
| `MockData.getNutrientGaps()` | `ApiClient.getNutrientGaps()` |

---

## IFCT Food Group Code Prefixes

| Prefix | Group |
|--------|-------|
| `A` | Cereals & Millets |
| `B` | Grain Legumes (Dals) |
| `C` | Green Leafy Vegetables |
| `D` | Other Vegetables |
| `E` | Fruits |
| `F` | Roots & Tubers |
| `G` | Condiments & Spices |
| `H` | Nuts & Oil Seeds |
| `I` | Sugars |
| `J` | Mushrooms |
| `K` | Milk & Milk Products |
| `L` | Eggs |
| `M` | Poultry |
| `N` | Animal Meat |
| `O` | Marine Fish |
| `P` | Edible Oils & Fats |

---

*Updated 2026-06-11 — Phase 4 Recommendations engine added. Generated from live API at http://100.99.105.51:8100/openapi.json*
