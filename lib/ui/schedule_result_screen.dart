import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/google_calendar_service.dart';

class ScheduleResultScreen extends StatefulWidget {
  final String scheduleResult;
  const ScheduleResultScreen({super.key, required this.scheduleResult});

  @override
  State<ScheduleResultScreen> createState() => _ScheduleResultScreenState();
}

class _ScheduleResultScreenState extends State<ScheduleResultScreen> {
  bool _isExporting = false;
  late final ParsedSchedule _parsedData;
  String _selectedFilter = "All Tasks";

  @override
  void initState() {
    super.initState();
    _parsedData = _parseSchedule(widget.scheduleResult);
  }

  ParsedSchedule _parseSchedule(String markdown) {
    final lines = markdown.split('\n');
    List<ScheduleItem> items = [];
    List<String> wellnessTips = [];
    List<String> successTips = [];
    String motivation = "";
    int efficiencyScore = 85;

    bool inTable = false;
    bool inWellness = false;
    bool inSuccess = false;
    bool inMotivation = false;

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.contains('|') && trimmed.contains('---')) {
        inTable = true;
        continue;
      }

      if (trimmed.startsWith('### 🌿')) {
        inWellness = true;
        inTable = false;
        inSuccess = false;
        inMotivation = false;
        continue;
      } else if (trimmed.startsWith('### 💡')) {
        inSuccess = true;
        inTable = false;
        inWellness = false;
        inMotivation = false;
        continue;
      } else if (trimmed.startsWith('### 🎯')) {
        inMotivation = true;
        inTable = false;
        inWellness = false;
        inSuccess = false;
        continue;
      } else if (trimmed.toLowerCase().contains('efficiency score:')) {
        final match = RegExp(r'(\d+)%').firstMatch(trimmed);
        if (match != null) {
          efficiencyScore = int.parse(match.group(1)!);
        }
        continue;
      }

