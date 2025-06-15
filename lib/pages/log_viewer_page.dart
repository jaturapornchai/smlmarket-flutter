import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class LogViewerPage extends StatefulWidget {
  const LogViewerPage({super.key});

  @override
  State<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends State<LogViewerPage> {
  final List<LogEntry> _logs = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _startLogListener();
  }

  void _startLogListener() {
    // เพื่อแสดงตัวอย่าง logs
    _addSampleLogs();
  }

  void _addSampleLogs() {
    final sampleLogs = [
      LogEntry(
        message: '🚀 Starting search process for query: "toyota"',
        name: 'SearchBloc',
        time: DateTime.now().subtract(const Duration(seconds: 5)),
        level: LogLevel.info,
      ),
      LogEntry(
        message: '🤖 Starting DeepSeek query enhancement for: "toyota"',
        name: 'DeepSeekService',
        time: DateTime.now().subtract(const Duration(seconds: 4)),
        level: LogLevel.info,
      ),
      LogEntry(
        message: '✨ Query enhanced: "toyota" → "toyota โตโยต้า"',
        name: 'DeepSeekService',
        time: DateTime.now().subtract(const Duration(seconds: 3)),
        level: LogLevel.info,
      ),
      LogEntry(
        message: '🔍 Starting product search',
        name: 'ProductRepository',
        time: DateTime.now().subtract(const Duration(seconds: 2)),
        level: LogLevel.info,
      ),
      LogEntry(
        message: '✅ API response success (200)',
        name: 'ProductRepository',
        time: DateTime.now().subtract(const Duration(seconds: 1)),
        level: LogLevel.info,
      ),
      LogEntry(
        message: '🎯 Parsed 15 products from 150 total',
        name: 'ProductRepository',
        time: DateTime.now(),
        level: LogLevel.info,
      ),
    ];

    setState(() {
      _logs.addAll(sampleLogs);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Logs'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearLogs,
            tooltip: 'Clear logs',
          ),
          IconButton(
            icon: const Icon(Icons.vertical_align_bottom),
            onPressed: _scrollToBottom,
            tooltip: 'Scroll to bottom',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.surface,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Real-time API logs for debugging',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  '${_logs.length} logs',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No logs yet',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Perform a search to see API logs',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondary.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return _buildLogItem(log);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(LogEntry log) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassmorphismCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildLogLevelIcon(log.level),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    log.message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    log.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(log.time),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return Icon(Icons.info_outline, color: Colors.blue, size: 16);
      case LogLevel.warning:
        return Icon(
          Icons.warning_amber_outlined,
          color: Colors.orange,
          size: 16,
        );
      case LogLevel.error:
        return Icon(Icons.error_outline, color: Colors.red, size: 16);
      case LogLevel.debug:
        return Icon(Icons.bug_report_outlined, color: Colors.grey, size: 16);
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }
}

class LogEntry {
  final String message;
  final String name;
  final DateTime time;
  final LogLevel level;

  LogEntry({
    required this.message,
    required this.name,
    required this.time,
    required this.level,
  });
}

enum LogLevel { info, warning, error, debug }
