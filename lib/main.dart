import 'package:flutter/material.dart';
// Импортируем файл с нашим экраном (путь зависит от названия вашего проекта)
// Если ваш проект называется diary, то путь будет 'package:diary/screens/onboarding_screen.dart'
// Но проще использовать относительный путь:
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MoodDiaryApp());
}

class MoodDiaryApp extends StatelessWidget {
  const MoodDiaryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Дневник Настроения',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
      ),
      // Указываем наш виджет OnboardingLoginScreen из импортированного файла
      home: const HomeScreen(), 
    );
  }
}
