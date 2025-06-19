import 'lib/services/database_service.dart';

void main() async {
  final db = DatabaseService();
  try {
    final result = await db.getTableFields('cart_items');
    print('cart_items fields:');
    for (var field in result['fields']) {
      print(
        '  ${field['column_name']}: ${field['data_type']} ${field['is_nullable'] == 'YES' ? 'NULL' : 'NOT NULL'}',
      );
    }
  } catch (e) {
    print('Error: $e');
  }
}
