import 'package:flutter_test/flutter_test.dart';
import 'package:juego/data/database/database.dart';
import 'package:juego/data/repositories/game_repository.dart';
import 'package:juego/main.dart';

void main() {
  testWidgets('Flujo de Splash a Menú Principal', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();
    final repo = GameRepository(db);

    await tester.pumpWidget(DungeonSurvivorApp(repository: repo));
    await tester.pump();

    // En la Splash Screen inicial
    expect(find.text('SHADOW VAULT'), findsOneWidget);
    expect(find.text('CARGANDO...'), findsOneWidget);

    // Avanzar los 5 segundos de carga del Splash
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    // Avanzar la duración de la transición de página (600ms)
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    // Verificar que estamos en el Menú Principal
    expect(find.text('ENTRAR A LA MAZMORRA'), findsOneWidget);
    expect(find.text('TALLER DE MEJORAS'), findsOneWidget);
    expect(find.text('RÉCORDS Y ESTADÍSTICAS'), findsOneWidget);
    expect(find.text('AJUSTES Y DIFICULTAD'), findsOneWidget);

    await db.close();
  });
}
