import 'package:flutter/material.dart';
import '../widgets/expandable_fab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Ключ для управления нашим ExpandableFab извне
  final GlobalKey<ExpandableFabState> _fabKey = GlobalKey<ExpandableFabState>();
  
  // Состояние затемнения экрана
  bool _isFabOpen = false;

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
            padding: const EdgeInsets.only(bottom: 140, top: 16), // Отступ больше, чтобы не перекрывать меню
            itemCount: 7,
            itemBuilder: (context, index) {
              return _DayCard(
                dayIndex: index,
                morningMood: index % 2 == 0 ? Colors.green.shade400 : Colors.blue.shade300,
                dayMood: Colors.green.shade500,
                eveningMood: Colors.orange.shade400,
                sleepHours: 7.5 - (index * 0.5),
              );
            },
          ),

          // 2. Затемнение экрана (Overlay)
          // Появляется с плавной анимацией
          AnimatedOpacity(
            opacity: _isFabOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: _isFabOpen
                ? GestureDetector(
                    onTap: () {
                      _fabKey.currentState?.toggle();
                    },
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.85), // Сделали фон намного темнее
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // 3. Радиальное меню
          // Внутри _HomeScreenState -> build -> Stack (блок 3. Радиальное меню)
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
    // Закрываем меню после выбора действия
    _fabKey.currentState?.toggle();
    
    // TODO: Здесь будет навигация на экран создания записи
  }
}

// Отдельный виджет для карточки дня (чтобы код был чистым)
class _DayCard extends StatelessWidget {
  final int dayIndex;
  final Color morningMood;
  final Color dayMood;
  final Color eveningMood;
  final double sleepHours;

  const _DayCard({
    required this.dayIndex,
    required this.morningMood,
    required this.dayMood,
    required this.eveningMood,
    required this.sleepHours,
  });

  @override
  Widget build(BuildContext context) {
    // В реальном приложении здесь будет логика форматирования даты
    String dateLabel = dayIndex == 0 ? 'Сегодня' : dayIndex == 1 ? 'Вчера' : 'Несколько дней назад';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0, // Плоский современный дизайн
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200), // Тонкая рамка
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Дата
            Text(
              dateLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            
            // Блок с данными
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Настроение (Утро, День, Вечер)
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MoodDot(color: morningMood, label: 'Утро'),
                      _MoodDot(color: dayMood, label: 'День'),
                      _MoodDot(color: eveningMood, label: 'Вечер'),
                    ],
                  ),
                ),
                
                // Разделитель
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                
                // Сон
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      const Icon(Icons.bedtime_rounded, color: Colors.indigo, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        '${sleepHours} ч',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          // Если сон меньше 5 или больше 10 часов - выделяем красным
                          color: (sleepHours < 5 || sleepHours > 10) ? Colors.red.shade400 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Маленький виджет для точки настроения
class _MoodDot extends StatelessWidget {
  final Color color;
  final String label;

  const _MoodDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
