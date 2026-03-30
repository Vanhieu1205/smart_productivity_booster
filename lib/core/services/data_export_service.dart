import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DataExportService {
  /// Xuất toàn bộ Task từ Hive ra một chuỗi JSON
  static Future<String> exportDataToJson() async {
    try {
      if (!Hive.isBoxOpen('tasks')) {
        await Hive.openBox('tasks');
      }
      final box = Hive.box('tasks');
      final allData = box.values.toList();
      
      // Chuyển Hive object thành Map (cần gọi toJson từ Model, hoặc decode dynamic)
      final List<Map<String, dynamic>> jsonData = allData.map((e) {
        // e is TaskModel
        // Hive object can be converted to JSON if we call its custom method,
        // Assuming we have toMap/toJson inside Model.
        // If not accessible natively here, we convert manually or rely on dynamic.
        // For safety, we try dynamic casting if 'toJson' is defined
        try {
          return (e as dynamic).toJson() as Map<String, dynamic>;
        } catch (_) {
          // Fallback if toJson is missing
          return {'id': 'error', 'data': e.toString()};
        }
      }).toList();

      return jsonEncode({'tasks': jsonData, 'exportDate': DateTime.now().toIso8601String()});
    } catch (e) {
      rethrow;
    }
  }

  /// Xuất file json và mở cửa sổ share cho người dùng
  static Future<void> exportAndShareData() async {
    try {
      final jsonString = await exportDataToJson();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/smart_productivity_backup.json');
      await file.writeAsString(jsonString);

      // Mở hộp thoại share hệ thống
      await Share.shareXFiles([XFile(file.path)], text: 'Dữ liệu sao lưu Smart Productivity Booster');
    } catch (e) {
      throw Exception('Không thể xuất dữ liệu: $e');
    }
  }
}
