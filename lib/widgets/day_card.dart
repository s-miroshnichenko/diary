// Файл: lib/widgets/day_card.dart

import 'package:flutter/material.dart';
import '../utils/date_formatter.dart'; 

class DayCard extends StatelessWidget {
  final String dateId;

  // Сон
  final double? sleepHours;

  // Оценки настроения (от 1 до 10)
  final int? morningMoodScore;
  final int? dayMoodScore;
  final int? eveningMoodScore;

  // Цвета настроения
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
    required this.dateId, // Изменено
    this.sleepHours,
    this.morningMoodScore,
    this.dayMoodScore,
    this.eveningMoodScore,
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
    // НОВОЕ: Используем наш форматтер, чтобы получить строку 'СЕГОДНЯ, 25 ФЕВ.'
    final formattedDate = DateFormatter.formatCardDate(dateId);
    
    // НОВОЕ: Проверяем, является ли эта карточка сегодняшней
    // Сравниваем сырую дату из БД с сегодняшней сырой датой
    final now = DateTime.now();
    final todayString = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final isToday = dateId == todayString;

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
            
            // НОВОЕ: Красивая дата (мелкий тонкий шрифт, ALL CAPS)
            Text(
              formattedDate, // Текст из DateFormatter (уже toUpperCase)
              style: const TextStyle(
                fontSize: 11.0,            // Мелкий
                fontWeight: FontWeight.w400, // Тонкий (Regular)
                color: Colors.grey,        // Серый
                letterSpacing: 1.2,        // Межбуквенный интервал для ALL CAPS
              ),
            ),
            
            SizedBox(height: isToday ? 24 : 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Слот: Сон
                _TimeSlot(
                  label: 'Сон',
                  isEmpty: sleepHours == null,
                  valueText: sleepHours != null
                      ? '${sleepHours! % 1 == 0 ? sleepHours!.toInt() : sleepHours} ч'
                      : null,
                  filledColor: Colors.indigo.shade400,
                  onTap: onAddSleep,
                ),
                // Слот: Утро
                _TimeSlot(
                  label: 'Утро',
                  isEmpty: morningMoodColor == null,
                  valueText: morningMoodScore?.toString(),
                  filledColor: morningMoodColor,
                  onTap: onAddMorning,
                ),
                // Слот: День
                _TimeSlot(
                  label: 'День',
                  isEmpty: dayMoodColor == null,
                  valueText: dayMoodScore?.toString(),
                  filledColor: dayMoodColor,
                  onTap: onAddDay,
                ),
                // Слот: Вечер
                _TimeSlot(
                  label: 'Вечер',
                  isEmpty: eveningMoodColor == null,
                  valueText: eveningMoodScore?.toString(),
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

// Внутренний виджет остался без изменений
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
            width: 48,
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
                  ? Text(valueText!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
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
