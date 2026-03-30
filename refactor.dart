import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    // Skip the new entities
    if (file.path.endsWith('task_entity.dart') || file.path.endsWith('quadrant_type.dart')) continue;
    
    var content = file.readAsStringSync();
    final original = content;
    
    // Replace imports
    content = content.replaceAll('entities/task.dart', 'entities/task_entity.dart');
    
    // Replace class names (case-sensitive, whole word)
    content = content.replaceAll(RegExp(r'\bTask\b'), 'TaskEntity');
    content = content.replaceAll(RegExp(r'\bQuadrant\b'), 'QuadrantType');
    
    if (content != original) {
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
