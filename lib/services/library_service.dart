import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import 'epub_parser_service.dart';

class LibraryService {
  static const String _booksKey = 'epub_reader_books';

  List<Book> _books = [];
  List<Book> get books => List.unmodifiable(_books);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final booksJson = prefs.getStringList(_booksKey) ?? [];
    _books = booksJson.map((json) => Book.fromJson(json)).toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final booksJson = _books.map((book) => book.toJson()).toList();
    await prefs.setStringList(_booksKey, booksJson);
  }

  Future<Book?> importBook(String epubPath) async {
    try {
      final book = await EPUBParserService.parse(epubPath);
      _books.add(book);
      await _save();
      return book;
    } catch (e) {
      print('Error importing book: $e');
      return null;
    }
  }

  Future<void> removeBook(String bookId) async {
    _books.removeWhere((book) => book.id == bookId);
    await _save();
  }

  Future<void> updateBookProgress(String bookId, int chapterIndex, int position) async {
    final index = _books.indexWhere((book) => book.id == bookId);
    if (index != -1) {
      _books[index] = _books[index].copyWith(
        lastReadChapter: chapterIndex,
        lastReadPosition: position,
      );
      await _save();
    }
  }

  Book? getBook(String bookId) {
    try {
      return _books.firstWhere((book) => book.id == bookId);
    } catch (e) {
      return null;
    }
  }
}
