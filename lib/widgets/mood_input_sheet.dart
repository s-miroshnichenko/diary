// Файл: lib/widgets/mood_input_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MoodInputSheet extends StatefulWidget {
  final int initialScore;
  final String period;
  final Function(int) onSave;

  const MoodInputSheet({
    Key? key,
    required this.initialScore,
    required this.period,
    required this.onSave,
  }) : super(key: key);

  @override
  State<MoodInputSheet> createState() => _MoodInputSheetState();
}

class _MoodInputSheetState extends State<MoodInputSheet> {
  late FixedExtentScrollController _scrollController;
  late int _selectedScore;

  // Твоя функция цветов
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

  // Названия состояний
  String getMoodTitle(int score) {
    switch (score) {
      case 1: return 'Полный крах';
      case 2: return 'Тяжело и темно';
      case 3: return 'Вязкая апатия';
      case 4: return 'Функциональный спад';
      case 5: return 'Нейтралитет';
      case 6: return 'Активная норма';
      case 7: return 'Светлый подъем';
      case 8: return 'Гиперактивность';
      case 9: return 'Дисфория';
      case 10: return 'Потеря контроля';
      default: return '';
    }
  }

  // Подробные описания для центрального элемента
  String getMoodDescription(int score) {
    switch (score) {
      case 1: return 'Нет сил даже на базовые вещи. Ощущение безысходности.';
      case 2: return 'Мир кажется враждебным. Все требует огромных усилий.';
      case 3: return 'Нет острой боли, но есть абсолютное равнодушие.';
      case 4: return 'Делаю только то, что обязан, и только через силу.';
      case 5: return 'Ровный фон. Ни хорошо, ни плохо, просто обычный день.';
      case 6: return 'Есть энергия на дела и общение. Стабильное состояние.';
      case 7: return 'Отличное настроение, много идей, хочется действовать.';
      case 8: return 'Трудно усидеть на месте, мысли скачут, разгон.';
      case 9: return 'Раздражительность, агрессия, сильное внутреннее напряжение.';
      case 10: return 'Импульсивные поступки, эйфория или слепой гнев.';
      default: return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedScore = widget.initialScore;
    // Индекс в массиве начинается с 0, поэтому отнимаем 1 от оценки
    _scrollController = FixedExtentScrollController(initialItem: _selectedScore - 1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Маркер свайпа
          Container(
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Настроение: ${widget.period}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          // Сам барабан
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Визуальная "рамка" выбора в центре
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: getMoodColor(_selectedScore).withValues(alpha: 0.1),
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: getMoodColor(_selectedScore).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                ListWheelScrollView.useDelegate(
                  controller: _scrollController,
                  itemExtent: 70, // Высота каждого элемента
                  physics: const FixedExtentScrollPhysics(), // Магнит к центру
                  perspective: 0.002, // Эффект цилиндра
                  squeeze: 1.2, // Плотность элементов
                  onSelectedItemChanged: (index) {
                    // Тактильный отклик при перещелкивании
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedScore = index + 1; // Индекс от 0 до 9 -> Оценка 1-10
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 10,
                    builder: (context, index) {
                      final score = index + 1;
                      final isSelected = score == _selectedScore;
                      final color = getMoodColor(score);
                      
                      // ИСПОЛЬЗУЕМ СОВРЕМЕННЫЙ AnimatedScale + AnimatedOpacity
                      return AnimatedScale(
                        scale: isSelected ? 1.1 : 0.9,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: AnimatedOpacity(
                          opacity: isSelected ? 1.0 : 0.4,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                                                    child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0), // Отступы по бокам!
                            child: Row(
                              // Убрали mainAxisAlignment: MainAxisAlignment.center
                              children: [
                                // Блок с цифрой фиксированной ширины, чтобы текст не прыгал
                                SizedBox(
                                  width: 40, 
                                  child: Center( // Центрируем цифру внутри её блока
                                    child: Text(
                                      score.toString(),
                                      style: TextStyle(
                                        fontSize: isSelected ? 32 : 24,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    getMoodTitle(score),
                                    style: TextStyle(
                                      fontSize: isSelected ? 20 : 16,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: isSelected ? Colors.black87 : Colors.grey.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Подробное описание под барабаном
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                getMoodDescription(_selectedScore),
                key: ValueKey<int>(_selectedScore),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          
          // Кнопка сохранения
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_selectedScore);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: getMoodColor(_selectedScore),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Сохранить',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}