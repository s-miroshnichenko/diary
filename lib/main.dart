// Файл: lib/main.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart'; // Твой путь к экрану

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Инициализируем Supabase
  await Supabase.initialize(
    url: 'https://nrcjdmfxqopucdqowlhe.supabase.co', // Оставь свои ключи
    anonKey: 'sb_publishable_l_LrNG_SY86LhTXU0g3-xw_GRT9qi4f',
  );

  // 2. Проверяем, есть ли уже авторизованный пользователь
  final supabase = Supabase.instance.client;
  
  if (supabase.auth.currentUser == null) {
    // 3. Если пользователя нет, создаем "теневой" (анонимный) аккаунт.
    // Это автоматически сгенерирует уникальный UUID и сохранит сессию на устройстве.
    try {
      await supabase.auth.signInAnonymously();
      print('Создан новый анонимный аккаунт: ${supabase.auth.currentUser?.id}');
    } catch (e) {
      print('Ошибка анонимной авторизации: $e');
    }
  } else {
    print('Пользователь уже авторизован: ${supabase.auth.currentUser?.id}');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Diary',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const HomeScreen(),
    );
  }
}
