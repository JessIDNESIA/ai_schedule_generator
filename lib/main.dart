import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart'; // untuk kReleaseMode
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'config/api_config.dart';
import 'config/app_theme.dart';
import 'features/home/presentation/providers/theme_provider.dart';
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

  // Initialize ThemeProvider
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: DevicePreview(
        enabled: !kReleaseMode, // mati otomatis saat build release
        defaultDevice: Devices.ios.iPhone11ProMax,
        devices: [
          Devices.ios.iPhone11ProMax,
          // Devices.android.samsungGalaxyS23Ultra,
          Devices.ios.iPadPro11Inches,
        ],
        builder: (context) => const MainApp(),
      ),
    ),
  );
}

// Root Widget aplikasi dengan Theme support
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          locale: DevicePreview.locale(context), // Menyesuaikan locale preview
          builder: DevicePreview.appBuilder, // Builder untuk integrasi DevicePreview

          debugShowCheckedModeBanner: false, // Menghilangkan banner debug
          title: 'AI Schedule Generator', // Judul aplikasi

          // Apply theme based on provider
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          home: const HomeScreen(), // Halaman pertama saat aplikasi dibuka
        );
      },
    );
  }
}