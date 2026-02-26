import 'package:flutter/material.dart';
// Импортируем файл с нашим экраном (путь зависит от названия вашего проекта)
// Если ваш проект называется diary, то путь будет 'package:diary/screens/onboarding_screen.dart'
// Но проще использовать относительный путь:
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализируем русскую локаль для дат
  await initializeDateFormatting('ru', null);
  
  // Подключаемся к нашему облаку
  await Supabase.initialize(
    url: 'https://nrcjdmfxqopucdqowlhe.supabase.co',
    anonKey: 'sb_publishable_l_LrNG_SY86LhTXU0g3-xw_GRT9qi4f',
  );

  runApp(const MoodDiaryApp());
}

class MoodDiaryApp extends StatelessWidget {
  const MoodDiaryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Дневник Настроения',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', 'RU'), // Русский
        Locale('en', 'US'), // Английский (оставьте как запасной)
        // Сюда можно будет дописать другие языки: Locale('es', ''), Locale('de', '') и т.д.
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color.fromARGB(209, 255, 255, 255),
      ),
      // Указываем наш виджет OnboardingLoginScreen из импортированного файла
      home: const HomeScreen(), 
    );
  }
}
