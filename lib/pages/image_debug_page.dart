import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/product_image.dart';
import '../services/cloudinary_service.dart';

class ImageDebugPage extends StatelessWidget {
  const ImageDebugPage({super.key});
  @override
  Widget build(BuildContext context) {
    const testImageUrl =
        "https://f.ptcdn.info/468/065/000/pw5l8933TR0cL0CH7f-o.jpg";

    final proxyImageUrl = CloudinaryService.getImageProxyUrl(testImageUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Debug Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Testing Image Loading with API Proxy:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            Text(
              'Original URL: $testImageUrl',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),

            Text(
              'API Proxy URL: $proxyImageUrl',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            // Test 1: Our custom ProductImage widget
            const Text('1. ProductImage Widget (300x300):'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const ProductImage(
                imageUrl: testImageUrl,
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24), // Test 2: Direct Image.network
            const Text('2. Direct Image.network (300x300):'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  testImageUrl,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Direct Image.network error: $error');
                    return const Icon(Icons.error);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Test 3: CachedNetworkImage
            const Text('3. CachedNetworkImage (300x300):'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: testImageUrl,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) {
                    debugPrint('CachedNetworkImage error: $error');
                    return const Icon(Icons.error);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Test 4: Direct API Proxy URL
            const Text('4. Direct API Proxy URL (300x300):'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: proxyImageUrl,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) {
                    debugPrint('API Proxy CachedNetworkImage error: $error');
                    return const Icon(Icons.error);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Back to Search'),
            ),
          ],
        ),
      ),
    );
  }
}
