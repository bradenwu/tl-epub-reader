import 'package:flutter/material.dart';
import 'package:epub_reader/screens/library_screen.dart';
import 'package:epub_reader/theme/app_theme.dart';

void main() {
  runApp(const EPUBReaderApp());
}

class EPUBReaderApp extends StatelessWidget {
  const EPUBReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EPUB Reader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LibraryScreen(),
    );
  }
}
