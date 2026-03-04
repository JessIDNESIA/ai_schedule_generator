import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk fitur copy ke clipboard
import 'package:flutter_markdown/flutter_markdown.dart'; // Untuk render Markdown
import '../services/google_calendar_service.dart';

class ScheduleResultScreen extends StatefulWidget {
  final String scheduleResult; // Data hasil dari AI
  const ScheduleResultScreen({super.key, required this.scheduleResult});

  @override
  State<ScheduleResultScreen> createState() => _ScheduleResultScreenState();
}

class _ScheduleResultScreenState extends State<ScheduleResultScreen> {
  bool _isExporting = false;

  Future<void> _exportToGoogleCalendar() async {
    setState(() => _isExporting = true);
    try {
      final success = await GoogleCalendarService.exportToCalendar(widget.scheduleResult);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berhasil ekspor ke Google Calendar!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal ekspor ke Google Calendar. Pastikan Anda sudah login."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // APP BAR + COPY & EXPORT BUTTONS
      appBar: AppBar(
        title: const Text("Hasil Jadwal Optimal"),
        actions: [
          // TOMBOL EXPORT GOOGLE CALENDAR
          _isExporting
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.event),
                  tooltip: "Export ke Google Calendar",
                  onPressed: _exportToGoogleCalendar,
                ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: "Salin Jadwal",
            onPressed: () {
              // Menyalin seluruh hasil ke clipboard
              Clipboard.setData(ClipboardData(text: widget.scheduleResult));
              // Notifikasi kecil ke user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Jadwal berhasil disalin!")),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // HEADER INFORMASI
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.auto_awesome, color: Colors.indigo),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Jadwal ini disusun otomatis oleh AI berdasarkan prioritas Anda.",
                        style: TextStyle(color: Colors.indigo, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              // AREA HASIL (MARKDOWN DENGAN HORIZONTAL SCROLL)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width - 32,
                            // Beri maxWidth yang cukup besar agar table tidak terpotong
                            maxWidth: 1000, 
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: MarkdownBody(
                              data: widget.scheduleResult,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                p: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                                h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
                                h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.indigoAccent),
                                tableBorder: TableBorder.all(color: Colors.grey.shade300, width: 1),
                                tableHeadAlign: TextAlign.center,
                                tablePadding: const EdgeInsets.all(12),
                                tableHead: const TextStyle(fontWeight: FontWeight.bold),
                                tableBody: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // TOMBOL KEMBALI
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Buat Jadwal Baru"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

