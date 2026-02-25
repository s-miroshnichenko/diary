// Файл: lib/services/supabase_diary_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDiaryService {
  // Получаем доступ к клиенту Supabase
  final _supabase = Supabase.instance.client;
  
  // Название нашей таблицы в облаке
  final String _table = 'daily_records';

  // 1. Сохранить или обновить сон
  Future<void> saveSleep(String dateId, double hours) async {
    // upsert автоматически обновит запись, если date_id уже существует
    await _supabase.from(_table).upsert({
      'date_id': dateId,
      'sleep_hours': hours,
    }, onConflict: 'date_id'); 
  }

  // 2. Сохранить настроение для определенного времени суток
  Future<void> saveMood(String dateId, String period, int moodValue) async {
    String columnToUpdate = '';
    
    switch (period) {
      case 'Утро': columnToUpdate = 'morning_mood'; break;
      case 'День': columnToUpdate = 'day_mood'; break;
      case 'Вечер': columnToUpdate = 'evening_mood'; break;
    }

    await _supabase.from(_table).upsert({
      'date_id': dateId,
      columnToUpdate: moodValue,
    }, onConflict: 'date_id');
  }

  // 3. Получить данные за конкретный месяц (для графиков и отчетов)
  Future<List<Map<String, dynamic>>> getRecordsForMonth(String yearMonth) async {
    // Запрашиваем данные, где дата начинается с "YYYY-MM" (например, "2023-10")
    final response = await _supabase
        .from(_table)
        .select()
        .like('date_id', '$yearMonth-%')
        .order('date_id', ascending: false);
        
    return response;
  }
}
