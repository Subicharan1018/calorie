# gemini.md — South Indian Calorie Deficit Tracker
## Flutter Frontend Design Brief

---

> **Skill Chain**: `taste-skill` → `impeccable` → `skillui`
> Run `/impeccable init` in your AI harness before generating any screen.
> Color tokens, typography scale, and surface hierarchy are resolved at runtime by the installed skills. Do NOT hardcode any palette here.

---

## 1. App Identity

| Key | Value |
|-----|-------|
| **App name** | Kalori (கலோரி) |
| **Platform target** | Android-first Flutter (API 26+), Material 3 |
| **App category** | Premium Health & Nutrition |
| **Cultural root** | South Indian (Tamil Nadu focus) — Tamil + English bilingual |
| **User persona** | Urban Tamil adult, 25–45, health-aware, uses smartphone daily |
| **Emotional goal** | Feel like a personal nutritionist lives in the phone |

---

## 2. Skill Invocation Order

When Gemini generates any screen or widget, apply skills in this order:

```
1. taste-skill     → judges whether the aesthetic direction is culturally resonant,
                     non-generic, and premium. Rejects "health app blue" defaults.

2. impeccable      → enforces pixel-perfect spacing, elevation hierarchy,
                     consistent border radius, shadow depth, and motion curves.
                     Run `/impeccable init` once at session start.

3. skillui         → generates the actual Flutter widget tree from the approved
                     aesthetic. Handles component variants, states, and accessibility.
```

> If any skill produces a conflict, `taste-skill` has final say on aesthetic; `impeccable` has final say on execution quality.

---

## 3. Design Constraints (Skills Provide the Rest)

### 3.1 What Gemini Must NOT decide
- Color palette (taste-skill owns this)
- Font selection (taste-skill owns this)
- Shadow/elevation values (impeccable owns this)
- Border radius scale (impeccable owns this)
- Component state variants (skillui owns this)

### 3.2 What Gemini MUST decide (layout & structure)
- Screen information architecture
- Navigation pattern
- Widget composition hierarchy
- Scroll behavior
- Data-empty states
- Loading skeleton shapes

---

## 4. Navigation Architecture

```
Root
 └── BottomNavigationBar (4 tabs, no labels — icons only, premium feel)
      ├── Tab 0: Home (Dashboard)
      ├── Tab 1: Log (Vegetable → Recipe → Meal Log)
      ├── Tab 2: Trends (Charts + Weight)
      └── Tab 3: Profile (TDEE + Settings)

Modals (full-screen or 80% sheet):
  • Recipe Detail Sheet
  • Add Meal Quantity Sheet
  • Weight Log Entry Sheet
  • Onboarding Flow (replaces nav on first launch)

No drawer. No top hamburger. Premium apps use bottom nav or gestures.
```

---

## 5. Screen Inventory & Layout Specs

### 5.1 Splash Screen
```
Layout   : Full screen, centered
Content  : App wordmark "Kalori" + Tamil subtitle "கலோரி கண்காணிப்பு"
Animation: Wordmark fades in with a subtle scale (0.92 → 1.0), 400ms ease-out
           Then dissolves into Onboarding or Home
Duration : 1800ms total
No logo  : Typography-only. No food icon clichés.
```

### 5.2 Onboarding (3 Slides — First Launch Only)
```
Slide 1 — "Your vegetables. Your recipes."
  Illustration: Abstract grid of vegetable silhouettes (drumstick, banana flower,
                raw banana, ash gourd — South Indian specific)
  Headline    : Large, 2 lines max
  Subtext     : 1 short paragraph

Slide 2 — "Calories from your own kitchen."
  Illustration: A stylised brass serving bowl (urli) from above
  Content     : Highlight ICMR-NIN data source credibility

Slide 3 — "Set your target. We track the rest."
  Illustration: Deficit ring preview (the chart from Home)
  CTA         : "Let's set up your profile" → goes to Setup

Progress: Dot indicators, bottom-right corner
Skip    : Ghost text button, top-right, "Skip setup"
```

