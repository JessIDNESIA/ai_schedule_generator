import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class GoogleCalendarService {
  /// Membuka Google Calendar via URL Template (Action=TEMPLATE)
  /// Ini menghindari masalah OAuth 403 access_denied
  static Future<bool> exportToCalendar(String markdownSchedule) async {
    try {
      // 1. Parse Markdown ke List of Event Data
      final events = _parseMarkdownToEvents(markdownSchedule);

      if (events.isEmpty) {
        print('Tidak ada event yang ditemukan untuk di-export.');
        return false;
      }

      // 2. Ambil event pertama untuk di-export via URL Redirect
      final firstEvent = events.first;
      final url = _generateTemplateUrl(firstEvent, markdownSchedule);

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        return true;
      } else {
        print('Gagal menjalankan URL: $url');
        return false;
      }
    } catch (e) {
      print('Export to Calendar Error: $e');
      return false;
    }
  }

  /// Menghasilkan URL Google Calendar Templated
  static String _generateTemplateUrl(Map<String, String> event, String fullSchedule) {
    final title = Uri.encodeComponent(event['summary'] ?? 'Jadwal AI');
    
    // Gabungkan info event spesifik dengan jadwal lengkap di Deskripsi
    final fullDetails = "📌 Kegiatan: ${event['summary']}\n"
        "📝 Keterangan: ${event['description']}\n\n"
        "--- JADWAL LENGKAP ---\n"
        "$fullSchedule";
        
    final details = Uri.encodeComponent(fullDetails);
    final dates = '${event['start']}/${event['end']}';

    return 'https://calendar.google.com/calendar/render?action=TEMPLATE'
        '&text=$title'
        '&details=$details'
        '&dates=$dates'
        '&ctz=Asia/Jakarta';
  }

  /// Parsing Markdown Tabel ke List of Event Data (Simplified for URL)
  static List<Map<String, String>> _parseMarkdownToEvents(String markdown) {
    List<Map<String, String>> events = [];
    final lines = markdown.split('\n');
    
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyyMMdd');
    final todayStr = dateFormat.format(now);

    for (var line in lines) {
      if (line.contains('|') && !line.contains('---') && !line.contains('Waktu')) {
        final cells = line.split('|').map((e) => e.trim()).toList();
        cells.removeWhere((element) => element.isEmpty);

        if (cells.length >= 2) {
          final timeRange = cells[0];
          final activity = cells[1];
          final description = cells.length > 4 ? cells[4] : '';

          try {
            final times = timeRange.split(RegExp(r'\s*-\s*'));
            if (times.length == 2) {
              final startTime = times[0].replaceAll(':', '');
              final endTime = times[1].replaceAll(':', '');

              // Format Google Calendar URL: YYYYMMDDTHHMMSSZ
              final startStr = '${todayStr}T${startTime}00';
              final endStr = '${todayStr}T${endTime}00';

              events.add({
                'summary': activity,
                'description': description,
                'start': startStr,
                'end': endStr,
              });
            }
          } catch (e) {
            print('Gagal parsing baris: $line, error: $e');
          }
        }
      }
    }
    return events;
  }
}
