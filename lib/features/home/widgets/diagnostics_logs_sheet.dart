import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/app_logger.dart';

/// Modal bottom sheet displaying persistent on-device logs for real-device
/// debugging without requiring an emulator or USB cable.
class DiagnosticsLogsSheet extends StatefulWidget {
  const DiagnosticsLogsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: AppRadius.sheetShape,
      builder: (_) => const DiagnosticsLogsSheet(),
    );
  }

  @override
  State<DiagnosticsLogsSheet> createState() => _DiagnosticsLogsSheetState();
}

class _DiagnosticsLogsSheetState extends State<DiagnosticsLogsSheet> {
  List<String> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final logs = await AppLogger.getLogs();
    if (mounted) {
      setState(() {
        _logs = logs;
        _loading = false;
      });
    }
  }

  Future<void> _copyAll() async {
    await Clipboard.setData(ClipboardData(text: _logs.join('\n')));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _clear() async {
    await AppLogger.clearLogs();
    if (mounted) {
      setState(() => _logs = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.terminal_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Text(
                        'Device Diagnostics Logs',
                        style: AppTypography.title3(),
                      ),
                    ),
                    if (_logs.isNotEmpty) ...[
                      IconButton(
                        tooltip: 'Copy all logs',
                        onPressed: _copyAll,
                        icon: const Icon(Icons.copy_rounded, size: 20),
                      ),
                      IconButton(
                        tooltip: 'Clear logs',
                        onPressed: _clear,
                        icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'On-device camera & TFLite runtime logs (persisted offline).',
                  style: AppTypography.footnote(),
                ),
                const SizedBox(height: AppSpacing.m),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _logs.isEmpty
                          ? Center(
                              child: Text(
                                'No logs recorded yet.',
                                style: AppTypography.subheadline(),
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.m),
                              decoration: BoxDecoration(
                                color: AppColors.textPrimary,
                                borderRadius: AppRadius.borderButton,
                              ),
                              child: ListView.separated(
                                controller: scrollController,
                                itemCount: _logs.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(color: Colors.white12, height: 10),
                                itemBuilder: (context, index) {
                                  final line = _logs[index];
                                  final isErr = line.contains('[ERROR]');
                                  final isWarn = line.contains('[WARN]');
                                  return SelectableText(
                                    line,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11.5,
                                      color: isErr
                                          ? const Color(0xFFFCA5A5)
                                          : isWarn
                                              ? const Color(0xFFFDE047)
                                              : Colors.white.withAlpha(220),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
