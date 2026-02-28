// Файл: lib/widgets/full_day_input_sheet.dart

import 'package:flutter/material.dart';

class FullDayInputSheet extends StatefulWidget {
  final String dateId;
  final Map<String, dynamic>? initialData;
  final Function(double sleep, int morning, int day, int evening) onSave;

  const FullDayInputSheet({
    Key? key,
    required this.dateId,
    this.initialData,
    required this.onSave,
  }) : super(key: key);

  @override
  State<FullDayInputSheet> createState() => _FullDayInputSheetState();
}

class _FullDayInputSheetState extends State<FullDayInputSheet> {
  late double _sleepHours;
  late int _morningMood;
  late int _dayMood;
  late int _eveningMood;

  final Color primaryTeal = const Color(0xFF4DB6AC);

  final ScrollController _morningScroll = ScrollController(initialScrollOffset: 88.0);
  final ScrollController _dayScroll = ScrollController(initialScrollOffset: 88.0);
  final ScrollController _eveningScroll = ScrollController(initialScrollOffset: 88.0);

  @override
  void initState() {
    super.initState();
    final data = widget.initialData ?? {};
    _sleepHours = data['sleep_hours'] != null ? (data['sleep_hours'] as num).toDouble() : 8.0;
    
    _morningMood = data['morning_mood'] as int? ?? 5;
    _dayMood = data['day_mood'] as int? ?? 5;
    _eveningMood = data['evening_mood'] as int? ?? 5;
  }

  @override
  void dispose() {
    _morningScroll.dispose();
    _dayScroll.dispose();
    _eveningScroll.dispose();
    super.dispose();
  }

  // --- ОБНОВЛЕННАЯ ФУНКЦИЯ ФОРМАТИРОВАНИЯ ДАТЫ ---
  String _formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      final List<String> months = [
        '', 'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
        'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
      ];
      final List<String> weekdays = [
        '', 'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'
      ];
      
      // date.weekday возвращает от 1 (пн) до 7 (вс)
      return '${weekdays[date.weekday]}, ${date.day} ${months[date.month]}';
    } catch (e) {
      return dateStr; 
    }
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

  Widget _buildMoodSelector(String title, int currentValue, ValueChanged<int> onChanged, ScrollController scrollController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(10, (index) {
              final score = index + 1;
              final isSelected = score == currentValue;
              final color = getMoodColor(score);

              return GestureDetector(
                onTap: () => onChanged(score),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: isSelected ? 44 : 36,
                  height: isSelected ? 44 : 36,
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                    boxShadow: isSelected ? [
                      BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))
                    ] : null,
                  ),
                  child: Center(
                    child: Text(
                      score.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : color.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: isSelected ? 18 : 14,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20, 
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // --- ОБНОВЛЕННЫЙ ЗАГОЛОВОК С ДАТОЙ ПО ЦЕНТРУ ---
          Center(
            child: Text(
              _formatDate(widget.dateId),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
            ),
          ),
          const SizedBox(height: 24),

          // --- БЛОК СНА ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Сон', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
              Text(
                '${_sleepHours % 1 == 0 ? _sleepHours.toInt() : _sleepHours} ч',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal),
              ),
            ],
          ),
          
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackShape: const RoundedRectSliderTrackShape(),
              trackHeight: 6.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
            ),
            child: Slider(
              value: _sleepHours,
              min: 0,
              max: 16,
              activeColor: primaryTeal,
              inactiveColor: primaryTeal.withOpacity(0.2),
              onChanged: (val) {
                setState(() => _sleepHours = (val * 2).roundToDouble() / 2);
              },
            ),
          ),
          const SizedBox(height: 16),

          // --- БЛОКИ НАСТРОЕНИЯ ---
          _buildMoodSelector('Утро', _morningMood, (val) => setState(() => _morningMood = val), _morningScroll),
          const SizedBox(height: 20),
          _buildMoodSelector('День', _dayMood, (val) => setState(() => _dayMood = val), _dayScroll),
          const SizedBox(height: 20),
          _buildMoodSelector('Вечер', _eveningMood, (val) => setState(() => _eveningMood = val), _eveningScroll),
          const SizedBox(height: 32),

          // --- КНОПКА СОХРАНИТЬ ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onSave(_sleepHours, _morningMood, _dayMood, _eveningMood),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: const Text('Сохранить день', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
