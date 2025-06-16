class ImageUrlHelper {
  static String normalizeImageUrl(String? imageUrl, {String? baseUrl}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }

    // If already absolute URL, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // If data URL (base64), return as is
    if (imageUrl.startsWith('data:')) {
      return imageUrl;
    }

    // If relative path and we have a base URL, combine them
    if (baseUrl != null && baseUrl.isNotEmpty) {
      // Remove trailing slash from base URL
      final cleanBaseUrl = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;

      // Add leading slash to image URL if needed
      final cleanImageUrl = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';

      return '$cleanBaseUrl$cleanImageUrl';
    }
    // If no base URL provided, try common patterns
    // For Shopee-style marketplace, assume it might be from common CDNs
    if (imageUrl.startsWith('/')) {
      // You might want to configure this based on your API
      return 'https:$imageUrl'; // For protocol-relative URLs
    }

    // If it looks like a relative URL without protocol, try adding https
    if (!imageUrl.contains('://') && imageUrl.contains('.')) {
      return 'https://$imageUrl';
    }

    // Return original if nothing else works
    return imageUrl;
  }

  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }

    // Check if it's a valid HTTP/HTTPS URL
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' ||
              uri.scheme == 'https' ||
              uri.scheme == 'data');
    } catch (e) {
      return false;
    }
  }
}
