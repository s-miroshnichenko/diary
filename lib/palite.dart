import 'package:flutter/material.dart';

Color getMoodColor(int score) {
  switch (score) {
    // 🥶 Зона спада и замедления (Холодные, тяжелые оттенки)
    case 1: return const Color(0xFF1A237E); // Deep Indigo (Полный крах)
    case 2: return const Color(0xFF3949AB); // Indigo (Тяжело и темно)
    case 3: return const Color(0xFF5C6BC0); // Light Indigo (Вязкая апатия)
    case 4: return const Color(0xFF26A69A); // Teal (Функциональный спад / Батарея садится)
    
    // 🌿 Зона нормы и баланса (Спокойные, природные оттенки)
    case 5: return const Color(0xFF4DB6AC); // Light Teal (Нейтралитет / Ровный фон)
    case 6: return const Color(0xFF81C784); // Light Green (Активная норма / Вовлеченность)
    
    // 🔥 Зона подъема и перегрева (Теплые, сигнальные оттенки)
    case 7: return const Color(0xFFFFB300); // Amber (Светлый подъем / Инициативность)
    case 8: return const Color(0xFFFB8C00); // Orange (Разгон / Гиперактивность)
    case 9: return const Color(0xFFE53935); // Red (Перегрев / Дисфория)
    case 10: return const Color(0xB71C1C); // Dark Red / Crimson (Потеря контроля / Мания)
    
    default: return Colors.grey;
  }
}
