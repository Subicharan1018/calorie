import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  static const String baseUrl = 'http://100.99.105.51:8100';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ))..interceptors.add(PrettyDioLogger(
    requestHeader: kDebugMode,
    requestBody: kDebugMode,
    responseBody: kDebugMode,
    responseHeader: false,
    error: true,
    compact: true,
  ));

  // ── Health Check ───────────────────────────────────────────────────────────
  static Future<bool> isHealthy() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Ingredients ────────────────────────────────────────────────────────────
  static Future<List<dynamic>> searchIngredients(
    String q, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/ingredients/search',
      queryParameters: {
        'q': q,
        'limit': limit,
        'offset': offset,
      },
    );
    if (response.data is Map && response.data['results'] != null) {
      return response.data['results'] as List<dynamic>;
    }
    return [];
  }

  static Future<Map<String, dynamic>> getIngredient(String code) async {
    final response = await _dio.get('/ingredients/$code');
    return response.data as Map<String, dynamic>;
  }

  // ── Recipes ────────────────────────────────────────────────────────────────
  static Future<List<dynamic>> getRecipes({
    String? ingredients,
    String? mealType,
    int limit = 10,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (ingredients != null && ingredients.isNotEmpty) {
      params['ingredients'] = ingredients;
    }
    if (mealType != null && mealType.isNotEmpty) {
      params['meal_type'] = mealType;
    }
    final response = await _dio.get('/recipes', queryParameters: params);
    if (response.data is Map && response.data['results'] != null) {
      return response.data['results'] as List<dynamic>;
    }
    return [];
  }

  static Future<Map<String, dynamic>> getRecipe(int id) async {
    final response = await _dio.get('/recipes/$id');
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> generateRecipe(String prompt) async {
    final response = await _dio.post(
      '/recipes/generate',
      queryParameters: {'prompt': prompt},
      options: Options(
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 90),
      ),
    );
    return response.data as Map<String, dynamic>;
  }

  // ── Meal Log ───────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> logIngredient({
    required String mealType,
    required String ingredientCode,
    required double quantityG,
  }) async {
    final response = await _dio.post(
      '/meals/log',
      data: {
        'meal_type': mealType,
        'ingredient_code': ingredientCode,
        'quantity_g': quantityG,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> logRecipe({
    required String mealType,
    required int recipeId,
    double servingsEaten = 1.0,
  }) async {
    final response = await _dio.post(
      '/meals/log',
      data: {
        'meal_type': mealType,
        'recipe_id': recipeId,
        'servings_eaten': servingsEaten,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getTodaySummary({String? date}) async {
    final params = <String, dynamic>{};
    if (date != null) {
      params['date'] = date;
    }
    final response = await _dio.get('/meals/today', queryParameters: params);
    return response.data as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getMealHistory({
    int days = 7,
    String? mealType,
  }) async {
    final params = <String, dynamic>{'days': days};
    if (mealType != null) {
      params['meal_type'] = mealType;
    }
    final response = await _dio.get('/meals/history', queryParameters: params);
    return response.data as List<dynamic>;
  }

  static Future<void> deleteLog(int logId) async {
    await _dio.delete('/meals/log/$logId');
  }

  // ── Weight ─────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> logWeight(
    double kg, {
    String? note,
  }) async {
    final response = await _dio.post(
      '/weight',
      data: {
        'weight_kg': kg,
        if (note != null) 'note': note,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getWeightHistory({int days = 90}) async {
    final response = await _dio.get(
      '/weight',
      queryParameters: {'days': days},
    );
    return response.data as Map<String, dynamic>;
  }

  static Future<void> deleteWeight(int logId) async {
    await _dio.delete('/weight/$logId');
  }

  // ── Profile ────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/profile');
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/profile', data: data);
    return response.data as Map<String, dynamic>;
  }

  // ── Barcode ────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> lookupBarcode(String barcode) async {
    try {
      final response = await _dio.get('/barcode/$barcode');
      if (response.statusCode == 404) return null;
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> scanLabel(
    String filePath, {
    required String barcode,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/barcode/scan-label',
        queryParameters: {'barcode': barcode},
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 90),
          sendTimeout: const Duration(seconds: 90),
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> updateBarcodeProduct(
    String barcode,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        '/barcode/$barcode',
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }


  // ── Recommendations ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getRecommendations({
    DateTime? date,
    bool forceRefresh = false,
  }) async {
    final params = <String, dynamic>{
      if (date != null) 'date': date.toIso8601String().substring(0, 10),
      if (forceRefresh) 'force_refresh': 'true',
    };
    final response = await _dio.get(
      '/recommendations/today',
      queryParameters: params.isNotEmpty ? params : null,
    );
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> refreshRecommendations() async {
    final response = await _dio.post('/recommendations/refresh');
    return response.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>?> getNutrientGaps({DateTime? date}) async {
    final params = <String, dynamic>{
      if (date != null) 'date': date.toIso8601String().substring(0, 10),
    };
    try {
      final response = await _dio.get(
        '/recommendations/gaps',
        queryParameters: params.isNotEmpty ? params : null,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
