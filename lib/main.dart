import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/database/database.dart';
import 'data/repositories/game_repository.dart';
import 'screens/main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquear orientación en vertical para experiencia móvil cómoda
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Barra de estado transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF090C12),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Inicializar Base de Datos Local SQLite (Drift)
  final database = AppDatabase();
  final repository = GameRepository(database);

  runApp(DungeonSurvivorApp(repository: repository));
}

class DungeonSurvivorApp extends StatelessWidget {
  final GameRepository repository;

  const DungeonSurvivorApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shadow Vault: Survivor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090C12),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2979FF),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF141A29),
        ),
      ),
      home: MainMenuScreen(repository: repository),
    );
  }
}
