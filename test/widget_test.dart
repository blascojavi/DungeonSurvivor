import 'package:flutter_test/flutter_test.dart';
import 'package:juego/data/database/database.dart';
import 'package:juego/data/repositories/game_repository.dart';
import 'package:juego/main.dart';

void main() {
  testWidgets('Carga inicial del Menú Principal', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();
    final repo = GameRepository(db);

    await tester.pumpWidget(DungeonSurvivorApp(repository: repo));
    await tester.pumpAndSettle();

    expect(find.text('SHADOW VAULT'), findsOneWidget);
    expect(find.text('ENTRAR A LA MAZMORRA'), findsOneWidget);
    expect(find.text('TALLER DE MEJORAS'), findsOneWidget);
    expect(find.text('RÉCORDS Y ESTADÍSTICAS'), findsOneWidget);
    expect(find.text('AJUSTES Y DIFICULTAD'), findsOneWidget);

    await db.close();
  });
}
