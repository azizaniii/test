import 'package:hive_flutter/hive_flutter.dart';

/// Nama-nama box Hive yang digunakan dalam aplikasi
class HiveBoxes {
  static const String aiCacheBox = 'ai_cache_box';
  static const String appSettingsBox = 'app_settings_box';
  static const String syncQueueBox = 'sync_queue_box';

  /// Inisialisasi semua Hive boxes
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters jika diperlukan (untuk custom objects)
    // Hive.registerAdapter(YourCustomAdapter());

    // Buka semua boxes
    await Hive.openBox(aiCacheBox);
    await Hive.openBox(appSettingsBox);
    await Hive.openBox(syncQueueBox);
  }

  /// Mendapatkan box AI cache
  static Box get aiCache => Hive.box(aiCacheBox);

  /// Mendapatkan box app settings
  static Box get appSettings => Hive.box(appSettingsBox);

  /// Mendapatkan box sync queue
  static Box get syncQueue => Hive.box(syncQueueBox);
}

/// Model untuk cache jawaban AI
class AiCacheEntry {
  final String question;
  final String answer;
  final String sourceProvider;
  final DateTime timestamp;

  AiCacheEntry({
    required this.question,
    required this.answer,
    required this.sourceProvider,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'source_provider': sourceProvider,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AiCacheEntry.fromJson(Map<String, dynamic> json) {
    return AiCacheEntry(
      question: json['question'] as String,
      answer: json['answer'] as String,
      sourceProvider: json['source_provider'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
