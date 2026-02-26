// Файл: lib/screens/home_screen.dart

import 'package:flutter/material.dart';

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
    final todayId = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final records = await _diaryService.getRecordsForMonth(yearMonth);

    final Map<String, Map<String, dynamic>> newRecordsMap = {};
    for (var record in records) {
      newRecordsMap[record['date_id']] = record;
    }

    // Гарантируем, что карточка "Сегодня" всегда есть в списке
    if (!newRecordsMap.containsKey(todayId)) {
      newRecordsMap[todayId] = {'date_id': todayId};
    }

    setState(() {
      _diaryRecords = newRecordsMap;
      _isLoading = false;
    });
  }

  // Метод для вызова календаря и загрузки выбранного дня
  Future<void> _pickDateAndOpen(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020), // Можно настроить, с какого года работает дневник
      lastDate: DateTime.now(),  // Запрещаем выбирать даты из будущего
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo.shade400, // Цвет шапки календаря
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final dateId = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

      // Если этой даты еще нет в нашей ленте, скачиваем её из БД
      if (!_diaryRecords.containsKey(dateId)) {
        // Показываем снекбар, чтобы юзер понимал, что идет загрузка
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Загрузка данных за ${pickedDate.day}...'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );

        final record = await _diaryService.getRecordForDate(dateId);
        
        setState(() {
          // Если запись есть в БД - берем её. Если нет - создаем пустую заготовку.
          _diaryRecords[dateId] = record ?? {'date_id': dateId};
        });
      }
      
      // Поскольку ключи (даты) сортируются в ленте автоматически, 
      // выбранная карточка просто появится на своем хронологическом месте.
    }
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
    // Сортируем даты по убыванию (от новых к старым)
    final sortedDates = _diaryRecords.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Дневник'),
        // Код вашего AppBar
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 16), // Уменьшили отступ снизу
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
      // НОВОЕ: Простая и красивая кнопка (FAB) для календаря
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickDateAndOpen(context),
        backgroundColor: Colors.indigo.shade400,
        elevation: 4,
        child: const Icon(Icons.calendar_month_rounded, color: Colors.white),
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
