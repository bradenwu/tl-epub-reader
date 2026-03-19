import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/book.dart';
import '../models/chapter_content.dart';
import '../services/library_service.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;
  final LibraryService libraryService;

  const ReaderScreen({
    super.key,
    required this.book,
    required this.libraryService,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late int _currentChapterIndex;
  late Book _book;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _currentChapterIndex = _book.lastReadChapter;
  }

  ChapterContent get _currentChapter => _book.spine[_currentChapterIndex];

  void _goToChapter(int index) {
    if (index >= 0 && index < _book.spine.length) {
      setState(() => _currentChapterIndex = index);
      _saveProgress();
    }
  }

  void _previousChapter() {
    if (_currentChapterIndex > 0) {
      _goToChapter(_currentChapterIndex - 1);
    }
  }

  void _nextChapter() {
    if (_currentChapterIndex < _book.spine.length - 1) {
      _goToChapter(_currentChapterIndex + 1);
    }
  }

  void _saveProgress() {
    widget.libraryService.updateBookProgress(
      _book.id,
      _currentChapterIndex,
      0,
    );
  }

  Future<void> _copyChapterText() async {
    final text = _currentChapter.text;
    await Clipboard.setData(ClipboardData(text: text));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已复制本章全部文本'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _book.title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Copy button - key feature!
          IconButton(
            onPressed: _copyChapterText,
            icon: const Icon(Icons.copy),
            tooltip: '复制本章全部文本',
          ),
          IconButton(
            onPressed: () => _showTOCDialog(context),
            icon: const Icon(Icons.list),
            tooltip: '目录',
          ),
        ],
      ),
      body: isWideScreen
          ? _buildWideLayout()
          : _buildNarrowLayout(),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Left: TOC sidebar
        SizedBox(
          width: 280,
          child: _buildTOCSidebar(),
        ),
        const VerticalDivider(width: 1),
        // Right: Content
        Expanded(
          child: _buildContentArea(),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return _buildContentArea();
  }

  Widget _buildTOCSidebar() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListView.builder(
        itemCount: _book.spine.length,
        itemBuilder: (context, index) {
          final chapter = _book.spine[index];
          final isSelected = index == _currentChapterIndex;

          return ListTile(
            title: Text(
              chapter.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
            selected: isSelected,
            onTap: () => _goToChapter(index),
          );
        },
      ),
    );
  }

  Widget _buildContentArea() {
    return Column(
      children: [
        // Chapter content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SelectableText(
              _currentChapter.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    height: 1.8,
                  ),
            ),
          ),
        ),
        // Navigation bar
        _buildNavigationBar(),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          // Previous button
          IconButton(
            onPressed: _currentChapterIndex > 0 ? _previousChapter : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: '上一章',
          ),
          // Progress indicator
          Expanded(
            child: Center(
              child: Text(
                '${_currentChapterIndex + 1} / ${_book.spine.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          // Next button
          IconButton(
            onPressed: _currentChapterIndex < _book.spine.length - 1
                ? _nextChapter
                : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: '下一章',
          ),
        ],
      ),
    );
  }

  void _showTOCDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '目录',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _book.spine.length,
                itemBuilder: (context, index) {
                  final chapter = _book.spine[index];
                  final isSelected = index == _currentChapterIndex;

                  return ListTile(
                    title: Text(
                      chapter.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    selected: isSelected,
                    onTap: () {
                      Navigator.pop(context);
                      _goToChapter(index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
