import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'base_url.dart';

class CategoryService {
  static  String baseUrl = BaseUrl.getUrl();

  static Future<List<Map<String, dynamic>>> getUserCategories() async {
    final token = localStorage.getItem('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/Categories/MyCategories'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final categoriesData = jsonDecode(response.body) as List<dynamic>;
      List<Map<String, dynamic>> categories = [];
      
      for (var categoryData in categoriesData) {
        categories.add({
          'id': categoryData['id'],
          'name': categoryData['name'],
          'userId': categoryData['userId'],
        });
      }
      
      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<Map<String, dynamic>> createCategory({
    required String name,
  }) async {
    final token = localStorage.getItem('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final categoryData = {
      'name': name,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/Categories'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(categoryData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'id': data['id'],
        'name': data['name'],
        'userId': data['userId'],
      };
    } else {
      // Try to extract error message from response body
      String errorMessage = 'Failed to create category';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is Map && errorData.containsKey('title')) {
          errorMessage = errorData['title'];
        } else if (errorData is String) {
          errorMessage = errorData;
        } else {
          errorMessage = response.body;
        }
      } catch (e) {
        errorMessage = response.body.isNotEmpty ? response.body : 'Unknown error';
      }
      throw Exception(errorMessage);
    }
  }

  static Future<void> deleteCategory(int categoryId) async {
    final token = localStorage.getItem('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/api/Categories/$categoryId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete category');
    }
  }
}
