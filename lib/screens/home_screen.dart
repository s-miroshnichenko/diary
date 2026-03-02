// Файл: lib/screens/home_screen.dart

import 'dart:ui';
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
    // Формируем строку для текущего месяца (например, "2026-03")
    final currentYearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    // Формируем строку для предыдущего месяца
    final prevMonthDate = DateTime(now.year, now.month - 1, 1);
    final prevYearMonth = "${prevMonthDate.year}-${prevMonthDate.month.toString().padLeft(2, '0')}";

    final todayId = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // Запрашиваем записи за оба месяца параллельно для скорости
    final currentMonthRecordsFuture = _diaryService.getRecordsForMonth(currentYearMonth);
    final prevMonthRecordsFuture = _diaryService.getRecordsForMonth(prevYearMonth);

    final results = await Future.wait([currentMonthRecordsFuture, prevMonthRecordsFuture]);

    // Объединяем результаты
    final allRecords = [...results[0], ...results[1]];
    final Map<String, Map<String, dynamic>> newRecordsMap = {};

    for (var record in allRecords) {
      newRecordsMap[record['date_id']] = record;
    }

    // Если за сегодня еще нет записи, создаем пустую карточку
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
      Map<String, dynamic> record = _diaryRecords[dateId] ?? {'date_id': dateId};
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
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка БД: $e'), backgroundColor: Colors.red),
                );
              }
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

  Widget _buildGapIndicator(int missedDays) {
    return GestureDetector(
      onTap: () async {
        // ... логика тапа по пропуску
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Center(
          child: Text(
            _getDaysDeclension(missedDays),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthYearName(DateTime date) {
    const months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return '${months[date.month - 1]} ${date.year}';
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
    final now = DateTime.now();

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF0F2F5),
      // Убираем floatingActionButton и floatingActionButtonLocation
      
      bottomNavigationBar: BottomAppBar(
        color: primaryTeal,
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        // Отступ внутри самой панели. SafeArea позаботится о системной полоске снизу.
        padding: EdgeInsets.zero, 
        child: SafeArea(
          top: false,
          // Убрали фиксированный SizedBox(height: 72), чтобы панель могла сама 
          // подстроиться под высоту контента и системные отступы.
          child: Padding(
            padding: const EdgeInsets.only(top: 0.0, bottom: 0.0), // Отступ снизу поднимет все кнопки
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildBottomNavItem(icon: Icons.list_alt_rounded, label: 'Записи', isActive: true, onTap: () {}),
                _buildBottomNavItem(icon: Icons.bar_chart_rounded, label: 'Статистика', isActive: false, onTap: () {}),
                
                // Наша кнопка с плюсом
                Padding(
                  // Дополнительно приподнимаем сам плюсик чуть выше остальных иконок, 
                  // если это необходимо визуально. Если хотите вровень — можно удалить этот Padding.
                  padding: const EdgeInsets.only(bottom: 14.0), 
                  child: Container(
                    width: 56, 
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _pickDateAndOpen(context),
                        child: Icon(
                          Icons.add_rounded,
                          color: primaryTeal,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),

                _buildBottomNavItem(icon: Icons.calendar_month_rounded, label: 'Календарь', isActive: false, onTap: () {}),
                _buildBottomNavItem(icon: Icons.more_horiz_rounded, label: 'Больше', isActive: false, onTap: () {}),
              ],
            ),
          ),
        ),
      ),

      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                reverse: true,
                padding: const EdgeInsets.only(bottom: 80.0, top: 40.0),
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  // ... (весь код внутри itemBuilder остается без изменений)
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

                  List<Widget> beforeCardWidgets = [];

                  if (index < sortedDates.length - 1) {
                    final currentDate = DateTime.parse(sortedDates[index]);
                    final nextOlderDate = DateTime.parse(sortedDates[index + 1]);
                    final bool isDifferentMonth = currentDate.month != nextOlderDate.month || currentDate.year != nextOlderDate.year;

                    if (isDifferentMonth) {
                      final firstDayOfCurrentMonth = DateTime(currentDate.year, currentDate.month, 1);
                      final int missedInCurrentMonth = currentDate.difference(firstDayOfCurrentMonth).inDays;
                      if (missedInCurrentMonth > 0) {
                        beforeCardWidgets.add(_buildGapIndicator(missedInCurrentMonth));
                      }

                      beforeCardWidgets.add(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Center(
                            child: Text(
                              _getMonthYearName(nextOlderDate).toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF8A9AA6),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      );

                      final lastDayOfPrevMonth = DateTime(currentDate.year, currentDate.month, 0);
                      final int missedInPrevMonth = lastDayOfPrevMonth.difference(nextOlderDate).inDays;
                      if (missedInPrevMonth > 0) {
                        beforeCardWidgets.add(_buildGapIndicator(missedInPrevMonth));
                      }
                    } else {
                      final int missedDays = currentDate.difference(nextOlderDate).inDays.abs() - 1;
                      if (missedDays > 0) {
                        beforeCardWidgets.add(_buildGapIndicator(missedDays));
                      }
                    }
                  }

                  if (beforeCardWidgets.isNotEmpty) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...beforeCardWidgets,
                        cardWidget,
                      ],
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
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка БД: $e'), backgroundColor: Colors.red),
                );
              }
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
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка БД: $e'), backgroundColor: Colors.red),
                );
              }
            }
          },
        );
      },
    );
  }
}
