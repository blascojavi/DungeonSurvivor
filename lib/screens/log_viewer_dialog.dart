import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/log_manager.dart';

class LogViewerDialog extends StatefulWidget {
  const LogViewerDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const LogViewerDialog(),
    );
  }

  @override
  State<LogViewerDialog> createState() => _LogViewerDialogState();
}

class _LogViewerDialogState extends State<LogViewerDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _copyToClipboard() {
    final text = LogManager.getFormattedLogs();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Logs copiados al portapapeles! Puedes pegarlos en el chat.'),
        backgroundColor: Color(0xFF00E5FF),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logs = LogManager.logs;

    return Dialog(
      backgroundColor: const Color(0xFF0D121F),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxHeight: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.terminal, color: Color(0xFF00E5FF), size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'REGISTRO DE ERRORES / LOGS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Historial en tiempo real de eventos, jefes y excepciones de Flutter:',
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
            const SizedBox(height: 12),

            // Ventana de logs estilo terminal
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF060910),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: logs.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay registros guardados.',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      )
                    : Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            final isError = log.contains('ERROR') || log.contains('CRITICAL') || log.contains('EXCEPTION');
                            final isBoss = log.contains('Malakor') || log.contains('Jefe');

                            Color logColor = Colors.white70;
                            if (isError) {
                              logColor = const Color(0xFFFF5252);
                            } else if (isBoss) {
                              logColor = const Color(0xFFFFD700);
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1.5),
                              child: Text(
                                log,
                                style: TextStyle(
                                  color: logColor,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  height: 1.3,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Botones inferiores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      LogManager.clear();
                    });
                  },
                  icon: const Icon(Icons.delete_sweep, color: Colors.white54, size: 16),
                  label: const Text(
                    'LIMPIAR',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _copyToClipboard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text(
                    'COPIAR LOGS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
