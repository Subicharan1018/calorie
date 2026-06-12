import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kalori/core/models/meal_log.dart';
import 'package:kalori/features/home/providers/dashboard_provider.dart';
import 'package:kalori/l10n/app_strings.dart';
import 'package:kalori/core/theme/spacing.dart';
import 'package:kalori/widgets/error_toast.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kalori/api/api_client.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeProduct {
  final String barcode;
  final String productName;
  final String brand;
  final int kcalPer100g;
  final double protein;
  final double carbs;
  final double fat;
  final String servingSize;

  const BarcodeProduct({
    required this.barcode,
    required this.productName,
    required this.brand,
    required this.kcalPer100g,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
  });

  factory BarcodeProduct.fromJson(Map<String, dynamic> json) {
    return BarcodeProduct(
      barcode: json['barcode'] as String? ?? '',
      productName: json['product_name'] as String? ?? 'Unknown Product',
      brand: json['brand'] as String? ?? '',
      kcalPer100g: ((json['energy_kcal'] as num?)?.toDouble() ?? 0.0).toInt(),
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carb'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      servingSize: json['serving_size'] as String? ?? '100g',
    );
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  late final MobileScannerController _cameraController;
  bool _isScanning = true;
  bool _isUploadingLabel = false;
  String _uploadingStatus = '';

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _scannerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        _onBarcodeDetected(code);
        break;
      }
    }
  }

  void _resumeScanning() {
    if (mounted) {
      setState(() {
        _isScanning = true;
      });
      _cameraController.start();
    }
  }

  Future<void> _pickLabelImage(ImageSource source, {required String barcode}) async {
    final s = AppStrings.of(context);
    final picker = ImagePicker();
    
    try {
      _cameraController.stop();
      setState(() {
        _isScanning = false;
      });

      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      
      if (image == null) {
        _resumeScanning();
        return;
      }

      setState(() {
        _isUploadingLabel = true;
        _uploadingStatus = s.analyzingLabel;
      });

      final apiResult = await ApiClient.scanLabel(image.path, barcode: barcode);
      
      if (apiResult != null) {
        // Fetch the updated barcode product directly from lookup cache/DB
        final lookupResult = await ApiClient.lookupBarcode(barcode);
        
        setState(() {
          _isUploadingLabel = false;
        });

        if (lookupResult != null) {
          final product = BarcodeProduct.fromJson(lookupResult);
          _showProductBottomSheet(product);
        } else {
          _showScanError(s.labelScanFailed);
        }
      } else {
        setState(() {
          _isUploadingLabel = false;
        });
        _showScanError(s.labelScanFailed);
      }
    } catch (e) {
      debugPrint('Scan label error: $e');
      setState(() {
        _isUploadingLabel = false;
      });
      _showScanError(s.labelScanFailed);
    }
  }

  void _showScanError(String message) {
    if (!mounted) return;
    ErrorToast.show(context, message);
    _resumeScanning();
  }

  void _showBarcodeNotFoundDialog(String barcode) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            icon: Icon(
              Icons.warning_amber_rounded,
              color: theme.colorScheme.error,
              size: 48,
            ),
            title: Text(
              s.productNotFound,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s.productNotFoundScanLabelPrompt,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickLabelImage(ImageSource.camera, barcode: barcode);
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: Text(s.isTamil ? 'படம் பிடி' : 'Take Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickLabelImage(ImageSource.gallery, barcode: barcode);
                  },
                  icon: Icon(Icons.photo_library, color: theme.colorScheme.secondary),
                  label: Text(
                    s.uploadLabelPhoto,
                    style: TextStyle(color: theme.colorScheme.secondary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.secondary.withValues(alpha: 0.5)),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resumeScanning();
                },
                child: Text(
                  s.tryAgain,
                  style: TextStyle(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          ),
        );
      },
    );
  }

  void _onBarcodeDetected(String barcode) async {
    if (!_isScanning) return;
    setState(() {
      _isScanning = false;
    });

    _cameraController.stop();

    await Haptics.vibrate(HapticsType.success);

    BarcodeProduct? product;

    try {
      final apiResult = await ApiClient.lookupBarcode(barcode);
      if (apiResult != null) {
        product = BarcodeProduct.fromJson(apiResult);
      }
    } catch (e) {
      debugPrint('Barcode API lookup error: $e');
    }

    if (!mounted) return;

    if (product == null) {
      _showBarcodeNotFoundDialog(barcode);
    } else {
      _showProductBottomSheet(product);
    }
  }

  void _showProductBottomSheet(BarcodeProduct product) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    
    BarcodeProduct currentProduct = product;
    MealType selectedMealType = MealType.snack;
    double quantityGrams = 100.0;

    List<dynamic> matchingIngredients = [];
    bool isLoadingMatches = true;
    Map<String, dynamic>? selectedIngredient;
    String searchError = '';
    bool hasFetched = false;
    String lastFetchedName = '';

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
            final double calculatedKcal = (currentProduct.kcalPer100g * quantityGrams) / 100;
            final double calculatedProtein = (currentProduct.protein * quantityGrams) / 100;
            final double calculatedCarbs = (currentProduct.carbs * quantityGrams) / 100;
            final double calculatedFat = (currentProduct.fat * quantityGrams) / 100;

            if (!hasFetched || lastFetchedName != currentProduct.productName) {
              hasFetched = true;
              lastFetchedName = currentProduct.productName;
              isLoadingMatches = true;
              Future.microtask(() async {
                try {
                  final name = currentProduct.productName;
                  final cleanName = name.replaceAll(RegExp(r'[^\w\s]'), '');
                  final words = cleanName.split(RegExp(r'\s+')).where((w) => w.length > 2).toList();
                  
                  List<dynamic> results = [];
                  if (words.isNotEmpty) {
                    final query = words.take(2).join(' ');
                    results = await ApiClient.searchIngredients(query);
                  }
                  
                  if (results.isEmpty && words.isNotEmpty) {
                    results = await ApiClient.searchIngredients(words.first);
                  }
                  
                  if (results.isEmpty) {
                    final queryLimit = currentProduct.productName.length > 20 ? 20 : currentProduct.productName.length;
                    results = await ApiClient.searchIngredients(currentProduct.productName.substring(0, queryLimit));
                  }
                  
                  if (context.mounted) {
                    setModalState(() {
                      matchingIngredients = results;
                      isLoadingMatches = false;
                      if (results.isNotEmpty) {
                        selectedIngredient = results.first as Map<String, dynamic>;
                      } else {
                        selectedIngredient = null;
                      }
                    });
                  }
                } catch (e) {
                  if (context.mounted) {
                    setModalState(() {
                      isLoadingMatches = false;
                      searchError = e.toString();
                    });
                  }
                }
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.md,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: SingleChildScrollView(
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
                                currentProduct.productName,
                                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${currentProduct.brand} · Barcode: ${currentProduct.barcode}',
                                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    onPressed: () {
                                      _showEditProductDialog(
                                        context,
                                        currentProduct,
                                        (updated) {
                                          setModalState(() {
                                            currentProduct = updated;
                                          });
                                        },
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
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

                    Text(
                      s.isTamil ? 'உணவுத் தரவுத்தளத்துடன் இணைக்கவும்' : 'Map to Database Food',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      s.isTamil 
                          ? 'கலோரிகளை கணக்கிட இதற்கேற்ற பொதுவான உணவை தேர்வு செய்யவும்' 
                          : 'Select the generic food equivalent from the database for accurate tracking.',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (isLoadingMatches)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else ...[
                      if (matchingIngredients.isNotEmpty) ...[
                        DropdownButtonFormField<String>(
                          initialValue: selectedIngredient?['code'] as String?,
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainer,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.button),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          ),
                          items: matchingIngredients.map<DropdownMenuItem<String>>((item) {
                            final name = item['name'] as String? ?? '';
                            final code = item['code'] as String? ?? '';
                            return DropdownMenuItem<String>(
                              value: code,
                              child: Text(
                                '$name ($code)',
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: (code) {
                            setModalState(() {
                              selectedIngredient = matchingIngredients.firstWhere((item) => item['code'] == code);
                            });
                          },
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ] else ...[
                        Text(
                          s.isTamil ? 'பொருந்தும் உணவு எதுவும் கிடைக்கவில்லை. கைமுறையாகத் தேடவும்.' : 'No matching database ingredients found. Please search manually.',
                          style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      if (searchError.isNotEmpty) ...[
                        Text(
                          searchError,
                          style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      TextField(
                        decoration: InputDecoration(
                          hintText: s.isTamil ? 'தரவுத்தளத்தில் தேடவும்...' : 'Search database to map manually...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHigh,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.button),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        ),
                        onSubmitted: (query) async {
                          final trimmed = query.trim();
                          if (trimmed.isEmpty) return;
                          setModalState(() {
                            isLoadingMatches = true;
                          });
                          try {
                            final results = await ApiClient.searchIngredients(trimmed);
                            setModalState(() {
                              matchingIngredients = results;
                              isLoadingMatches = false;
                              if (results.isNotEmpty) {
                                selectedIngredient = results.first as Map<String, dynamic>;
                              } else {
                                selectedIngredient = null;
                              }
                            });
                          } catch (e) {
                            setModalState(() {
                              isLoadingMatches = false;
                              searchError = e.toString();
                            });
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),

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

                    Consumer(
                      builder: (context, ref, child) {
                        return AppLogButton(
                          onPressed: selectedIngredient == null
                              ? null
                              : () async {
                                  await Haptics.vibrate(HapticsType.medium);
                                  final code = selectedIngredient!['code'] as String;
                                  
                                  try {
                                    await ApiClient.logIngredient(
                                      mealType: selectedMealType.name,
                                      ingredientCode: code,
                                      quantityG: quantityGrams,
                                    );

                                    ref.invalidate(dashboardProvider);

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      context.go('/home');
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error logging product: $e')),
                                      );
                                    }
                                  }
                                },
                          label: s.logProduct,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          _isScanning = true;
        });
        _cameraController.start();
      }
    });
  }

  void _showEditProductDialog(
    BuildContext context,
    BarcodeProduct product,
    Function(BarcodeProduct) onSaved,
  ) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: product.productName);
    final brandController = TextEditingController(text: product.brand);
    final kcalController = TextEditingController(text: product.kcalPer100g.toString());
    final proteinController = TextEditingController(text: product.protein.toString());
    final carbsController = TextEditingController(text: product.carbs.toString());
    final fatController = TextEditingController(text: product.fat.toString());
    final servingController = TextEditingController(text: product.servingSize);

    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                backgroundColor: theme.colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                title: Text(
                  s.isTamil ? 'தயாரிப்பு விவரங்களை திருத்து' : 'Edit Product Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: s.isTamil ? 'பெயர்' : 'Product Name',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return s.isTamil ? 'பெயர் தேவை' : 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: brandController,
                          decoration: InputDecoration(
                            labelText: s.isTamil ? 'பிராண்ட்' : 'Brand',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: kcalController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'kcal/100g',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) {
                                  if (val == null || double.tryParse(val) == null) {
                                    return s.isTamil ? 'தவறான எண்' : 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: TextFormField(
                                controller: servingController,
                                decoration: InputDecoration(
                                  labelText: s.isTamil ? 'பரிமாறும் அளவு' : 'Serving Size',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: carbsController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: s.isTamil ? 'கார்ப்ஸ் (g)' : 'Carbs (g)',
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (val) {
                                  if (val == null || double.tryParse(val) == null) {
                                    return s.isTamil ? 'தவறான எண்' : 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: TextFormField(
                                controller: proteinController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: s.isTamil ? 'புரதம் (g)' : 'Protein (g)',
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (val) {
                                  if (val == null || double.tryParse(val) == null) {
                                    return s.isTamil ? 'தவறான எண்' : 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: TextFormField(
                                controller: fatController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: s.isTamil ? 'கொழுப்பு (g)' : 'Fat (g)',
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (val) {
                                  if (val == null || double.tryParse(val) == null) {
                                    return s.isTamil ? 'தவறான எண்' : 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                    child: Text(
                      s.isTamil ? 'ரத்துசெய்' : 'Cancel',
                      style: TextStyle(color: theme.colorScheme.outline),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (formKey.currentState?.validate() ?? false) {
                              setState(() {
                                isSaving = true;
                              });

                              final updatedData = {
                                'product_name': nameController.text.trim(),
                                'brand': brandController.text.trim(),
                                'energy_kcal': double.parse(kcalController.text),
                                'carb': double.parse(carbsController.text),
                                'protein': double.parse(proteinController.text),
                                'fat': double.parse(fatController.text),
                                'serving_size': servingController.text.trim(),
                              };

                              try {
                                final res = await ApiClient.updateBarcodeProduct(
                                  product.barcode,
                                  updatedData,
                                );
                                if (res != null) {
                                  final updatedProduct = BarcodeProduct.fromJson(res);
                                  await Haptics.vibrate(HapticsType.success);
                                  onSaved(updatedProduct);
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              } catch (e) {
                                debugPrint('Save product error: $e');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error updating: $e')),
                                  );
                                }
                              } finally {
                                if (context.mounted) {
                                  setState(() {
                                    isSaving = false;
                                  });
                                }
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(s.isTamil ? 'சேமி' : 'Save'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
          Positioned.fill(
            child: MobileScanner(
              controller: _cameraController,
              onDetect: _onDetect,
            ),
          ),

          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: CustomPaint(
                painter: _CameraGridPainter(),
              ),
            ),
          ),

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

          // Glassmorphic Analyzing / Loading Overlay
          if (_isUploadingLabel)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                              border: Border.all(
                                color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                                strokeWidth: 3,
                              ),
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                           .scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 1500.ms, curve: Curves.easeInOut)
                           .then()
                           .scale(begin: const Offset(1.08, 1.08), end: const Offset(1, 1), duration: 1500.ms, curve: Curves.easeInOut),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            _uploadingStatus,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                           .shimmer(duration: 2.seconds, color: theme.colorScheme.secondary.withValues(alpha: 0.5)),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            s.isTamil 
                                ? 'AI கொண்டு ஊட்டச்சத்தை கணக்கிடுகிறது (சில வினாடிகள் ஆகலாம்)' 
                                : 'Analyzing label with AI (may take a few seconds)',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppLogButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;

  const AppLogButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  State<AppLogButton> createState() => _AppLogButtonState();
}

class _AppLogButtonState extends State<AppLogButton> {
  bool _isLogging = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (!isEnabled || _isLogging)
            ? null
            : () async {
                setState(() {
                  _isLogging = true;
                });
                widget.onPressed!();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
        child: _isLogging
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                widget.label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
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
