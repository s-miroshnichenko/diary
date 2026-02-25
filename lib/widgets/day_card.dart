// Файл: lib/widgets/day_card.dart
import 'package:flutter/material.dart';

class DayCard extends StatelessWidget {
  final int dayIndex;
  
  // Данные для слотов (если null, значит слот пустой и ждет заполнения)
  final double? sleepHours;
  final Color? morningMoodColor;
  final Color? dayMoodColor;
  final Color? eveningMoodColor;

  // Коллбэки для нажатия на слоты
  final VoidCallback onAddSleep;
  final VoidCallback onAddMorning;
  final VoidCallback onAddDay;
  final VoidCallback onAddEvening;

  const DayCard({
    Key? key,
    required this.dayIndex,
    this.sleepHours,
    this.morningMoodColor,
    this.dayMoodColor,
    this.eveningMoodColor,
    required this.onAddSleep,
    required this.onAddMorning,
    required this.onAddDay,
    required this.onAddEvening,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // В реальном приложении здесь будет логика форматирования даты
    String dateLabel = dayIndex == 0 ? 'Сегодня' : dayIndex == 1 ? 'Вчера' : 'Несколько дней назад';

    // Выделяем карточку "Сегодня" визуально
    final isToday = dayIndex == 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isToday ? 4 : 0, // "Сегодня" более выпуклая
      shadowColor: isToday ? Colors.black.withValues(alpha: 0.1) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isToday ? Colors.blue.shade100 : Colors.grey.shade200, 
          width: isToday ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: isToday ? 20 : 16, // У "Сегодня" шрифт крупнее
                    color: Colors.black87,
                  ),
                ),
                if (isToday)
                  Text(
                    'Заполни день',
                    style: TextStyle(fontSize: 14, color: Colors.blue.shade600, fontWeight: FontWeight.w500),
                  ),
              ],
            ),
            SizedBox(height: isToday ? 24 : 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Сон
                _TimeSlot(
                  label: 'Сон',
                  isEmpty: sleepHours == null,
                  valueText: sleepHours != null ? '${sleepHours} ч' : null,
                  filledColor: Colors.indigo.shade400,
                  onTap: onAddSleep,
                ),
                // Утро
                _TimeSlot(
                  label: 'Утро',
                  isEmpty: morningMoodColor == null,
                  filledIcon: Icons.sentiment_satisfied_alt_rounded, // Можно менять иконку в зависимости от цвета/настроения
                  filledColor: morningMoodColor,
                  onTap: onAddMorning,
                ),
                // День
                _TimeSlot(
                  label: 'День',
                  isEmpty: dayMoodColor == null,
                  filledIcon: Icons.sentiment_satisfied_alt_rounded,
                  filledColor: dayMoodColor,
                  onTap: onAddDay,
                ),
                // Вечер
                _TimeSlot(
                  label: 'Вечер',
                  isEmpty: eveningMoodColor == null,
                  filledIcon: Icons.sentiment_satisfied_alt_rounded,
                  filledColor: eveningMoodColor,
                  onTap: onAddEvening,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Внутренний виджет для кликабельного слота (оставляем с подчеркиванием, так как используется только здесь)
class _TimeSlot extends StatelessWidget {
  final String label;
  final bool isEmpty;
  final String? valueText;
  final IconData? filledIcon;
  final Color? filledColor;
  final VoidCallback onTap;

  const _TimeSlot({
    required this.label,
    required this.isEmpty,
    this.valueText,
    this.filledIcon,
    this.filledColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 48, // Чуть меньше, чем в InteractiveTodayCard, чтобы влезало на все экраны
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEmpty ? Colors.grey.shade50 : filledColor,
              border: isEmpty ? Border.all(color: Colors.grey.shade300, width: 2) : null,
              boxShadow: isEmpty ? null : [
                BoxShadow(
                  color: filledColor!.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Center(
              child: isEmpty
                  ? Icon(Icons.add_rounded, color: Colors.grey.shade400, size: 24)
                  : (valueText != null
                      ? Text(valueText!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))
                      : Icon(filledIcon ?? Icons.check_rounded, color: Colors.white, size: 24)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isEmpty ? FontWeight.normal : FontWeight.bold,
              color: isEmpty ? Colors.grey.shade500 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
