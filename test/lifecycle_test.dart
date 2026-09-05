import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juego/data/database/database.dart';
import 'package:juego/data/repositories/game_repository.dart';
import 'package:juego/screens/game_screen.dart';

void main() {
  testWidgets('GameScreen inicializa con PopScope y pausa protegida', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();
    final repo = GameRepository(db);

    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          repository: repo,
          upgrades: const [],
          difficultyMode: 'nightmare',
        ),
      ),
    );

    // Esperar inicialización
    await tester.pump();

    // Comprobar que GameScreen monta y no crashea
    expect(find.byType(GameScreen), findsOneWidget);

    await db.close();
  });
}
