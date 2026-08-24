import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'app_database.dart';

/// Database accessor untuk Drift
@DriftDatabase(tables: [
  KbliTable,
  KbjiTable,
  InaCbgTariffTable,
  PerdaRuleTable,
  SyncQueueTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Query pencarian KBLI dengan full-text search
  Future<List<KbliEntry>> searchKbli(String query) async {
    final searchTerm = '%${query.toLowerCase()}%';
    return (select(kbliTable)
          ..where((tbl) => tbl.kode.lower().like(searchTerm) |
              tbl.judul.lower().like(searchTerm) |
              tbl.deskripsi.lower().like(searchTerm)))
        .get();
  }

  /// Query pencarian KBJI dengan full-text search
  Future<List<KbjiEntry>> searchKbji(String query) async {
    final searchTerm = '%${query.toLowerCase()}%';
    return (select(kbjiTable)
          ..where((tbl) => tbl.kode.lower().like(searchTerm) |
              tbl.judul.lower().like(searchTerm) |
              tbl.deskripsi.lower().like(searchTerm)))
        .get();
  }

  /// Mendapatkan tarif INA-CBG berdasarkan kode diagnosa dan kelas
  Future<InaCbgTariff?> getInaCbgTariff(
      String kodeDiagnosa, String jenisLayanan) async {
    return (select(inacbgTariffTable)
          ..where((tbl) => tbl.kodeDiagnosa.equals(kodeDiagnosa) &
              tbl.jenisLayanan.equals(jenisLayanan)))
        .getSingleOrNull();
  }

  /// Mendapatkan aturan Perda
  Future<List<PerdaRule>> getPerdaRules() async {
    return select(perdaRuleTable).get();
  }

  /// Menambahkan item ke antrian sinkronisasi
  Future<void> addToSyncQueue({
    required String id,
    required String collectionTarget,
    required Map<String, dynamic> payload,
  }) async {
    await into(syncQueueTable).insert(SyncQueueItemCompanion.insert(
      id: id,
      collectionTarget: collectionTarget,
      payloadJson: payload.toString(), // TODO: gunakan JSON encode yang proper
      status: 'pending',
      createdAt: DateTime.now(),
    ));
  }

  /// Mendapatkan item yang pending untuk disinkronkan
  Future<List<SyncQueueItem>> getPendingSyncItems() async {
    return (select(syncQueueTable)..where((tbl) => tbl.status.equals('pending')))
        .get();
  }

  /// Update status sync item
  Future<void> updateSyncStatus(String id, String status, {String? errorMessage}) async {
    await update(syncQueueTable).replace(SyncQueueItemCompanion(
      id: Value(id),
      status: Value(status),
      errorMessage: Value(errorMessage),
      retryCount: Value.absent(),
    ));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'bps_lu.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
