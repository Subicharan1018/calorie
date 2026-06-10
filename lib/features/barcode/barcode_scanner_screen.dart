import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:kalori/core/models/meal_log.dart';
import 'package:kalori/features/home/providers/dashboard_provider.dart';
import 'package:kalori/mock/mock_data.dart';
import 'package:kalori/l10n/app_strings.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/widgets/error_toast.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onSimulateScan(String barcode) async {
    if (!_isScanning) return;
    setState(() {
      _isScanning = false;
    });

    await Haptics.vibrate(HapticsType.success);

    // Look up barcode in mock database
    final product = mockBarcodeProducts.firstWhere(
      (p) => p.barcode == barcode,
      orElse: () => const BarcodeProduct(
        barcode: '',
        productName: '',
        brand: '',
        kcalPer100g: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        servingSize: '',
      ),
    );

    if (!mounted) return;

    if (product.barcode.isEmpty) {
      // Show error toast
      final s = AppStrings.of(context);
      ErrorToast.show(context, s.productNotFound);
      setState(() {
        _isScanning = true;
      });
    } else {
      _showProductBottomSheet(product);
    }
  }

  void _showProductBottomSheet(BarcodeProduct product) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    
    // Default meal type and quantity state
    MealType selectedMealType = MealType.snack;
    double quantityGrams = 100.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double calculatedKcal = (product.kcalPer100g * quantityGrams) / 100;
            final double calculatedProtein = (product.protein * quantityGrams) / 100;
            final double calculatedCarbs = (product.carbs * quantityGrams) / 100;
            final double calculatedFat = (product.fat * quantityGrams) / 100;

            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.md,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${product.brand} · Barcode: ${product.barcode}',
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: Text(
                          '${calculatedKcal.toInt()} kcal',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.xl),
                  
                  // Macro Splits Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MacroBlock(
                        label: s.carbs,
                        value: '${calculatedCarbs.toStringAsFixed(1)}g',
                        color: theme.colorScheme.primary,
                      ),
                      _MacroBlock(
                        label: s.protein,
                        value: '${calculatedProtein.toStringAsFixed(1)}g',
                        color: theme.colorScheme.secondary,
                      ),
                      _MacroBlock(
                        label: s.fat,
                        value: '${calculatedFat.toStringAsFixed(1)}g',
                        color: const Color(0xFFD47A22),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Meal Type Selection Chips
                  Text(
                    s.isTamil ? 'உணவு வகை' : 'Select Meal Type',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: MealType.values.map((type) {
                      final isSelected = selectedMealType == type;
                      return ChoiceChip(
                        label: Text(_getMealTypeName(type, s)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => selectedMealType = type);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Quantity Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.isTamil ? 'அளவு (கிராம்)' : 'Quantity (grams)',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${quantityGrams.toInt()} g',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: quantityGrams,
                    min: 10,
                    max: 500,
                    divisions: 49,
                    label: '${quantityGrams.toInt()}g',
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: theme.colorScheme.surfaceContainerHighest,
                    onChanged: (val) {
                      setModalState(() => quantityGrams = val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Log Button
                  Consumer(
                    builder: (context, ref, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Haptics.vibrate(HapticsType.medium);
                            
                            // Map product brand & name to Tamil dynamically if required
                            String tamilName = product.productName;
                            if (product.barcode == '8901499000040') {
                              tamilName = 'ஆசீர்வாத் மல்டிகிரைன் ஆட்டா';
                            } else if (product.barcode == '8901262010191') {
                              tamilName = 'அமுல் வெண்ணெய்';
                            } else if (product.barcode == '8901719101046') {
                              tamilName = 'பிரிட்டானியா மேரி கோல்ட்';
                            }

                            final mealLog = MealLog(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              recipeName: product.productName,
                              tamilName: tamilName,
                              quantityGrams: quantityGrams.toInt(),
                              kcal: calculatedKcal.toInt(),
                              proteinG: calculatedProtein,
                              carbsG: calculatedCarbs,
                              fatG: calculatedFat,
                              mealType: selectedMealType,
                            );

                            ref.read(dashboardProvider.notifier).addMeal(mealLog);
                            
                            if (context.mounted) {
                              Navigator.pop(context); // Close bottom sheet
                              context.go('/home'); // Go to Home
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.button),
                            ),
                          ),
                          child: Text(
                            s.logProduct,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      // Re-enable scanning when sheet is dismissed without logging
      if (mounted) {
        setState(() {
          _isScanning = true;
        });
      }
    });
  }

  String _getMealTypeName(MealType type, AppStrings s) {
    switch (type) {
      case MealType.breakfast:
        return s.breakfast.split(' · ').first;
      case MealType.lunch:
        return s.lunch.split(' · ').first;
      case MealType.snack:
        return s.snack.split(' · ').first;
      case MealType.dinner:
        return s.dinner.split(' · ').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          s.barcodeScannerTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Simulated camera viewfinder background grid
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: CustomPaint(
                painter: _CameraGridPainter(),
              ),
            ),
          ),

          // Central text
          Positioned(
            top: 40,
            child: Text(
              _isScanning ? s.pointCamera : s.scanningProduct,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 0.5,
              ),
            ).animate().fade(),
          ),

          // Viewfinder center target
          Center(
            child: Container(
              width: 260,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Viewfinder corners (L-brackets)
                  Positioned(
                    top: 0, left: 0,
                    child: _CornerBracket(isTop: true, isLeft: true, color: theme.colorScheme.secondary),
                  ),
                  Positioned(
                    top: 0, right: 0,
                    child: _CornerBracket(isTop: true, isLeft: false, color: theme.colorScheme.secondary),
                  ),
                  Positioned(
                    bottom: 0, left: 0,
                    child: _CornerBracket(isTop: false, isLeft: true, color: theme.colorScheme.secondary),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: _CornerBracket(isTop: false, isLeft: false, color: theme.colorScheme.secondary),
                  ),

                  // Horizontal animated laser scanning line
                  if (_isScanning)
                    AnimatedBuilder(
                      animation: _scannerController,
                      builder: (context, child) {
                        return Positioned(
                          top: _scannerController.value * 170 + 5,
                          left: 10,
                          right: 10,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.secondary.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // Simulation Control Buttons at bottom
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s.isTamil ? 'மாதிரி ஸ்கேன் சோதிக்க:' : 'Simulate Scanning Packaged Product:',
                  style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _SimulateButton(
                      label: s.isTamil ? 'ஆட்டா' : 'Atta',
                      onPressed: () => _onSimulateScan('8901499000040'),
                    ),
                    _SimulateButton(
                      label: s.isTamil ? 'வெண்ணெய்' : 'Butter',
                      onPressed: () => _onSimulateScan('8901262010191'),
                    ),
                    _SimulateButton(
                      label: s.isTamil ? 'பிஸ்கட்' : 'Biscuit',
                      onPressed: () => _onSimulateScan('8901719101046'),
                    ),
                    _SimulateButton(
                      label: s.isTamil ? 'தவறான பொருள்' : 'Invalid',
                      onPressed: () => _onSimulateScan('0000000000000'),
                      color: theme.colorScheme.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroBlock({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final bool isTop;
  final bool isLeft;
  final Color color;

  const _CornerBracket({
    required this.isTop,
    required this.isLeft,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const double length = 20.0;
    const double thickness = 4.0;
    
    return SizedBox(
      width: length,
      height: length,
      child: Stack(
        children: [
          // Horizontal leg
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: 0,
            right: 0,
            child: Container(
              height: thickness,
              color: color,
            ),
          ),
          // Vertical leg
          Positioned(
            top: 0,
            bottom: 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(
              width: thickness,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimulateButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _SimulateButton({
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.secondary;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor.withValues(alpha: 0.2),
        foregroundColor: buttonColor,
        side: BorderSide(color: buttonColor),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _CameraGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    const int cols = 5;
    const int rows = 5;

    final double colStep = size.width / cols;
    final double rowStep = size.height / rows;

    for (int i = 1; i < cols; i++) {
      canvas.drawLine(Offset(colStep * i, 0), Offset(colStep * i, size.height), paint);
    }
    for (int i = 1; i < rows; i++) {
      canvas.drawLine(Offset(0, rowStep * i), Offset(size.width, rowStep * i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
