import 'package:flutter/material.dart';

class SleepInputSheet extends StatefulWidget {
  final double initialSleep;
  final Function(double) onSave;

  const SleepInputSheet({
    Key? key,
    this.initialSleep = 8.0,
    required this.onSave,
  }) : super(key: key);

  @override
  State<SleepInputSheet> createState() => _SleepInputSheetState();
}

class _SleepInputSheetState extends State<SleepInputSheet> {
  late double _currentSleep;

  @override
  void initState() {
    super.initState();
    _currentSleep = widget.initialSleep;
  }

  void _changeSleep(double amount) {
    setState(() {
      _currentSleep += amount;
      if (_currentSleep < 0) _currentSleep = 0;
      if (_currentSleep > 24) _currentSleep = 24;
    });
  }

  // Метод для красивого отображения чисел без .0
  String _formatSleep(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Сколько часов вы спали?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: Icons.remove_rounded,
                onTap: () => _changeSleep(-0.5),
              ),
              const SizedBox(width: 32),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    _formatSleep(_currentSleep), // Используем форматирование
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              _buildControlButton(
                icon: Icons.add_rounded,
                onTap: () => _changeSleep(0.5),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Быстрые пресеты
          Wrap(
            alignment: WrapAlignment.center, // Выравниваем чипсы по центру по горизонтали
            spacing: 12, // Отступ между чипсами по горизонтали (в одном ряду)
            runSpacing: 12, // Отступ между рядами чипсов (по вертикали)
            children: [5.0, 6.0, 7.0, 8.0, 9.0, 10.0].map((preset) {
              final isSelected = _currentSleep == preset;
              
              return ChoiceChip(
                label: Text(_formatSleep(preset)),
                selected: isSelected,
                showCheckmark: false, // <-- Добавьте это свойство, чтобы скрыть галочку
                onSelected: (selected) {
                  if (selected) setState(() => _currentSleep = preset);
                },
                selectedColor: Colors.indigo.shade100,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.indigo.shade900 : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                // Немного увеличим отступы внутри чипса для лучшей "кликабельности"
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(_currentSleep);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Сохранить',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 32, color: Colors.indigo),
      ),
    );
  }
}
