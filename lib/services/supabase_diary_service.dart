// Файл: lib/services/supabase_diary_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDiaryService {
  final _supabase = Supabase.instance.client;
  final String _table = 'daily_records';

  // ТЕПЕРЬ БЕРЕМ РЕАЛЬНЫЙ ID ИЗ СЕССИИ SUPABASE
  String get currentUserId {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      // Этого не должно происходить, так как мы логинимся в main.dart, 
      // но для безопасности лучше бросить понятное исключение
      throw Exception('Пользователь не авторизован');
    }
    return user.id;
  }

  // --- МЕТОДЫ ЗАПИСИ (UPSERT) ---

  // 1. Сохранить или обновить сон
  Future<void> saveSleep(String dateId, double hours) async {
    await _supabase.from(_table).upsert({
      'user_id': currentUserId, // Привязываем к пользователю
      'date_id': dateId,
      'sleep_hours': hours,
    }, onConflict: 'user_id, date_id'); 
    // ВАЖНО: В Supabase нужно сделать составной Primary Key (user_id + date_id), 
    // чтобы onConflict работал корректно для разных пользователей в один день.
  }

  // 2. Сохранить настроение для определенного времени суток
  Future<void> saveMood(String dateId, String period, int moodValue) async {
    String columnToUpdate = '';
    switch (period) {
      case 'Утро': columnToUpdate = 'morning_mood'; break;
      case 'День': columnToUpdate = 'day_mood'; break;
      case 'Вечер': columnToUpdate = 'evening_mood'; break;
      default: return; // Защита от опечаток
    }

    await _supabase.from(_table).upsert({
      'user_id': currentUserId,
      'date_id': dateId,
      columnToUpdate: moodValue,
    }, onConflict: 'user_id, date_id');
  }

  // 3. Сохранить текстовую заметку для дня
  Future<void> saveNote(String dateId, String noteText) async {
    await _supabase.from(_table).upsert({
      'user_id': currentUserId,
      'date_id': dateId,
      'notes': noteText, 
    }, onConflict: 'user_id, date_id'); 
  }

  // 4. Сохранить массив симптомов/тегов (например: ['тревога', 'головная боль'])
  Future<void> saveSymptoms(String dateId, List<String> symptoms) async {
    await _supabase.from(_table).upsert({
      'user_id': currentUserId,
      'date_id': dateId,
      'symptoms': symptoms, // В Supabase колонка должна быть типа text[] (Array)
    }, onConflict: 'user_id, date_id');
  }


  // --- МЕТОДЫ ЧТЕНИЯ (SELECT) ---

  // 5. Получить данные за один конкретный день (Для открытия карточки дня)
  Future<Map<String, dynamic>?> getRecordForDate(String dateId) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('user_id', currentUserId) // Ищем только для текущего юзера
          .eq('date_id', dateId)
          .maybeSingle(); // Вернет null, если записи за этот день еще нет
      
      return response;
    } catch (e) {
      print('Ошибка при загрузке дня $dateId: $e');
      return null;
    }
  }

  // 6. Получить данные за конкретный месяц (для графиков и списка карточек)
  // yearMonth передается в формате "YYYY-MM" (например, "2023-10")
  Future<List<Map<String, dynamic>>> getRecordsForMonth(String yearMonth) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('user_id', currentUserId) // Фильтр по пользователю ОБЯЗАТЕЛЕН
          .like('date_id', '$yearMonth-%')
          .order('date_id', ascending: false); // Сортировка: новые дни сверху

      return response;
    } catch (e) {
      print('Ошибка при загрузке месяца $yearMonth: $e');
      return []; // Возвращаем пустой список, чтобы UI не упал
    }
  }

  Future<void> saveFullDay({
    required String dateId,
    required double sleepHours,
    required int morningMood,
    required int dayMood,
    required int eveningMood,
  }) async {
    await _supabase.from(_table).upsert({
      'user_id': currentUserId,
      'date_id': dateId,
      'sleep_hours': sleepHours,
      'morning_mood': morningMood,
      'day_mood': dayMood,
      'evening_mood': eveningMood,
    }, onConflict: 'user_id, date_id');
  }
}
