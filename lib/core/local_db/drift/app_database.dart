import 'package:drift/drift.dart';

/// Tabel KBLI (Klasifikasi Baku Lapangan Usaha Indonesia)
@DataClassName(name: 'KbliEntry')
class KbliTable extends Table {
  @PrimaryKey()
  TextColumn get kode => text()();

  TextColumn get judul => text()();

  TextColumn get deskripsi => text()();

  TextColumn get kategori => text().nullable()();

  /// Index untuk full-text search
  @Index(indexName: 'idx_kbli_kode_judul')
  Index get idxKbliSearch => Index(columns: [kode, judul]);
}

/// Tabel KBJI (Klasifikasi Baku Jabatan Indonesia)
@DataClassName(name: 'KbjiEntry')
class KbjiTable extends Table {
  @PrimaryKey()
  TextColumn get kode => text()();

  TextColumn get judul => text()();

  TextColumn get deskripsi => text()();

  @Index(indexName: 'idx_kbji_kode_judul')
  Index get idxKbjiSearch => Index(columns: [kode, judul]);
}

/// Tabel Tarif INA-CBG untuk estimasi biaya BPJS
@DataClassName(name: 'InaCbgTariff')
class InaCbgTariffTable extends Table {
  @PrimaryKey()
  TextColumn get kodeDiagnosa => text()();

  IntColumn get kelas1 => integer()();

  IntColumn get kelas2 => integer()();

  IntColumn get kelas3 => integer()();

  TextColumn get jenisLayanan => text()(); // rawat_jalan | rawat_inap

  DateTimeColumn get berlakuDari => dateTime()();

  @Index(indexName: 'idx_inacbg_kode')
  Index get idxKodeDiagnosa => Index(columns: [kodeDiagnosa]);
}

/// Tabel Peraturan Daerah (Perda) untuk aturan tambahan
@DataClassName(name: 'PerdaRule')
class PerdaRuleTable extends Table {
  @PrimaryKey()
  @InsertMode(onConflict: OnConflictStrategy.replace)
  TextColumn get id => text()();

  TextColumn get nomorPerda => text()();

  TextColumn get deskripsi => text()();

  TextColumn get ruleJson => text()(); // JSON string berisi rule/nominal

  DateTimeColumn get berlakuDari => dateTime()();
}

/// Tabel antrian sinkronisasi ke Firestore
@DataClassName(name: 'SyncQueueItem')
class SyncQueueTable extends Table {
  @PrimaryKey()
  @InsertMode(onConflict: OnConflictStrategy.replace)
  TextColumn get id => text()();

  TextColumn get collectionTarget => text()(); // nama collection Firestore

  TextColumn get payloadJson => text()(); // JSON string data yang akan disinkronkan

  TextColumn get status => text()(); // pending | syncing | success | failed

  DateTimeColumn get createdAt => dateTime()();

  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  TextColumn get errorMessage => text().nullable()();

  @Index(indexName: 'idx_sync_status')
  Index get idxStatus => Index(columns: [status]);
}
