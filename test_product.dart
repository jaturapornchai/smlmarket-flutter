import 'dart:convert';
import 'lib/models/search_response.dart';

void main() {
  // Test JSON response structure
  const sampleJson = '''
{
  "success": true,
  "message": "Search completed successfully",
  "data": {
    "data": [
      {
        "id": "07-1151",
        "name": "น่ารัก 300มล./แชมพูเด็ก/สีชมพู",
        "similarity_score": 1.0,
        "code": "07-1151",
        "balance_qty": -1,
        "price": 100,
        "supplier_code": "",
        "unit": "ชิ้น",
        "img_url": "",
        "search_priority": 1
      }
    ],
    "total_count": 1,
    "query": "07-1151",
    "duration_ms": 724.27
  }
}
''';

  try {
    final jsonData = jsonDecode(sampleJson);
    final response = SearchResponse.fromJson(jsonData);
    print('✅ Parsing successful!');
    print('Success: ${response.success}');
    print('Message: ${response.message}');
    print('Total count: ${response.data?.totalCount ?? 0}');
    print('Query: ${response.data?.query ?? "N/A"}');
    print('Duration: ${response.data?.durationMs ?? 0.0}ms');

    if (response.data?.data?.isNotEmpty == true) {
      final product = response.data!.data!.first;
      print('\\nProduct details:');
      print('ID: ${product.id}');
      print('Name: ${product.name}');
      print('Code: ${product.code}');
      print('Price: ${product.price}');
      print('Balance: ${product.balanceQty}');
      print('Unit: ${product.unit}');
      print('Priority: ${product.searchPriority}');
      print('Similarity: ${product.similarityScore}');

      // Test backward compatibility
      print('\\nBackward compatibility:');
      print('Metadata code: ${product.metadata.code}');
      print('Metadata price: ${product.metadata.price}');
    } else {
      print('\\nNo products found in response');
    }
  } catch (e) {
    print('❌ Error parsing JSON: $e');
  }
}
