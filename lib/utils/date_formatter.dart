// Файл: lib/utils/date_formatter.dart

import 'package:intl/intl.dart';

class DateFormatter {
  /// Преобразует строку 'YYYY-MM-DD' в формат 'СЕГОДНЯ, 25 ФЕВ.' или 'ПОНЕДЕЛЬНИК, 23 ФЕВ.'
  static String formatCardDate(String dateString) {
    try {
      // 1. Парсим строку в объект DateTime
      final date = DateTime.parse(dateString);
      final now = DateTime.now();

      // Убираем время, оставляем только даты для корректного сравнения
      final today = DateTime(now.year, now.month, now.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      final yesterday = today.subtract(const Duration(days: 1));

      // 2. Форматируем число и короткий месяц (например, "25 фев.")
      final dayAndMonth = DateFormat('d MMM', 'ru').format(targetDate);

      // 3. Определяем префикс (СЕГОДНЯ, ВЧЕРА или ДЕНЬ НЕДЕЛИ)
      String prefix;
      if (targetDate.isAtSameMomentAs(today)) {
        prefix = 'СЕГОДНЯ';
      } else if (targetDate.isAtSameMomentAs(yesterday)) {
        prefix = 'ВЧЕРА';
      } else {
        // Если это другой день, берем день недели (например, "понедельник")
        prefix = DateFormat('EEEE', 'ru').format(targetDate);
      }

      // 4. Собираем итоговую строку и делаем ВСЕ ЗАГЛАВНЫМИ БУКВАМИ (toUpperCase)
      final result = '$prefix, $dayAndMonth';
      return result.toUpperCase();

    } catch (e) {
      // Если пришла кривая дата, просто возвращаем ее как есть
      return dateString.toUpperCase();
    }
  }
}
