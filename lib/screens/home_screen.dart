// Файл: lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/expandable_fab.dart';
import '../widgets/day_card.dart';
import '../widgets/sleep_input_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ExpandableFabState> _fabKey = GlobalKey<ExpandableFabState>();
  bool _isFabOpen = false;

  // ДОБАВЛЕНО: Мапа для хранения введенных данных о сне для каждого дня
  final Map<int, double> _sleepData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Дневник', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Лента дней
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 140, top: 16),
            itemCount: 7,
            itemBuilder: (context, index) {
              
              // Ищем сохраненный сон в мапе. Если его нет — используем твои моковые данные.
              // Сделаем для "Сегодня" (index == 0) значение null по умолчанию, чтобы было что заполнять
              double? currentSleep = _sleepData.containsKey(index) 
                  ? _sleepData[index] 
                  : (index == 0 ? null : 8.0 - (index * 0.2));

              return DayCard(
                dayIndex: index,
                sleepHours: currentSleep, // ИСПОЛЬЗУЕМ ПЕРЕМЕННУЮ ЗДЕСЬ
                morningMoodColor: index % 2 == 0 ? Colors.green.shade400 : Colors.blue.shade300,
                dayMoodColor: index == 0 ? null : Colors.green.shade500,
                eveningMoodColor: index == 0 ? null : Colors.orange.shade400,
                onAddSleep: () => _openInputBottomSheet(context, index, 'Сон'),
                onAddMorning: () => _openInputBottomSheet(context, index, 'Утро'),
                onAddDay: () => _openInputBottomSheet(context, index, 'День'),
                onAddEvening: () => _openInputBottomSheet(context, index, 'Вечер'),
              );
            },
          ),

          // 2. Затемнение экрана (Overlay)
          AnimatedOpacity(
            opacity: _isFabOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: _isFabOpen
                ? GestureDetector(
                    onTap: () {
                      _fabKey.currentState?.toggle();
                    },
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.85),
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // 3. Радиальное меню (ExpandableFab)
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

  // Метод, который вызывается при клике на пустой слот в карточке дня
  void _openInputBottomSheet(BuildContext context, int dayIndex, String period) {
    print('Открываем форму для: $period, день: $dayIndex');
    
    // ДОБАВЛЕНО: Маршрутизация в зависимости от выбранного периода
    if (period == 'Сон') {
      _openSleepInput(context, dayIndex);
    } else {
      // TODO: В будущем здесь будут вызовы для _openMoodInput(context, dayIndex, period)
    }
  }

  // Обновленный метод _openSleepInput (теперь принимает dayIndex)
  void _openSleepInput(BuildContext context, int dayIndex) {
    // Если для этого дня уже есть данные, показываем их как стартовые
    double initialValue = _sleepData[dayIndex] ?? 8.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SleepInputSheet(
          initialSleep: initialValue,
          onSave: (sleepValue) {
            print('Пользователь спал: $sleepValue часов в день $dayIndex');
            
            // ДОБАВЛЕНО: Обновляем состояние экрана
            setState(() {
              _sleepData[dayIndex] = sleepValue;
            });
            
            // TODO: Здесь вызовем SupabaseDiaryService.saveSleep(...)
          },
        );
      },
    );
  }
}