### 5.3 Profile Setup (One-time, scrollable single screen)
```
Fields (in order, each as a styled card/section):
  1. Name (text field, optional)
  2. Gender (segmented control: Male / Female / Other)
  3. Age (number wheel picker)
  4. Height (cm — number picker with unit toggle cm/ft)
  5. Weight (kg — number picker)
  6. Activity Level (5-option horizontal chip row):
     Sedentary · Light · Moderate · Active · Very Active
  7. Goal (3-option card selector):
     Lose 0.5 kg/week · Lose 0.25 kg/week · Maintain
  8. Deficit target (auto-calculated, shown as read-only callout):
     "Your daily target: XXXX kcal (deficit: −500 kcal)"

CTA: Floating "Save & Continue" button pinned to bottom
```

### 5.4 Home — Dashboard (Primary screen)
```
Layout: Single scroll (no tabs inside Home)

Section A — Hero Deficit Ring (top 40% of viewport)
  • CustomPainter arc ring showing calories consumed vs target
  • Center: Remaining kcal (large numeral) + "remaining" label
  • Ring has 3 arc segments: Carbs / Protein / Fat (macro split)
  • Below ring: 3 mini stat chips — Protein Xg · Carbs Xg · Fat Xg
  • Today's date, Tamil weekday name in small text above ring

Section B — Meal Log Summary (card list)
  • Today's logged meals grouped by meal type:
    Breakfast · Lunch · Snack · Dinner
  • Each group: meal type label + total kcal for that group
  • Each meal row: recipe/ingredient name · quantity · kcal · delete swipe
  • Empty state: "Tap + to log your first meal today"

Section C — Quick Actions (horizontal scroll chips)
  • "Add Breakfast" / "Add Lunch" / "Add Snack" / "Add Dinner"
  • These chips jump directly to Log tab pre-selected meal type

Section D — Micronutrient Snapshot (collapsible)
  • Iron · Calcium · Vitamin C · Fibre — progress bars
  • % of daily requirement met
  • Collapsed by default, tap to expand

FAB: Circular "+" button, bottom-right, opens Add Meal flow
```

### 5.5 Log Tab — Vegetable Input Screen
```
Purpose: User picks vegetables they have → gets recipe suggestions

Layout:
  Header: "What vegetables do you have?"
          Sub: "We'll find South Indian recipes that match"

  Search Bar (sticky top):
    • Real-time search hits /ingredients/search?q=
    • Searches both English and Tamil names
    • Tamil name shown as secondary line in results
    • Debounce: 300ms

  Selected Vegetables Section:
    • Horizontal chip row of selected items
    • Each chip: vegetable name + × to remove
    • Empty state: "Search and add vegetables above"

  Search Results List:
    • Row: [Category icon] · [English name] · [Tamil name] · [kcal/100g]
    • Tap to add to selected chips
    • Categories: Leafy Green · Root · Gourd · Legume · Grain

  Sticky Bottom Bar:
    • Shows count: "3 vegetables selected"
    • CTA button: "Find Recipes →"
    • Disabled state when 0 selected

Transitions:
  • Chip add: scale-in from search result position
  • Chip remove: scale-out + collapse
```

### 5.6 Recipe Suggestions Screen
```
Triggered by: "Find Recipes →" from Vegetable Input

Header: "Recipes for your vegetables" + match count
        "Showing 6 recipes · 2 from AI suggestions"

Layout: Vertical card list (NOT a grid — calorie data needs space)

Recipe Card anatomy:
  ┌─────────────────────────────────────────────────────┐
  │  [Category badge]  [AI badge if AI-generated]       │
  │                                                     │
  │  Recipe Name (English)          [Total kcal large]  │
  │  Tamil name in smaller text                         │
  │                                                     │
  │  Protein · Carbs · Fat  (3 small coloured dots)     │
  │                                                     │
  │  Matched vegetables: [chip] [chip] [chip]           │
  │                                     [Log Meal →]   │
  └─────────────────────────────────────────────────────┘

Loading state: 
  • If hitting AI: "Asking AI for recipes…" skeleton with shimmer
  • Estimated wait indicator (3–8 seconds)
  • Already-cached: instant, no loader

Empty state:
  • "No recipes found — AI is generating new ones"
  • Animated progress indicator

Sort options (top-right): Lowest Cal · Best Protein · Best Match
```

