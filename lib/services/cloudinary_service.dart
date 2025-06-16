import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../global.dart' as global;

class CloudinaryService {
  static const String _cloudName = 'demo'; // ชั่วคราวสำหรับทดสอบ
  static const String _uploadPreset = 'ml_default'; // ชั่วคราวสำหรับทดสอบ

  static final CloudinaryPublic _cloudinary = CloudinaryPublic(
    _cloudName,
    _uploadPreset,
    cache: false,
  );

  /// Transform image URL to use Cloudinary optimizations
  static String transformImageUrl(
    String originalUrl, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    try {
      // If it's already a Cloudinary URL, return as is
      if (originalUrl.contains('cloudinary.com')) {
        return originalUrl;
      } // For external URLs, use Cloudinary fetch to proxy and optimize
      String transformations = '';

      // Validate width and height values
      if (width != null && width > 0 && width <= 5000) {
        if (height != null && height > 0 && height <= 5000) {
          transformations += 'c_fill,w_$width,h_$height,';
        } else {
          transformations += 'w_$width,';
        }
      } else if (height != null && height > 0 && height <= 5000) {
        transformations += 'h_$height,';
      }

      transformations += 'q_$quality,f_$format';

      // Use Cloudinary's fetch feature to proxy external images
      final encodedUrl = Uri.encodeComponent(originalUrl);
      return 'https://res.cloudinary.com/$_cloudName/image/fetch/$transformations/$encodedUrl';
    } catch (e) {
      debugPrint('❌ Error transforming image URL: $e');
      return originalUrl;
    }
  }

  // Get Image Proxy URL
  static String getImageProxyUrl(String originalUrl) {
    return '${global.apiBaseUrl()}/imgproxy?url=${Uri.encodeComponent(originalUrl)}';
  }

  /// Get optimized image URL for web using API proxy
  static String getWebOptimizedUrl(
    String originalUrl, {
    int? width,
    int? height,
  }) {
    // Use API proxy for all platforms to ensure consistent image loading
    final proxyUrl = getImageProxyUrl(originalUrl);
    debugPrint('🖼️ Using API proxy for image URL: $proxyUrl');
    return proxyUrl;
  }

  // Get Tables
  static Future<List<dynamic>?> getTables() async {
    try {
      final response = await http.get(
        Uri.parse('${global.apiBaseUrl()}/api/tables'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get tables error: $e');
      return null;
    }
  }

  /// Get thumbnail URL using API proxy
  static String getThumbnailUrl(String originalUrl, {int size = 150}) {
    return getImageProxyUrl(originalUrl);
  }

  /// Upload image to Cloudinary (for future use)
  static Future<CloudinaryResponse?> uploadImage({
    required String imagePath,
    String? folder,
    Map<String, String>? tags,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imagePath,
          folder: folder,
          tags: tags?.values.toList(),
        ),
      );

      debugPrint('✅ Image uploaded to Cloudinary: ${response.secureUrl}');
      return response;
    } catch (e) {
      debugPrint('❌ Error uploading image to Cloudinary: $e');
      return null;
    }
  }
}
