import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class SMLGOAPIService {
  static const String baseUrl = 'http://localhost:8008';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Model classes
  static Future<List<LocationData>> findByZipcode(int zipCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get/findbyzipcode'),
      headers: headers,
      body: jsonEncode({'zip_code': zipCode}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((item) => LocationData.fromJson(item))
            .toList();
      } else {
        throw Exception(data['error'] ?? 'API Error');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  static Future<List<Province>> getProvinces() async {
    final response = await http.post(
      Uri.parse('$baseUrl/get/provinces'),
      headers: headers,
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((item) => Province.fromJson(item))
            .toList();
      } else {
        throw Exception(data['error'] ?? 'API Error');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  static Future<List<Amphure>> getAmphures(int provinceId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get/amphures'),
      headers: headers,
      body: jsonEncode({'province_id': provinceId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((item) => Amphure.fromJson(item))
            .toList();
      } else {
        throw Exception(data['error'] ?? 'API Error');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  static Future<List<Tambon>> getTambons(int amphureId, int provinceId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get/tambons'),
      headers: headers,
      body: jsonEncode({'amphure_id': amphureId, 'province_id': provinceId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((item) => Tambon.fromJson(item))
            .toList();
      } else {
        throw Exception(data['error'] ?? 'API Error');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  // Product Search
  static Future<List<Map<String, dynamic>>> searchProducts({
    required String query,
    int limit = 10,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/search'),
      headers: headers,
      body: jsonEncode({'query': query, 'limit': limit}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return List<Map<String, dynamic>>.from(data['data']['data'] ?? []);
      } else {
        throw Exception(data['error'] ?? 'Search failed');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  // Database Operations
  static Future<List<Map<String, dynamic>>> executeSelect(String query) async {
    final response = await http.post(
      Uri.parse('$baseUrl/select'),
      headers: headers,
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception(data['error'] ?? 'Query failed');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> executeCommand(String query) async {
    final response = await http.post(
      Uri.parse('$baseUrl/command'),
      headers: headers,
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['result'];
      } else {
        throw Exception(data['error'] ?? 'Command failed');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  static Future<List<String>> getTables() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/tables'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((item) => item['name'] as String)
            .toList();
      } else {
        throw Exception(data['error'] ?? 'Failed to get tables');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  // Health Check
  static Future<Map<String, dynamic>> checkHealth() async {
    final response = await http.get(
      Uri.parse('$baseUrl/health'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Health check failed: ${response.statusCode}');
    }
  }

  // Image Proxy
  static String getProxyImageUrl(String originalUrl) {
    final encodedUrl = Uri.encodeComponent(originalUrl);
    return '$baseUrl/imgproxy?url=$encodedUrl';
  }
}

// Model classes
class Province {
  final int id;
  final String nameTh;
  final String nameEn;

  Province({required this.id, required this.nameTh, required this.nameEn});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'],
      nameTh: json['name_th'],
      nameEn: json['name_en'],
    );
  }
}

class Amphure {
  final int id;
  final String nameTh;
  final String nameEn;

  Amphure({required this.id, required this.nameTh, required this.nameEn});

  factory Amphure.fromJson(Map<String, dynamic> json) {
    return Amphure(
      id: json['id'],
      nameTh: json['name_th'],
      nameEn: json['name_en'],
    );
  }
}

class Tambon {
  final int id;
  final String nameTh;
  final String nameEn;
  final int zipCode;

  Tambon({
    required this.id,
    required this.nameTh,
    required this.nameEn,
    required this.zipCode,
  });

  factory Tambon.fromJson(Map<String, dynamic> json) {
    return Tambon(
      id: json['id'],
      nameTh: json['name_th'],
      nameEn: json['name_en'],
      zipCode: json['zip_code'],
    );
  }
}

class LocationData {
  final Province province;
  final Amphure amphure;
  final Tambon tambon;

  LocationData({
    required this.province,
    required this.amphure,
    required this.tambon,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      province: Province.fromJson(json['province']),
      amphure: Amphure.fromJson(json['amphure']),
      tambon: Tambon.fromJson(json['tambon']),
    );
  }
}

// Error Handling
class APIException implements Exception {
  final String message;
  final int? statusCode;

  APIException(this.message, [this.statusCode]);

  @override
  String toString() => 'APIException: $message (Code: $statusCode)';
}

// Wrapper for all API calls
Future<T> handleAPICall<T>(Future<T> Function() apiCall) async {
  try {
    return await apiCall();
  } on SocketException {
    throw APIException('No internet connection');
  } on TimeoutException {
    throw APIException('Request timeout');
  } on FormatException {
    throw APIException('Invalid response format');
  } catch (e) {
    throw APIException('Unknown error: $e');
  }
}

// Loading State Management
class LoadingState<T> {
  final bool isLoading;
  final T? data;
  final String? error;

  const LoadingState({this.isLoading = false, this.data, this.error});

  LoadingState<T> loading() => LoadingState(isLoading: true);
  LoadingState<T> success(T data) => LoadingState(data: data);
  LoadingState<T> failure(String error) => LoadingState(error: error);
}