### 5.7 Recipe Detail Bottom Sheet (80% height)
```
Triggered by: Tapping a recipe card

Content (scrollable):
  1. Recipe name (large) + Tamil name
  2. Serving size selector (100g / 150g / 200g / 250g — stepper)
  3. Macro breakdown: 4 large stats — Calories · Protein · Carbs · Fat
  4. Full ICMR nutrition table (collapsible):
     Iron · Calcium · Phosphorus · Vitamin C · Thiamin · Riboflavin
     Fibre · Zinc · Folate — shown as labelled progress bars vs daily RDA
  5. Ingredient list (with proportional quantities)
  6. Source badge: "ICMR-NIN verified" or "AI-generated, verify before use"

Bottom action:
  [Log This Meal] button — full width, prominent
  Opens quantity confirmation sheet on top of this one
```

### 5.8 Meal Log Quantity Sheet (40% height)
```
Triggered by: "Log This Meal" from Recipe Detail

Content:
  Recipe name (small, top)
  Quantity slider: 50g – 500g (snaps to 25g increments)
  Live preview: "Logging 200g = 312 kcal · 8g protein"
  Meal type selector: Breakfast · Lunch · Snack · Dinner
  [Confirm Log] button

Dismissal: swipe down or tap outside
On confirm: optimistic UI update on Home ring + success haptic
```

### 5.9 Trends Tab
```
Layout: Scrollable, two main sections

Section A — Calorie Trend (7-day bar chart)
  • X: Mon–Sun labels
  • Y: kcal consumed
  • Target line: dashed horizontal at TDEE – deficit
  • Bar colour: green if under target, amber if 0–10% over, red if >10% over
  • Tap a bar: tooltip with that day's total + deficit/surplus

Section B — Weight Progress
  • Line chart: last 30 data points
  • Dot at each logged weight
  • Trend line (linear regression)
  • Goal weight shown as dashed line
  • Below chart: "Lost 1.2 kg in 14 days" stat card (or gained/maintained)

FAB: "Log Weight" — opens weight entry sheet
```

### 5.10 Weight Log Sheet (40% height)
```
Content:
  Today's date label
  Large number input: weight in kg (decimal)
  "Last logged: 72.4 kg (3 days ago)"
  [Save Weight] button
```

### 5.11 Profile Tab
```
Layout: Scrollable settings list (SliverAppBar collapses into title)

Section: Your Stats
  • Name / Gender / Age (tap to edit inline)
  • Height · Current Weight (auto-filled from latest weight log)
  • TDEE: Xkcal/day (tap to recalculate)
  • Daily deficit target: −Xkcal

Section: Activity Level
  • 5-option segmented card (same as setup)
  • Changing this recalculates TDEE live

Section: Nutrition Goals
  • Deficit amount: −250 / −500 kcal (radio)
  • Macros split: Auto (40C/30P/30F) or Custom sliders

Section: App
  • Dark / Light / System theme toggle
  • Language: English / தமிழ் (Tamil)
  • Export data (CSV)
  • About
```

---

## 6. Motion & Interaction Guidelines

```
General:
  All transitions: 280ms, Curves.easeOutCubic (no bouncy springs)
  Page transitions: shared-axis Z (zoom) between tabs, shared-axis X within flows

Specific:
  Deficit ring: AnimatedBuilder on a Tween<double> over 800ms on page load
  Number counters: CountUpAnimation, 600ms, ease-out
  Meal log chip add: scale 0→1, 180ms
  Meal log chip remove: scale 1→0, 120ms + 80ms collapse
  Recipe card appear: staggered FadeSlideIn, 40ms between each card
  Bottom sheets: standard Material 3 sheet curve
  Success haptic: HapticFeedback.mediumImpact() on meal log confirm
  Error haptic: HapticFeedback.vibrate() on validation fail
```

---

## 7. Empty States — All screens

```
Pattern for all empty states:
  1. Illustration: simple line-art (NOT a generic sad face)
     Each empty state gets a culturally specific illustration:
     - No meals logged: empty brass thali from above
     - No weight logs: an empty measuring tape
     - No recipes: empty kolam grid
  2. Headline: 1 line, action-oriented
  3. Sub: 1 sentence
  4. CTA button where applicable
```

---

## 8. Loading States

```
Type A — Skeleton (list/card loaders):
  shimmerColors from impeccable skill
  Match exact card shape geometry

Type B — Progress (AI recipe generation):
  Linear progress bar at top of screen
  Status text: "Asking AI…" → "Parsing recipes…" → "Done"

Type C — Spinner (quick operations like log save):
  Small CircularProgressIndicator inside button, replaces button text
  Button width remains fixed (no layout shift)
```

