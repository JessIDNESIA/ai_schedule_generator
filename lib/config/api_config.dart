import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konfigurasi API untuk aplikasi
/// Handles loading API keys dari .env file secara aman
class ApiConfig {
  static late String geminiApiKey;

  /// Initialize configurasi API pada startup
  /// Wajib dipanggil sebelum menggunakan API services
  static Future<void> initialize() async {
    try {
      // Load dari .env file
      geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

      // Validasi API key
      if (geminiApiKey.isEmpty) {
        throw ApiConfigException(
          'GEMINI_API_KEY tidak ditemukan di .env file. '
          'Pastikan file .env sudah ada dan berisi GEMINI_API_KEY',
        );
      }

      // Optional: Validate format (should start with AIza)
      if (!geminiApiKey.startsWith('AIza')) {
        throw ApiConfigException(
          'GEMINI_API_KEY format tidak valid. '
          'Key harus dimulai dengan "AIza"',
        );
      }
    } catch (e) {
      throw ApiConfigException('Gagal initialize API config: $e');
    }
  }

  /// Reset untuk testing purposes
  static void reset() {
    geminiApiKey = '';
  }

  /// Check if API is configured
  static bool isConfigured() {
    return geminiApiKey.isNotEmpty;
  }
}

/// Custom exception untuk API configuration errors
class ApiConfigException implements Exception {
  final String message;

  ApiConfigException(this.message);

  @override
  String toString() => message;
}
