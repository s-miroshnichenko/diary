// Файл: lib/widgets/day_card.dart

import 'package:flutter/material.dart';

class DayCard extends StatelessWidget {
  final String dateId;
  final double? sleepHours;
  final int? morningMoodScore;
  final int? dayMoodScore;
  final int? eveningMoodScore;
  final Color? morningMoodColor;
  final Color? dayMoodColor;
  final Color? eveningMoodColor;
  final VoidCallback onAddSleep;
  final VoidCallback onAddMorning;
  final VoidCallback onAddDay;
  final VoidCallback onAddEvening;

  const DayCard({
    Key? key,
    required this.dateId,
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

  /// Функция для форматирования даты в нужный нам вид:
  /// "СЕГОДНЯ, 27 ФЕВ.", "ВЧЕРА, 26 ФЕВ.", "СРЕДА, 25 ФЕВ."
  String _getFormattedDateString(String dateId) {
    try {
      final parts = dateId.split('-');
      if (parts.length != 3) return dateId;

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      final date = DateTime(year, month, day);
      final now = DateTime.now();
      
      // Обнуляем время для корректного расчета разницы в днях
      final today = DateTime(now.year, now.month, now.day);
      final dateToCompare = DateTime(date.year, date.month, date.day);

      final difference = today.difference(dateToCompare).inDays;

      String prefix;
      if (difference == 0) {
        prefix = 'СЕГОДНЯ';
      } else if (difference == 1) {
        prefix = 'ВЧЕРА';
      } else {
        const weekDays = [
          '', 'ПОНЕДЕЛЬНИК', 'ВТОРНИК', 'СРЕДА', 'ЧЕТВЕРГ',
          'ПЯТНИЦА', 'СУББОТА', 'ВОСКРЕСЕНЬЕ'
        ];
        prefix = weekDays[date.weekday];
      }

      const months = [
        '', 'ЯНВ.', 'ФЕВ.', 'МАР.', 'АПР.', 'МАЯ', 'ИЮН.',
        'ИЮЛ.', 'АВГ.', 'СЕН.', 'ОКТ.', 'НОЯБ.', 'ДЕК.'
      ];
      final monthStr = months[month];

      return '$prefix, $day $monthStr';
    } catch (e) {
      return dateId; // Возвращаем как есть в случае ошибки парсинга
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayString = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final isToday = dateId == todayString;

    // Генерируем нужную строку и заменяем запятую на перенос строки
    final formattedDate = _getFormattedDateString(dateId);
    final multiLineDate = formattedDate.replaceFirst(', ', '\n');

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: isToday ? 4 : 1,
      shadowColor: isToday
          ? Colors.black.withValues(alpha: 0.15)
          : Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isToday ? Colors.blue.shade200 : Colors.grey.shade200,
          width: isToday ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 14.0,
          right: 14.0,
          top: 12.0,
          bottom: 12.0,
        ),
        child: Row(
          crossAxisAlignment: isToday ? CrossAxisAlignment.end : CrossAxisAlignment.center,
          children: [
            // --- ЛЕВЫЙ БЛОК: ДАТА ---
            SizedBox(
              width: 75,
              child: Padding(
                padding: EdgeInsets.only(bottom: isToday ? 16.0 : 0),
                child: FittedBox(
                  fit: BoxFit.scaleDown, // Поможет длинным дням (ПОНЕДЕЛЬНИК) влезть в 75 пикселей
                  alignment: Alignment.centerLeft,
                  child: Text(
                    multiLineDate,
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                      color: isToday ? Colors.blue.shade700 : Colors.grey.shade700,
                      height: 1.4,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            // --- ПРАВЫЙ БЛОК: КРУЖКИ В СЕТКЕ ---
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _TimeSlot(
                      label: 'Сон, ч',
                      showLabel: isToday,
                      isEmpty: sleepHours == null,
                      valueText: sleepHours != null
                          ? '${sleepHours! % 1 == 0 ? sleepHours!.toInt() : sleepHours}'
                          : null,
                      filledColor: Colors.indigo.shade400,
                      onTap: onAddSleep,
                    ),
                  ),
                  Expanded(
                    child: _TimeSlot(
                      label: 'Утро',
                      showLabel: isToday,
                      isEmpty: morningMoodColor == null,
                      valueText: morningMoodScore?.toString(),
                      filledColor: morningMoodColor,
                      onTap: onAddMorning,
                    ),
                  ),
                  Expanded(
                    child: _TimeSlot(
                      label: 'День',
                      showLabel: isToday,
                      isEmpty: dayMoodColor == null,
                      valueText: dayMoodScore?.toString(),
                      filledColor: dayMoodColor,
                      onTap: onAddDay,
                    ),
                  ),
                  Expanded(
                    child: _TimeSlot(
                      label: 'Вечер',
                      showLabel: isToday,
                      isEmpty: eveningMoodColor == null,
                      valueText: eveningMoodScore?.toString(),
                      filledColor: eveningMoodColor,
                      onTap: onAddEvening,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSlot extends StatelessWidget {
  final String label;
  final bool showLabel;
  final bool isEmpty;
  final String? valueText;
  final IconData? filledIcon;
  final Color? filledColor;
  final VoidCallback onTap;

  const _TimeSlot({
    required this.label,
    required this.showLabel,
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEmpty ? Colors.grey.shade50 : filledColor,
              border: isEmpty
                  ? Border.all(color: Colors.grey.shade300, width: 1.5)
                  : Border.all(color: Colors.white, width: 2),
              boxShadow: isEmpty
                  ? null
                  : [
                      BoxShadow(
                        color: filledColor!.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: Center(
              child: isEmpty
                  ? Icon(Icons.add_rounded, color: Colors.grey.shade400, size: 20)
                  : (valueText != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              valueText!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        )
                      : Icon(filledIcon ?? Icons.check_rounded, color: Colors.white, size: 20)),
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: isEmpty ? Colors.grey.shade500 : Colors.black87,
              ),
            )
          ]
        ],
      ),
    );
  }
}
