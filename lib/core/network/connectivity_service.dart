import 'package:connectivity_plus/connectivity_plus.dart';

/// Service untuk mengecek status konektivitas internet
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Stream yang emit status koneksi
  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((results) {
      // Check if any of the results indicate a connection
      return results.any((result) => 
        result != ConnectivityResult.none,
      );
    });
  }

  /// Cek apakah device online sekarang
  Future<bool> isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (e) {
      // Jika error, asumsikan offline untuk safety
      return false;
    }
  }

  /// Cek apakah device offline
  Future<bool> isOffline() async {
    return !(await isOnline());
  }
}
