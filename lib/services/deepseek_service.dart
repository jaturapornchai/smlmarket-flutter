// ห้าม AI เข้ามาแก้ไขโค้ดนี้

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class DeepSeekService {
  static const String apiKey = 'sk-f57e7b56ab3f4f1a8030b7ae57500b85';
  static const String apiUrl = 'https://api.deepseek.com/v1/chat/completions';
  Future<String> enhanceSearchQuery(String originalQuery) async {
    final stopwatch = Stopwatch()..start();
    developer.log(
      '🤖 Starting DeepSeek query enhancement for: "$originalQuery"',
      name: 'DeepSeekService',
    );

    try {
      developer.log(
        '📤 Sending request to DeepSeek API',
        name: 'DeepSeekService',
      );

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': '''
คุณเป็นผู้ช่วยที่เชี่ยวชาญในการปรับปรุงข้อความค้นหา
ถ้าเป็น barcode หรือ รหัส หรือ หมายเลข ให้ส่งคืนข้อความเดิม
ถ้าไม่ใช่ ให้ปรับปรุงข้อความค้นหาให้มีคำหลักที่เกี่ยวข้องมากขึ้น
เปลี่ยนข้อความต้นฉบับให้เป็นข้อความค้นหาที่มีคำหลักที่เกี่ยวข้องมากขึ้น
Example:
Input: "toyota"
Output: toyota โตโยต้า
Input: "brake pad"
Output: ผ้าเบรค''',
            },
            {'role': 'user', 'content': originalQuery},
          ],
          'max_tokens': 100,
          'temperature': 0.3,
        }),
      );

      stopwatch.stop();
      developer.log(
        '⏱️ DeepSeek API response time: ${stopwatch.elapsedMilliseconds}ms',
        name: 'DeepSeekService',
      );

      if (response.statusCode == 200) {
        developer.log(
          '✅ DeepSeek API success (${response.statusCode})',
          name: 'DeepSeekService',
        );

        final jsonData = jsonDecode(response.body);
        final enhancedQuery =
            jsonData['choices'][0]['message']['content']?.trim() ??
            originalQuery;

        if (originalQuery == enhancedQuery) {
          developer.log(
            '🔄 No enhancement needed, returning original query',
            name: 'DeepSeekService',
          );
          return originalQuery;
        } else {
          final finalQuery = "$originalQuery $enhancedQuery";
          developer.log(
            '✨ Query enhanced: "$originalQuery" → "$finalQuery"',
            name: 'DeepSeekService',
          );
          return finalQuery;
        }
      } else {
        developer.log(
          '❌ DeepSeek API error: ${response.statusCode}',
          name: 'DeepSeekService',
          error: response.body,
        );
        return originalQuery; // Return original query if API fails
      }
    } catch (e) {
      stopwatch.stop();
      developer.log(
        '💥 DeepSeek service error after ${stopwatch.elapsedMilliseconds}ms',
        name: 'DeepSeekService',
        error: e,
        stackTrace: StackTrace.current,
      );
      return originalQuery; // Return original query if service fails
    }
  }
}
