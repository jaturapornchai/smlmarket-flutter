import 'lib/services/database_service.dart';

void main() async {
  final db = DatabaseService();
  final result = await db.getTableFields('carts');
  print('Carts table fields:');
  for (var field in result['fields']) {
    print('${field['column_name']}: ${field['data_type']}');
  }
}
