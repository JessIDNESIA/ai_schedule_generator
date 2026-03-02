import 'dart:convert'; // Untuk encode/decode JSON
import 'package:http/http.dart' as http;
import '../config/api_config.dart'; // Secure API key dari .env

class GeminiService {
  // API Key diload dari ApiConfig (aman, tidak hardcoded)

  // Gunakan model stabil terbaru (per 2026: gemini-1.5-flash atau gemini-1.5-flash-latest)
  static const String model =
      "gemini-flash-latest"; // atau "gemini-1.5-flash-latest"

  // Endpoint Gemini API (generateContent)
  static const String baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent";

  static Future<String> generateSchedule(
    List<Map<String, dynamic>> tasks,
  ) async {
    try {
      // Validasi API key sudah ter-initialize
      if (!ApiConfig.isConfigured()) {
        throw Exception(
          'API key belum di-initialize. Hubungi ApiConfig.initialize() di main.dart',
        );
      }

      // Bangun prompt dari data tugas
      final prompt = _buildPrompt(tasks);

      // Siapkan URL dengan API key dari ApiConfig
      final url = Uri.parse('$baseUrl?key=${ApiConfig.geminiApiKey}');

      // Body request sesuai spec resmi Gemini
      final requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
        // Maximize tokens for a full day 24h schedule + detailed notes
        "generationConfig": {
          "temperature": 0.8, // Slightly higher for better variety in routine tasks
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 4096,
        },
      };

      // Kirim POST request
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      // Handle response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["candidates"] != null &&
            data["candidates"].isNotEmpty &&
            data["candidates"][0]["content"] != null &&
            data["candidates"][0]["content"]["parts"] != null &&
            data["candidates"][0]["content"]["parts"].isNotEmpty) {
          return data["candidates"][0]["content"]["parts"][0]["text"] as String;
        }
        return "Tidak ada jadwal yang dihasilkan dari AI.";
      } else {
        print(
          "API Error - Status: ${response.statusCode}, Body: ${response.body}",
        );
        if (response.statusCode == 429) {
          throw Exception(
            "Rate limit tercapai (429). Tunggu beberapa menit atau upgrade quota.",
          );
        }
        if (response.statusCode == 401) {
          throw Exception("API key tidak valid (401). Periksa key Anda.");
        }
        if (response.statusCode == 400) {
          throw Exception("Request salah format (400): ${response.body}");
        }
        throw Exception(
          "Gagal memanggil Gemini API (Code: ${response.statusCode})",
        );
      }
    } catch (e) {
      print("Exception saat generate schedule: $e");
      throw Exception("Error saat generate jadwal: $e");
    }
  }

  static String _buildPrompt(List<Map<String, dynamic>> tasks) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln(
      "Sebagai AI Perencana Jadwal Profesional, buatkan jadwal harian yang LOGIS, PRODUKTIF, dan LENGKAP 24 JAM (00:00 - 23:59).",
    );
    buffer.writeln("\nDAFTAR TUGAS UTAMA (WAJIB dimasukkan di jam produktif):");
    for (var task in tasks) {
      buffer.writeln(
        "- ${task['name']} (Prioritas: ${task['priority']}, Durasi: ${task['duration']} menit)",
      );
    }
    buffer.writeln(
      "\nATURAN OUTPUT (WAJIB PATUH):"
      "\n1. FORMAT TABEL: Gunakan Tabel Markdown dengan kolom: Waktu (Mulai - Selesai), Kegiatan, Prioritas, Durasi, dan Keterangan."
      "\n2. DURASI 24 JAM: Mulailah dari bangun pagi (sekitar 04:00/05:00) hingga tidur kembali. Masukkan kegiatan rutin (makan, ibadah, mandi, istirahat, hobi, santai) secara detail agar jadwal penuh 24 jam."
      "\n3. TUGAS UTAMA: Prioritas 'Tinggi' harus mendapat waktu terbaik."
      "\n4. CATATAN TAMBAHAN: Di bawah tabel, WAJIB tambahkan section '### 💡 Catatan Tambahan' yang berisi tips sukses hari ini dan kata-kata motivasi."
      "\n5. BAHASA: Gunakan Bahasa Indonesia yang sopan dan profesional.",
    );
    return buffer.toString();
  }
}
