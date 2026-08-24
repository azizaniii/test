/// Konstanta aplikasi
class AppConstants {
  // Nama aplikasi
  static const String appName = 'BPS Lombok Utara';

  // Collection Firestore
  static const String usersCollection = 'users';
  static const String surveiSakernasCollection = 'survei_sakernas';
  static const String surveiSusenasCollection = 'survei_susenas';
  static const String laporanPerjalananCollection = 'laporan_perjalanan';
  static const String masterKbliCollection = 'master_kbli';
  static const String masterKbjiCollection = 'master_kbji';
  static const String masterInaCbgCollection = 'master_ina_cbg';
  static const String masterPerdaCollection = 'master_perda';

  // Roles
  static const String roleAdminKantor = 'admin_kantor';
  static const String rolePetugasLapangan = 'petugas_lapangan';

  // Sync status
  static const String syncStatusPending = 'pending';
  static const String syncStatusSyncing = 'syncing';
  static const String syncStatusSuccess = 'success';
  static const String syncStatusFailed = 'failed';

  // Settings keys
  static const String settingLastSyncTime = 'last_sync_time';
  static const String settingAutoBackupEnabled = 'auto_backup_enabled';

  // OCR settings
  static const int maxOcrBatchSize = 50;
  static const double imageCompressionQuality = 0.7; // 70% quality
  static const int maxImageSizeKb = 500; // 500 KB

  // AI settings
  static const int aiCacheExpiryHours = 24;
  static const int aiDailyLimitPerUser = 100;
}
