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

  // Выносим цвет в константу для удобства
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
    // Временная переменная для хранения выбранной даты до нажатия "Продолжить"
    DateTime tempSelectedDate = initialDate ?? DateTime.now();

    final DateTime? pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent, // Прозрачный фон для эффекта "парящих" элементов
      isScrollControlled: true, 
      builder: (BuildContext context) {
        // Используем StatefulBuilder, чтобы обновлять выбранный день без перерисовки всего экрана
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              // Динамический отступ снизу с учетом SafeArea (например, "челки" на iPhone)
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 16,
                right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Занимаем минимум места по вертикали
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Блок с календарем
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28), // Закругление как на макете
                    ),
                    padding: const EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: primaryTeal, // Цвет кружка выбранной даты
                          onPrimary: Colors.white, // Цвет текста внутри кружка
                          onSurface: Colors.black87,
                        ),
                      ),
                      child: CalendarDatePicker(
                        initialDate: tempSelectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        onDateChanged: (DateTime date) {
                          // Обновляем выделение при клике на день
                          setState(() {
                            tempSelectedDate = date;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Блок с кнопкой "Продолжить"
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Возвращаем выбранную дату при закрытии
                        Navigator.of(context).pop(tempSelectedDate);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32), // Сильное закругление кнопки
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

        // НОВАЯ ЛОГИКА КАЛЕНДАРЯ
    if (pickedDate != null) {
      final dateId = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      
      // Сначала проверяем, есть ли уже данные за этот день в локальной памяти (в ленте)
      Map<String, dynamic>? record = _diaryRecords[dateId];
      
      // Если данных локально нет, загружаем из базы (Supabase)
      if (record == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Загрузка данных...'), duration: Duration(milliseconds: 500)),
        );
        
        final fetchedRecord = await _diaryService.getRecordForDate(dateId);
        
        setState(() {
          // Сохраняем загруженные данные или создаем пустую "болванку" для этого дня
          _diaryRecords[dateId] = fetchedRecord ?? {'date_id': dateId};
        });
        
        record = _diaryRecords[dateId];
      }
      
      // Открываем окно, передавая туда найденную запись (record)
      if (context.mounted) {
        _openFullDayInput(context, dateId, record);
      }
    }
  }

  // Открывает единое окно для заполнения целого дня
  void _openFullDayInput(BuildContext context, String dateId, Map<String, dynamic>? existingRecord) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Позволяет BottomSheet занимать больше половины экрана
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FullDayInputSheet(
          dateId: dateId,
          initialData: existingRecord,
          onSave: (sleep, morning, day, evening) async {
            // 1. Закрываем BottomSheet сразу после нажатия
            Navigator.of(context).pop();

            // 2. Локально обновляем состояние, чтобы UI (DayCard) мгновенно обновился
            setState(() {
              if (!_diaryRecords.containsKey(dateId)) {
                _diaryRecords[dateId] = {'date_id': dateId};
              }
              _diaryRecords[dateId]!['sleep_hours'] = sleep;
              _diaryRecords[dateId]!['morning_mood'] = morning;
              _diaryRecords[dateId]!['day_mood'] = day;
              _diaryRecords[dateId]!['evening_mood'] = evening;
            });

            // 3. Отправляем в Supabase единым запросом
            try {
              await _diaryService.saveFullDay(
                dateId: dateId,
                sleepHours: sleep,
                morningMood: morning,
                dayMood: day,
                eveningMood: evening,
              );
            } catch (e) {
              // Если вдруг произойдет ошибка базы данных, выведем её в консоль
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
      case 5: return primaryTeal; // Заменил на нашу константу
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
    
    if (mod100 >= 11 && mod100 <= 19) {
      return 'Пропущено $count дней';
    }
    if (mod10 == 1) {
      return 'Пропущен $count день';
    }
    if (mod10 >= 2 && mod10 <= 4) {
      return 'Пропущено $count дня';
    }
    return 'Пропущено $count дней';
  }

  // Обновленный метод для кнопок навигации (теперь белые)
  Widget _buildBottomNavItem({
    required IconData icon, 
    required String label, 
    required bool isActive, 
    required VoidCallback onTap
  }) {
    // Если активно - чисто белый, если нет - полупрозрачный белый
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Дневник'),
        // ... (Код AppBar)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickDateAndOpen(context),
        backgroundColor: Colors.white,
        // НОВОЕ: Окружность (граница) цвета 0xFF4DB6AC
        shape: CircleBorder(
          side: BorderSide(
            color: primaryTeal, 
            width: 3.0, // Толщина обводки
          ),
        ), 
        elevation: 4,
        // НОВОЕ: Плюсик цвета 0xFF4DB6AC
        child: Icon(Icons.add_rounded, color: primaryTeal, size: 32),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        // НОВОЕ: Заливаем саму область (BottomAppBar) в 0xFF4DB6AC
        color: primaryTeal, 
        surfaceTintColor: Colors.transparent, // Чтобы Material 3 не искажал цвет
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                icon: Icons.list_alt_rounded, 
                label: 'Записи', 
                isActive: true, 
                onTap: () {}, 
              ),
              _buildBottomNavItem(
                icon: Icons.bar_chart_rounded, 
                label: 'Статистика', 
                isActive: false, 
                onTap: () {}, 
              ),
              const SizedBox(width: 48), // Отступ под центральную кнопку
              _buildBottomNavItem(
                icon: Icons.calendar_month_rounded, 
                label: 'Календарь', 
                isActive: false, 
                onTap: () {}, 
              ),
              _buildBottomNavItem(
                icon: Icons.more_horiz_rounded, 
                label: 'Больше', 
                isActive: false, 
                onTap: () {}, 
              ),
            ],
          ),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView.builder(
            padding: const EdgeInsets.only(bottom: 40, top: 16),
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
                  children: [
                    cardWidget,
                    gapIndicator,
                  ],
                );
              }

              return cardWidget;
            },
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
    
    // Подхватываем уже существующие данные для конкретного периода
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
            // Локально обновляем UI
            setState(() {
              if (!_diaryRecords.containsKey(dateId)) {
                _diaryRecords[dateId] = {'date_id': dateId};
              }
              if (period == 'Утро') _diaryRecords[dateId]!['morning_mood'] = score;
              if (period == 'День') _diaryRecords[dateId]!['day_mood'] = score;
              if (period == 'Вечер') _diaryRecords[dateId]!['evening_mood'] = score;
            });
            
            // Отправляем ОДИН точечный запрос в Supabase (это безопасно)
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
    
    // Подхватываем уже существующие часы сна
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
            // Локально обновляем UI
            setState(() {
              if (!_diaryRecords.containsKey(dateId)) {
                _diaryRecords[dateId] = {'date_id': dateId};
              }
              _diaryRecords[dateId]!['sleep_hours'] = sleepValue;
            });
            
            // Отправляем ОДИН точечный запрос в Supabase
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
