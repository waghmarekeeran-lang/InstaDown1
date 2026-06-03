import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const _box = 'instadown_v1';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_box);
  }

  Box<Map> get _b => Hive.box<Map>(_box);

  Future<void> save({
    required String id,
    required String title,
    required String source,
    required String date,
    required String thumbnailUrl,
    required String filePath,
  }) async {
    await _b.put(id, {
      'id': id, 'title': title, 'source': source,
      'date': date, 'thumbnailUrl': thumbnailUrl,
      'filePath': filePath,
      'savedAt': DateTime.now().toIso8601String(),
    });
  }

  List<Map<String, dynamic>> all() {
    final list = _b.values
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
    list.sort((a, b) =>
        (b['savedAt'] as String).compareTo(a['savedAt'] as String));
    return list;
  }

  Future<void> delete(String id) => _b.delete(id);
  Future<void> clear()            => _b.clear();
}