---

## 9. Error States

```
Network error:  Inline banner (NOT a blocking dialog)
                "Can't reach server · Check your Tailscale connection"
                Retry button on right

API error:      Toast at bottom, 4s auto-dismiss

Validation:     Inline under field, shake animation on field

Empty search:   "No results for 'X' in English or Tamil
                 Try searching by the vegetable's common name"
```

---

## 10. Accessibility

```
- Minimum touch target: 48×48dp (impeccable enforces this)
- All icons have Semantics labels in both English and Tamil
- Color is never the ONLY indicator (shapes/icons also used)
- Screen reader order: logical top-to-bottom, left-to-right
- Dynamic text scaling: layout tested at 1.0× and 1.3× font scale
- Contrast: AA minimum (impeccable enforces this against the skill's palette)
```

---

## 11. Flutter Widget Structure Reference

```dart
// Top-level widget map (structure only — no styling here, skills own that)

MaterialApp
  └── GoRouter
       ├── /splash          → SplashScreen
       ├── /onboarding      → OnboardingFlow (PageView, 3 pages)
       ├── /setup           → ProfileSetupScreen
       └── /home            → MainShell (ScaffoldWithNavBar)
            ├── HomeTab     → DashboardScreen
            │    ├── DeficitRingWidget (CustomPainter)
            │    ├── MealLogSummaryList
            │    └── MicronutrientSnapshot (ExpansionTile)
            ├── LogTab      → VegetableInputScreen
            │    └── RecipeSuggestionsScreen
            │         └── RecipeDetailSheet (modal)
            │              └── MealLogQuantitySheet (modal)
            ├── TrendsTab   → TrendsScreen
            │    ├── CalorieTrendChart (fl_chart BarChart)
            │    └── WeightProgressChart (fl_chart LineChart)
            └── ProfileTab  → ProfileScreen
```

---

## 12. Key Packages (UI-relevant only)

```yaml
# pubspec.yaml — UI packages only
dependencies:
  flutter_riverpod: ^2.5.1      # State management
  go_router: ^13.2.0            # Navigation
  fl_chart: ^0.68.0             # Deficit ring + charts
  flutter_animate: ^4.5.0       # Declarative animations
  shimmer: ^3.0.0               # Skeleton loaders
  gap: ^3.0.1                   # Consistent spacing
  google_fonts: ^6.2.1          # Premium typography (taste-skill selects the font)
  lottie: ^3.1.0                # Splash / onboarding illustrations
  haptic_feedback: ^0.5.1       # Tactile responses
  skeletonizer: ^1.3.0          # Skeleton shimmer for lists
```

---

## 13. Gemini Prompt Template (per screen)

When generating each screen, Gemini should follow this prompt structure:

```
[SCREEN: <name>]
[SKILLS: taste-skill, impeccable, skillui]
[CONSTRAINTS: see gemini.md §3.2]
[LAYOUT SPEC: see gemini.md §5.<n>]

Generate the Flutter widget for <ScreenName>.
- Apply taste-skill for aesthetic direction
- Apply impeccable for spacing, elevation, radius
- Apply skillui for component variants and states
- Do NOT hardcode any color value — use Theme.of(context) tokens only
- Widget must be stateless where possible, StatefulWidget only if animation requires
- Include empty state, loading state, and error state
- Add Semantics widgets for accessibility
- Use const constructors wherever possible
```

---

## 14. Cultural Authenticity Checklist

Gemini must verify each screen passes these before finalising:

- [ ] Tamil names appear alongside English everywhere (ingredient names, day labels)
- [ ] Food categories use South Indian taxonomy (not Western "Vegetables / Proteins")
- [ ] Recipe names are correct Tamil culinary terms (sambar, kootu, poriyal, rasam, kuzhambu, pachadi)
- [ ] Unit is grams (not cups/oz)
- [ ] Meal type labels reflect South Indian meal culture:
      Kaalaai Saapadu (Breakfast) · Madiyam Saapadu (Lunch) ·
      Maaalai Tiffin (Evening Snack) · Iravu Saapadu (Dinner)
      Show both Tamil + English
- [ ] ICMR-NIN attribution appears on every nutrition display (small badge/footnote)
- [ ] "Murungakkai", "Vazhakkai", "Avarakkai" etc. spelled correctly in Tamil