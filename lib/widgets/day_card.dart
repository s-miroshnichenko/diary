// Файл: lib/widgets/day_card.dart
import 'package:flutter/material.dart';
import '../utils/date_formatter.dart'; 

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

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormatter.formatCardDate(dateId);
    final multiLineDate = formattedDate.replaceFirst(', ', '\n');
    
    final now = DateTime.now();
    final todayString = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final isToday = dateId == todayString;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: isToday ? 4 : 0,
      shadowColor: isToday ? Colors.black.withValues(alpha: 0.1) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isToday ? Colors.blue.shade100 : Colors.grey.shade200,
          width: isToday ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        // Если это не сегодня (нет подписей), делаем нижний отступ еще меньше!
        padding: EdgeInsets.only(
          left: 14.0, 
          right: 14.0, 
          top: 12.0, 
          bottom: isToday ? 12.0 : 8.0, 
        ),
        child: Row(
          crossAxisAlignment: isToday ? CrossAxisAlignment.end : CrossAxisAlignment.center, 
          children: [
            // --- ЛЕВЫЙ БЛОК: ДАТА ---
            SizedBox(
              width: 75, 
              child: Padding(
                // Немного приподнимаем дату, если нет подписей, чтобы она была по центру кружков
                padding: EdgeInsets.only(bottom: isToday ? 16.0 : 0),
                child: Text(
                  multiLineDate,
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                    color: isToday ? Colors.blue.shade700 : Colors.grey.shade500,
                    height: 1.4,
                    letterSpacing: 0.5,
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
                      label: 'Сон',
                      showLabel: isToday, // Показываем подпись только сегодня
                      isEmpty: sleepHours == null,
                      valueText: sleepHours != null
                          ? '${sleepHours! % 1 == 0 ? sleepHours!.toInt() : sleepHours}ч'
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
    // Проверяем, является ли значение оценкой 5, 6 или 7
    final bool isLightShade = ['5', '6', '7'].contains(valueText);
    // Назначаем темно-серый цвет для светлых оттенков, иначе белый
    final Color textColor = isLightShade ? Colors.grey.shade800 : Colors.white;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEmpty ? Colors.grey.shade50 : filledColor,
                border: isEmpty ? Border.all(color: Colors.grey.shade300, width: 1.5) : null,
                boxShadow: isEmpty ? null : [
                  BoxShadow(
                    color: filledColor!.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
            ),
            child: Center(
              child: isEmpty
                  ? Icon(Icons.add_rounded, color: Colors.grey.shade400, size: 20)
                  : (valueText != null
                      ? Text(
                          valueText!,
                          style: TextStyle(
                            color: textColor, // Используем вычисленный цвет
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
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
                color: isEmpty ? Colors.grey.shade400 : Colors.black87,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