      if (inTable && trimmed.startsWith('|')) {
        final parts = trimmed.split('|').map((e) => e.trim()).toList();
        if (parts.length >= 4 && parts[1] != 'Waktu' && parts[1] != '---') {
          items.add(ScheduleItem(
            time: parts[1].replaceAll('**', ''),
            activity: parts[2].replaceAll('**', ''),
            priority: parts[3].replaceAll('**', ''),
            description: parts.length > 4 ? parts[4].replaceAll('**', '') : "",
          ));
        }
      } else if (inWellness && (trimmed.startsWith('-') || trimmed.startsWith('*'))) {
        wellnessTips.add(trimmed.replaceFirst(RegExp(r'^[-*]\s*'), '').replaceAll('**', ''));
      } else if (inSuccess && (trimmed.startsWith('-') || trimmed.startsWith('*'))) {
        successTips.add(trimmed.replaceFirst(RegExp(r'^[-*]\s*'), '').replaceAll('**', ''));
      } else if (inMotivation && !trimmed.startsWith('#')) {
        motivation += "${trimmed.replaceAll('**', '')} ";
      }
    }

    return ParsedSchedule(
      items: items,
      wellnessTips: wellnessTips,
      successTips: successTips,
      motivation: motivation.trim(),
      efficiencyScore: efficiencyScore,
    );
  }

  Future<void> _exportToGoogleCalendar() async {
    setState(() => _isExporting = true);
    try {
      final success = await GoogleCalendarService.exportToCalendar(widget.scheduleResult);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil ekspor ke Google Calendar!"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal ekspor ke Google Calendar. Pastikan Anda sudah login."), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER (Custom AppBar style)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      "Daily Agenda",
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP AI BANNER (PRESERVED)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
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
                    ),

                    // TODAY SECTION
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Today", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(DateFormat('MMMM d').format(DateTime.now()), style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${_parsedData.efficiencyScore}%", style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                              Text("Efficiency Score", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                      child: Text("Your AI-optimized schedule for peak productivity.", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
                    ),

                    // FILTERS
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          _buildFilterChip("All Tasks", Icons.view_list, _selectedFilter == "All Tasks", theme),
                          const SizedBox(width: 12),
                          _buildFilterChip("High Priority", Icons.priority_high, _selectedFilter == "High Priority", theme),
                          const SizedBox(width: 12),
                          _buildFilterChip("Meetings", Icons.groups, _selectedFilter == "Meetings", theme),
                        ],
                      ),
                    ),

                    // SCHEDULE TABLE/LIST
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 600, // Increased width for horizontal alignment
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainer,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 110, child: Text("Time", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold))),
                                      Expanded(child: Text("Task / Activity", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold))),
                                      SizedBox(width: 80, child: Text("Priority", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                                    ],
                                  ),
                                ),
                                ...List.generate(_getFilteredItems().length, (index) {
                                  final item = _getFilteredItems()[index];
                                  return _buildScheduleRow(item, theme);
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // WELLNESS SECTION
                    if (_parsedData.wellnessTips.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 32, bottom: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.spa, color: Colors.teal),
                            const SizedBox(width: 8),
                            Text("Wellness & Mental Health Tips", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: _parsedData.wellnessTips.map((tip) => _buildWellnessCard(tip, theme)).toList(),
                        ),
                      ),
                    ],

                    // SUCCESS TIPS SECTION
                    if (_parsedData.successTips.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 32, bottom: 16),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text("Success Tips", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: _parsedData.successTips.map((tip) => _buildSuccessCard(tip, theme)).toList(),
                        ),
                      ),
                    ],

                    // MOTIVATIONAL QUOTE
                    if (_parsedData.motivation.isNotEmpty) 
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme.colorScheme.primary.withValues(alpha: 0.1), theme.colorScheme.surfaceContainer],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.format_quote, color: theme.colorScheme.primary, size: 32),
                              const SizedBox(height: 12),
                              Text(
                                "\"${_parsedData.motivation}\"",
                                style: theme.textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                    
                    // BOTTOM BUTTONS
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.autorenew, color: Colors.white),
                            label: const Text("Regenerate Schedule", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _exportToGoogleCalendar,
                                  icon: _isExporting ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary)) : const Icon(Icons.event),
                                  label: const Text("Export to Calendar"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.colorScheme.primary,
                                    side: BorderSide(color: theme.colorScheme.primary),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: widget.scheduleResult));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard!")));
                                },
                                icon: const Icon(Icons.copy),
                                style: IconButton.styleFrom(
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  foregroundColor: theme.colorScheme.onSurface,
                                  padding: const EdgeInsets.all(14),
                                ),
                                iconSize: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ScheduleItem> _getFilteredItems() {
    if (_selectedFilter == "All Tasks") return _parsedData.items;
    if (_selectedFilter == "High Priority") {
      return _parsedData.items.where((item) {
        final p = item.priority.toLowerCase();
        return p.contains('crit') || p.contains('high');
      }).toList();
    }
    if (_selectedFilter == "Meetings") {
      return _parsedData.items.where((item) {
        final act = item.activity.toLowerCase();
        return act.contains('meeting') || act.contains('sync');
      }).toList();
    }
    return _parsedData.items;
  }

  Widget _buildFilterChip(String label, IconData icon, bool selected, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: selected ? null : Border.all(color: theme.colorScheme.outlineVariant),
          boxShadow: selected ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant, fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow(ScheduleItem item, ThemeData theme) {
    final activityIcon = _getActivityIcon(item.activity);
    final priorityColor = _getPriorityColor(item.priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align top for multiline
        children: [
          SizedBox(
            width: 110,
            child: Text(
              item.time, 
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12, fontFamily: 'monospace'),
              softWrap: false,
              overflow: TextOverflow.visible,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(activityIcon, size: 16, color: priorityColor.withValues(alpha: 0.8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.activity,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                if (item.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 24, top: 4),
                    child: Text(
                      item.description,
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.priority,
                  style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessCard(String tip, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.teal, size: 16),
          const SizedBox(width: 12),
          Expanded(child: Text(tip, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildSuccessCard(String tip, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.stars, color: theme.colorScheme.primary, size: 16),
          const SizedBox(width: 12),
          Expanded(child: Text(tip, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14))),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String activity) {
    final act = activity.toLowerCase();
    if (act.contains('tidur') || act.contains('rest')) return Icons.bedtime;
    if (act.contains('workout') || act.contains('olahraga')) return Icons.fitness_center;
    if (act.contains('work') || act.contains('kerja')) return Icons.laptop_chromebook;
    if (act.contains('meeting') || act.contains('sync')) return Icons.group;
    if (act.contains('makan')) return Icons.restaurant;
    if (act.contains('baca') || act.contains('read')) return Icons.menu_book;
    if (act.contains('code')) return Icons.code;
    if (act.contains('meditasi') || act.contains('relax')) return Icons.self_improvement;
    return Icons.event_note;
  }

  Color _getPriorityColor(String priority) {
    final p = priority.toLowerCase();
    if (p.contains('crit')) return Colors.red;
    if (p.contains('high')) return Colors.orange;
    if (p.contains('med')) return const Color(0xFF137fec);
    if (p.contains('low')) return Colors.grey;
    return const Color(0xFF92adc9);
  }
}

class ParsedSchedule {
  final List<ScheduleItem> items;
  final List<String> wellnessTips;
  final List<String> successTips;
  final String motivation;
  final int efficiencyScore;

  ParsedSchedule({
    required this.items,
    required this.wellnessTips,
    required this.successTips,
    required this.motivation,
    required this.efficiencyScore,
  });
}

class ScheduleItem {
  final String time;
  final String activity;
  final String priority;
  final String description;

  ScheduleItem({
    required this.time,
    required this.activity,
    required this.priority,
    required this.description,
  });
}

