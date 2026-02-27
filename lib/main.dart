import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart'; // untuk kReleaseMode
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/api_config.dart';
import 'ui/home_screen.dart';

void main() async {
  // Pastikan Flutter binding sudah initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file (hanya di development, akan diabaikan di production)
  await dotenv.load(fileName: '.env');

  // Initialize API config (load API key dari .env)
  try {
    await ApiConfig.initialize();
  } catch (e) {
    // Log error tapi jangan crash app - akan trigger error saat AI digunakan
    debugPrint('⚠️ API Config Error: $e');
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // mati otomatis saat build release
      defaultDevice: Devices.ios.iPhone11ProMax,
      devices: [
        Devices.ios.iPhone11ProMax,
        // Devices.android.samsungGalaxyS23Ultra,
        Devices.ios.iPadPro11Inches,
      ],
      builder: (context) => const MainApp(),
    ),
  );
}

// Root Widget aplikasi
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      locale: DevicePreview.locale(context), // Menyesuaikan locale preview
      builder:
          DevicePreview.appBuilder, // Builder untuk integrasi DevicePreview

      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      title: 'AI Schedule Generator', // Judul aplikasi

      theme: ThemeData(
        // Konfigurasi tema global aplikasi
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo, // Warna utama aplikasi
          brightness: Brightness.light,
        ),
        useMaterial3: true, // Menggunakan Material Design 3
        scaffoldBackgroundColor: Colors.grey[50], // Warna background utama
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      home: const HomeScreen(), // Halaman pertama saat aplikasi dibuka
    );
  }
}