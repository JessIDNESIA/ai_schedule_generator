import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/gemini_service.dart'; // Service untuk memanggil AI
import 'schedule_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> tasks = [];
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  
  String _selectedDurationPreset = "30 mins";
  int _durationInMinutes = 30;
  String _priority = "Medium";
  bool isLoading = false;

  final Map<String, int> _durationPresets = {
    "15 mins": 15,
    "30 mins": 30,
    "45 mins": 45,
    "1 hour": 60,
    "1.5 hours": 90,
    "2 hours": 120,
  };

  @override
  void dispose() {
    taskNameController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _updateDurationFromPreset(String? preset, StateSetter setStatePopup) {
    if (preset != null && _durationPresets.containsKey(preset)) {
      setStatePopup(() {
        _selectedDurationPreset = preset;
        _durationInMinutes = _durationPresets[preset]!;
      });
    }
  }

  void _updateDurationValue(int delta, StateSetter setStatePopup) {
    setStatePopup(() {
      _durationInMinutes = (_durationInMinutes + delta).clamp(1, 480);
      _selectedDurationPreset = _durationPresets.entries
          .firstWhere((e) => e.value == _durationInMinutes,
              orElse: () => const MapEntry("Custom", -1))
          .key;
    });
  }

  void _showNotification(String message, {bool isError = false}) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(20 * (1 - value), 0),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isError ? Colors.red : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void _addTask() {
    if (taskNameController.text.isNotEmpty) {
      setState(() {
        tasks.insert(0, {
          "name": taskNameController.text,
          "priority": _priority,
          "duration": _durationInMinutes,
          "notes": notesController.text,
          "timestamp": DateTime.now(),
          "category": _getCategoryForName(taskNameController.text),
        });
      });
      taskNameController.clear();
      notesController.clear();
      Navigator.pop(context);
      _showNotification("Task added successfully!");
    }
  }

  String _getCategoryForName(String name) {
    name = name.toLowerCase();
    if (name.contains("report") || name.contains("finance")) return "Finance";
    if (name.contains("design") || name.contains("palette")) return "Design";
    if (name.contains("code") || name.contains("bug")) return "Dev";
    if (name.contains("email") || name.contains("mail")) return "Admin";
    return "Work";
  }

  void _showAddTaskSheet() {
    _selectedDurationPreset = "30 mins";
    _durationInMinutes = 30;
    _priority = "Medium";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStatePopup) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Add New Task",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    _buildLabel(Theme.of(context), "Task Name"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: taskNameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: "What needs to be done?",
                        prefixIcon: Icon(Icons.edit_note, size: 24),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel(Theme.of(context), "Duration"),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _selectedDurationPreset == "Custom" ? null : _selectedDurationPreset,
                            hint: const Text("Custom"),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.timer, size: 20),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            items: _durationPresets.keys.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) => _updateDurationFromPreset(val, setStatePopup),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).colorScheme.outline),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => _updateDurationValue(-5, setStatePopup),
                                icon: Icon(Icons.remove, color: Theme.of(context).colorScheme.primary, size: 20),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                              ),
                              Container(
                                width: 32,
                                alignment: Alignment.center,
                                child: Text(
                                  "$_durationInMinutes",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              const Text("min", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              IconButton(
                                onPressed: () => _updateDurationValue(5, setStatePopup),
                                icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary, size: 20),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildLabel(Theme.of(context), "Priority"),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                      ),
                      child: Row(
                        children: [
                          _buildPriorityOption(Theme.of(context), "Low", _priority == "Low", setStatePopup),
                          _buildPriorityOption(Theme.of(context), "Medium", _priority == "Medium", setStatePopup),
                          _buildPriorityOption(Theme.of(context), "High", _priority == "High", setStatePopup),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel(Theme.of(context), "Notes"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: "Add any details here...",
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _addTask,
                        child: const Text("Create Task"),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _generateSchedule() async {
    if (tasks.isEmpty) {
      _showNotification("Please add tasks first!", isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      String schedule = await GeminiService.generateSchedule(tasks);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScheduleResultScreen(scheduleResult: schedule),
        ),
      );
    } catch (e) {
      _showNotification("Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final todayTasks = tasks.where((t) {
      final ts = t['timestamp'] as DateTime;
      return ts.day == now.day && ts.month == now.month && ts.year == now.year;
    }).toList();

    double totalHrs = todayTasks.fold(0.0, (sum, t) => sum + (t['duration'] as int) / 60.0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text("My Tasks"),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF137FEC), Color(0xFF60A5FA)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, User",
                            style: theme.textTheme.displayLarge?.copyWith(fontSize: 24),
                          ),
                          Text(
                            "You have ${todayTasks.length} tasks for today.",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${totalHrs.toStringAsFixed(1)} hrs total",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Calendar Strip (Simplified)
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final date = now.add(Duration(days: index - 2));
                      final isToday = index == 2;
                      return Container(
                        width: 56,
                        decoration: BoxDecoration(
                          color: isToday ? theme.colorScheme.primary : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: isToday ? null : Border.all(color: theme.colorScheme.outline),
                          boxShadow: isToday ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ] : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E').format(date),
                              style: TextStyle(
                                fontSize: 11,
                                color: isToday ? Colors.white : theme.colorScheme.onSurfaceVariant,
                                fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${date.day}",
                              style: TextStyle(
                                fontSize: 18,
                                color: isToday ? Colors.white : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Text(
                    "TO DO",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                ),

                if (todayTasks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60, left: 40, right: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.task_alt,
                              size: 48,
                              color: theme.colorScheme.primary.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "No tasks for today",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Enjoy your day or add a new task to get started!",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: todayTasks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = todayTasks[index];
                      return _buildTaskCard(theme, task);
                    },
                  ),
              ],
            ),
          ),
          
          // Floating Action Buttons (Positioned relative to bottom)
          Positioned(
            bottom: 110,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: _showAddTaskSheet,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.outline),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          "Add Task",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: isLoading ? null : _generateSchedule,
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.auto_fix_high, color: Colors.white),
                        const SizedBox(width: 10),
                        const Text(
                          "Generate Schedule",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.95),
                border: Border(top: BorderSide(color: theme.colorScheme.outline)),
              ),
              child: SafeArea(
                top: false,
                bottom: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildNavItem(theme, Icons.check_circle, "Tasks", true, () {}),
                      _buildNavItem(theme, Icons.calendar_month, "Calendar", false, () {
                        _showNotification("Calendar feature coming soon!");
                      }),
                      _buildNavItem(theme, Icons.analytics, "Insights", false, () {
                        _showNotification("Insights feature coming soon!");
                      }),
                      _buildNavItem(theme, Icons.settings, "Settings", false, () {
                        _showNotification("Settings feature coming soon!");
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(ThemeData theme, Map<String, dynamic> task) {
    Color pColor = _getPriorityColor(task['priority']);
    String pLabel = task['priority'].toString().toUpperCase().substring(0, 3);
    IconData taskIcon = _getIconForCategory(task['category']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: pColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: pColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                pLabel,
                style: TextStyle(
                  color: pColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(taskIcon, color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['name'],
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text("${task['duration']} mins", style: theme.textTheme.bodySmall),
                        const SizedBox(width: 12),
                        Icon(Icons.folder, size: 14, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(task['category'] ?? "Work", style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String? category) {
    switch (category) {
      case "Finance": return Icons.description;
      case "Design": return Icons.palette;
      case "Dev": return Icons.code;
      case "Admin": return Icons.mail;
      default: return Icons.work;
    }
  }

  Widget _buildLabel(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildPriorityOption(ThemeData theme, String label, bool isSelected, StateSetter setStatePopup) {
    Color selectedColor;
    if (label == "Low") {
      selectedColor = theme.colorScheme.secondaryContainer;
    } else if (label == "Medium") {
      selectedColor = theme.colorScheme.tertiary;
    } else {
      selectedColor = theme.colorScheme.error;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => setStatePopup(() => _priority = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
            ] : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? selectedColor : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(ThemeData theme, IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    if (priority == "High") return const Color(0xFFEF4444);
    if (priority == "Medium") return const Color(0xFFF97316);
    return const Color(0xFF22C55E);
  }
}

