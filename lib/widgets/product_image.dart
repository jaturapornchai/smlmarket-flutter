import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/image_url_helper.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? placeholder;

  const ProductImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });
  @override
  Widget build(BuildContext context) {
    // If imageUrl is empty, null, or invalid, show placeholder with icon
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFC0C0C0), Color(0xFFE5E5E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1F000000), // Colors.black.withOpacity(0.12)
              blurRadius: 2,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: const Color(0x0F000000), // Colors.black.withOpacity(0.06)
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: const Color(0x80FFFFFF),
            width: 1.5,
          ), // Colors.white.withOpacity(0.5)
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0x1AFFFFFF),
                      Colors.transparent,
                    ], // Colors.white.withOpacity(0.1)
                  ),
                ),
              ),
            ),
            Center(
              child: Icon(
                Icons.inventory_outlined,
                color: Colors.white,
                size: (width != null && width! > 0) ? width! * 0.4 : 40,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1F000000), // Colors.black.withOpacity(0.12)
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: const Color(0x0F000000), // Colors.black.withOpacity(0.06)
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0x66FFFFFF),
          width: 1.5,
        ), // Colors.white.withOpacity(0.4)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            // Use Image.network with error handling for web compatibility
            _buildNetworkImage(),
            // Subtle gradient overlay for better contrast
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0x05000000), // Colors.black.withOpacity(0.02)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkImage() {
    // Debug logging for web image issues
    debugPrint('🖼️ Original image URL: $imageUrl');

    // Normalize and validate the image URL
    final normalizedUrl = ImageUrlHelper.normalizeImageUrl(imageUrl);
    final isValidUrl = ImageUrlHelper.isValidImageUrl(normalizedUrl);

    debugPrint('🖼️ Normalized image URL: $normalizedUrl');
    debugPrint('🖼️ Is valid URL: $isValidUrl');

    // Check if URL is valid
    if (!isValidUrl || normalizedUrl.isEmpty) {
      return _buildPlaceholder('Invalid URL');
    }
    // Use CachedNetworkImage for better web compatibility
    return CachedNetworkImage(
      imageUrl: normalizedUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildLoadingPlaceholder(),
      errorWidget: (context, url, error) {
        // Enhanced error logging for debugging
        debugPrint('🖼️ CachedNetworkImage error for URL: $url');
        debugPrint('🚨 Error: $error');
        debugPrint('🔍 Error Type: ${error.runtimeType}');

        return _buildPlaceholder('Load failed');
      }, // Simple headers for web compatibility
      httpHeaders: kIsWeb
          ? {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Accept': 'image/*,*/*;q=0.8',
            }
          : null,
      // Add fadeIn animation
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFC0C0C0), Color(0xFFE5E5E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(11)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String reason) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFC0C0C0), Color(0xFFE5E5E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(11)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_outlined,
            color: Colors.white,
            size: (width != null && width! > 0) ? width! * 0.3 : 30,
          ),
          if (kIsWeb) ...[
            const SizedBox(height: 4),
            Text(
              'Image not\navailable',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
              ),
            ),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                '($reason)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 8,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
