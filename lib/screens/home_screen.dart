// Файл: lib/screens/home_screen.dart

import 'package:flutter/material.dart';

import '../widgets/expandable_fab.dart';
import '../widgets/day_card.dart';
import '../widgets/sleep_input_sheet.dart';
import '../widgets/mood_input_sheet.dart';
import '../services/supabase_diary_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ExpandableFabState> _fabKey = GlobalKey<ExpandableFabState>();
  bool _isFabOpen = false;
  bool _isLoading = true;

  final SupabaseDiaryService _diaryService = SupabaseDiaryService();

  Map<String, Map<String, dynamic>> _diaryRecords = {};

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
    // Вычисляем dateId для сегодняшнего дня
    final todayId = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final records = await _diaryService.getRecordsForMonth(yearMonth);

    final Map<String, Map<String, dynamic>> newRecordsMap = {};
    for (var record in records) {
      newRecordsMap[record['date_id']] = record;
    }

    // НОВОЕ: Гарантируем, что карточка "Сегодня" всегда есть в списке
    if (!newRecordsMap.containsKey(todayId)) {
      newRecordsMap[todayId] = {'date_id': todayId}; // Создаем пустую заготовку
    }

    setState(() {
      _diaryRecords = newRecordsMap;
      _isLoading = false;
    });
  }

  Color getMoodColor(int score) {
    switch (score) {
      case 1: return const Color(0xFF1A237E);
      case 2: return const Color(0xFF3949AB);
      case 3: return const Color(0xFF5C6BC0);
      case 4: return const Color(0xFF26A69A);
      case 5: return const Color(0xFF4DB6AC);
      case 6: return const Color(0xFF81C784);
      case 7: return const Color(0xFFFFB300);
      case 8: return const Color(0xFFFB8C00);
      case 9: return const Color(0xFFE53935);
      case 10: return const Color(0xFFB71C1C);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Получаем список всех дат и сортируем от новых к старым (Сегодня всегда будет первым)
    final sortedDates = _diaryRecords.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Дневник'),
        // ... (Ваш код AppBar)
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 140, top: 16),
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

              return DayCard(
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
            },
          ),

          // Затемнение экрана (Overlay)
          AnimatedOpacity(
            opacity: _isFabOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: _isFabOpen
                ? GestureDetector(
                    onTap: () {
                      _fabKey.currentState?.toggle();
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.85),
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Радиальное меню (ExpandableFab)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: ExpandableFab(
                key: _fabKey,
                distance: 95.0,
                onToggle: (isOpen) {
                  setState(() {
                    _isFabOpen = isOpen;
                  });
                },
                children: [
                  ActionButton(
                    onPressed: () => _handleAction('Другой день'),
                    icon: Icons.calendar_month_rounded,
                    label: 'Другой день',
                  ),
                  ActionButton(
                    onPressed: () => _handleAction('Сейчас'),
                    icon: Icons.access_time_filled_rounded,
                    label: 'Сейчас',
                    topLabel: 'Создать запись',
                  ),
                  ActionButton(
                    onPressed: () => _handleAction('Сегодня'),
                    icon: Icons.today_rounded,
                    label: 'Сегодня',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(String action) {
    print('Выбрано: $action');
    _fabKey.currentState?.toggle();
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

            await _diaryService.saveMood(dateId, period, score);
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

            await _diaryService.saveSleep(dateId, sleepValue);
          },
        );
      },
    );
  }
}
