// Файл: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../widgets/day_card.dart';
import '../widgets/sleep_input_sheet.dart';
import '../widgets/mood_input_sheet.dart';
import '../widgets/full_day_input_sheet.dart';
import '../services/supabase_diary_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  final SupabaseDiaryService _diaryService = SupabaseDiaryService();
  Map<String, Map<String, dynamic>> _diaryRecords = {};

  final Color primaryTeal = const Color(0xFF4DB6AC);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now();
    final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    final todayId = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final records = await _diaryService.getRecordsForMonth(yearMonth);
    final Map<String, Map<String, dynamic>> newRecordsMap = {};

    for (var record in records) {
      newRecordsMap[record['date_id']] = record;
    }

    if (!newRecordsMap.containsKey(todayId)) {
      newRecordsMap[todayId] = {'date_id': todayId};
    }

    setState(() {
      _diaryRecords = newRecordsMap;
      _isLoading = false;
    });
  }

  Future<void> _pickDateAndOpen(BuildContext context, {DateTime? initialDate}) async {
    DateTime tempSelectedDate = initialDate ?? DateTime.now();

    final DateTime? pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, 
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 16,
                right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: const EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: primaryTeal,
                          onPrimary: Colors.white,
                          onSurface: Colors.black87,
                        ),
                      ),
                      child: CalendarDatePicker(
                        initialDate: tempSelectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        onDateChanged: (DateTime date) {
                          setState(() {
                            tempSelectedDate = date;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(tempSelectedDate);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Продолжить',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (pickedDate != null) {
      final dateId = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      Map<String, dynamic>? record = _diaryRecords[dateId];

      if (record == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Загрузка данных...'), duration: Duration(milliseconds: 500)),
        );
        final fetchedRecord = await _diaryService.getRecordForDate(dateId);
        setState(() {
          _diaryRecords[dateId] = fetchedRecord ?? {'date_id': dateId};
        });
        record = _diaryRecords[dateId];
      }

      if (context.mounted) {
        _openFullDayInput(context, dateId, record);
      }
    }
  }

  void _openFullDayInput(BuildContext context, String dateId, Map<String, dynamic>? existingRecord) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FullDayInputSheet(
          dateId: dateId,
          initialData: existingRecord,
          onSave: (sleep, morning, day, evening) async {
            Navigator.of(context).pop();
            setState(() {
              if (!_diaryRecords.containsKey(dateId)) {
                _diaryRecords[dateId] = {'date_id': dateId};
              }
              _diaryRecords[dateId]!['sleep_hours'] = sleep;
              _diaryRecords[dateId]!['morning_mood'] = morning;
              _diaryRecords[dateId]!['day_mood'] = day;
              _diaryRecords[dateId]!['evening_mood'] = evening;
            });
            try {
              await _diaryService.saveFullDay(
                dateId: dateId,
                sleepHours: sleep,
                morningMood: morning,
                dayMood: day,
                eveningMood: evening,
              );
            } catch (e) {
              print('Ошибка при сохранении дня: $e');
            }
          },
        );
      },
    );
  }

  Color getMoodColor(int score) {
    switch (score) {
      case 1: return const Color(0xFF1A237E);
      case 2: return const Color(0xFF3949AB);
      case 3: return const Color(0xFF5C6BC0);
      case 4: return const Color(0xFF26A69A);
      case 5: return primaryTeal;
      case 6: return const Color(0xFF81C784);
      case 7: return const Color(0xFFFFB300);
      case 8: return const Color(0xFFFB8C00);
      case 9: return const Color(0xFFE53935);
      case 10: return const Color(0xFFB71C1C);
      default: return Colors.grey;
    }
  }

  String _getDaysDeclension(int count) {
    final int mod10 = count % 10;
    final int mod100 = count % 100;
    if (mod100 >= 11 && mod100 <= 19) return 'Пропущено $count дней';
    if (mod10 == 1) return 'Пропущен $count день';
    if (mod10 >= 2 && mod10 <= 4) return 'Пропущено $count дня';
    return 'Пропущено $count дней';
  }

  Widget _buildBottomNavItem({
    required IconData icon, 
    required String label, 
    required bool isActive, 
    required VoidCallback onTap
  }) {
    final color = isActive ? Colors.white : Colors.white.withOpacity(0.6);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = _diaryRecords.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), 
      // Полностью убрали AppBar!
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickDateAndOpen(context),
        backgroundColor: Colors.white,
        shape: CircleBorder(
          side: BorderSide(color: primaryTeal, width: 3.0),
        ), 
        elevation: 4,
        child: Icon(Icons.add_rounded, color: primaryTeal, size: 32),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: primaryTeal, 
        surfaceTintColor: Colors.transparent, 
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(icon: Icons.list_alt_rounded, label: 'Записи', isActive: true, onTap: () {}),
              _buildBottomNavItem(icon: Icons.bar_chart_rounded, label: 'Статистика', isActive: false, onTap: () {}),
              const SizedBox(width: 48), 
              _buildBottomNavItem(icon: Icons.calendar_month_rounded, label: 'Календарь', isActive: false, onTap: () {}),
              _buildBottomNavItem(icon: Icons.more_horiz_rounded, label: 'Больше', isActive: false, onTap: () {}),
            ],
          ),
        ),
      ),
      // Обернули body в SafeArea
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : ListView.builder(
              // Увеличили верхний отступ (top: 24.0), чтобы карточка "дышала"
              padding: const EdgeInsets.only(bottom: 40, top: 24.0),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final dateId = sortedDates[index];
                final record = _diaryRecords[dateId]!;

                final double? currentSleep = record['sleep_hours'] != null 
                    ? (record['sleep_hours'] as num).toDouble() 
                    : null;
                final int? morningScore = record['morning_mood'] as int?;
                final int? dayScore = record['day_mood'] as int?;
                final int? eveningScore = record['evening_mood'] as int?;

                Widget cardWidget = DayCard(
                  dateId: dateId, 
                  sleepHours: currentSleep,
                  morningMoodScore: morningScore,
                  morningMoodColor: morningScore != null ? getMoodColor(morningScore) : null,
                  dayMoodScore: dayScore,
                  dayMoodColor: dayScore != null ? getMoodColor(dayScore) : null,
                  eveningMoodScore: eveningScore,
                  eveningMoodColor: eveningScore != null ? getMoodColor(eveningScore) : null,
                  onAddSleep: () => _openInputBottomSheet(context, dateId, 'Сон'),
                  onAddMorning: () => _openInputBottomSheet(context, dateId, 'Утро'),
                  onAddDay: () => _openInputBottomSheet(context, dateId, 'День'),
                  onAddEvening: () => _openInputBottomSheet(context, dateId, 'Вечер'),
                );

                Widget? gapIndicator;
                if (index < sortedDates.length - 1) {
                  final currentDate = DateTime.parse(sortedDates[index]);
                  final nextOlderDate = DateTime.parse(sortedDates[index + 1]);
                  final int missedDays = currentDate.difference(nextOlderDate).inDays.abs() - 1;

                  if (missedDays > 0) {
                    gapIndicator = GestureDetector(
                      onTap: () => _pickDateAndOpen(
                        context, 
                        initialDate: currentDate.subtract(const Duration(days: 1)),
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Text(
                            _getDaysDeclension(missedDays),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }

                if (gapIndicator != null) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [cardWidget, gapIndicator],
                  );
                }
                return cardWidget;
              },
            ),
      ),
    );
  }

  void _openInputBottomSheet(BuildContext context, String dateId, String period) {
    if (period == 'Сон') {
      _openSleepInput(context, dateId);
    } else {
      _openMoodInput(context, dateId, period);
    }
  }

  void _openMoodInput(BuildContext context, String dateId, String period) {
    int initialScore = 5;
    final record = _diaryRecords[dateId] ?? {};

    if (period == 'Утро' && record['morning_mood'] != null) initialScore = record['morning_mood'];
    if (period == 'День' && record['day_mood'] != null) initialScore = record['day_mood'];
    if (period == 'Вечер' && record['evening_mood'] != null) initialScore = record['evening_mood'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MoodInputSheet(
          initialScore: initialScore,
          period: period,
          onSave: (score) async {          
            setState(() {
              if (!_diaryRecords.containsKey(dateId)) {
                _diaryRecords[dateId] = {'date_id': dateId};
              }
              if (period == 'Утро') _diaryRecords[dateId]!['morning_mood'] = score;
              if (period == 'День') _diaryRecords[dateId]!['day_mood'] = score;
              if (period == 'Вечер') _diaryRecords[dateId]!['evening_mood'] = score;
            });

            try {
              await _diaryService.saveMood(dateId, period, score);
            } catch (e) {
              print('Ошибка сохранения настроения: $e');
            }
          },
        );
      },
    );
  }

  void _openSleepInput(BuildContext context, String dateId) {
    final record = _diaryRecords[dateId] ?? {};
    double initialValue = record['sleep_hours'] != null 
        ? (record['sleep_hours'] as num).toDouble() 
        : 8.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SleepInputSheet(
          initialSleep: initialValue,
          onSave: (sleepValue) async {
            setState(() {
              if (!_diaryRecords.containsKey(dateId)) {
                _diaryRecords[dateId] = {'date_id': dateId};
              }
              _diaryRecords[dateId]!['sleep_hours'] = sleepValue;
            });

            try {
              await _diaryService.saveSleep(dateId, sleepValue);
            } catch (e) {
              print('Ошибка сохранения сна: $e');
            }
          },
        );
      },
    );
  }
}
