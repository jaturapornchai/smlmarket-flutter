import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/search_request.dart';
import '../models/search_response.dart';

class ProductRepository {
  static const String baseUrl = 'http://192.168.2.36:8008';
  Future<SearchResponse> searchProducts(SearchRequest request) async {
    try {
      developer.log(
        '📤 Sending request to API: $baseUrl/search',
        name: 'ProductRepository',
      );
      developer.log(
        '📝 Request payload: ${jsonEncode(request.toJson())}',
        name: 'ProductRepository',
      );

      final response = await http.post(
        Uri.parse('$baseUrl/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        developer.log(
          '✅ API response success (${response.statusCode})',
          name: 'ProductRepository',
        );
        developer.log(
          '📄 Response body length: ${response.body.length} characters',
          name: 'ProductRepository',
        );

        final jsonData = jsonDecode(response.body);
        final searchResponse = SearchResponse.fromJson(jsonData);

        return searchResponse;
      } else {
        developer.log(
          '❌ API response failed (${response.statusCode})',
          name: 'ProductRepository',
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }
}
