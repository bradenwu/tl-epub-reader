import 'dart:convert';
import 'dart:io';
import 'book_metadata.dart';
import 'chapter_content.dart';
import 'toc_entry.dart';

class Book {
  final String id;
  final BookMetadata metadata;
  final List<ChapterContent> spine;
  final List<TOCEntry> toc;
  final String sourcePath;
  final DateTime addedAt;
  int lastReadChapter;
  int lastReadPosition;

  Book({
    required this.id,
    required this.metadata,
    required this.spine,
    required this.toc,
    required this.sourcePath,
    DateTime? addedAt,
    this.lastReadChapter = 0,
    this.lastReadPosition = 0,
  })  : addedAt = addedAt ?? DateTime.now();

  String get title => metadata.title;
  String get author => metadata.authors.isNotEmpty ? metadata.authors.join(', ') : 'Unknown Author';
  int get chapterCount => spine.length;

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      metadata: BookMetadata.fromMap(map['metadata']),
      spine: (map['spine'] as List)
          .map((e) => ChapterContent.fromMap(e))
          .toList(),
      toc: (map['toc'] as List)
          .map((e) => TOCEntry.fromMap(e))
          .toList(),
      sourcePath: map['sourcePath'],
      addedAt: DateTime.parse(map['addedAt']),
      lastReadChapter: map['lastReadChapter'] ?? 0,
      lastReadPosition: map['lastReadPosition'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'metadata': metadata.toMap(),
      'spine': spine.map((e) => e.toMap()).toList(),
      'toc': toc.map((e) => e.toMap()).toList(),
      'sourcePath': sourcePath,
      'addedAt': addedAt.toIso8601String(),
      'lastReadChapter': lastReadChapter,
      'lastReadPosition': lastReadPosition,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory Book.fromJson(String json) => Book.fromMap(jsonDecode(json));

  Book copyWith({
    String? id,
    BookMetadata? metadata,
    List<ChapterContent>? spine,
    List<TOCEntry>? toc,
    String? sourcePath,
    DateTime? addedAt,
    int? lastReadChapter,
    int? lastReadPosition,
  }) {
    return Book(
      id: id ?? this.id,
      metadata: metadata ?? this.metadata,
      spine: spine ?? this.spine,
      toc: toc ?? this.toc,
      sourcePath: sourcePath ?? this.sourcePath,
      addedAt: addedAt ?? this.addedAt,
      lastReadChapter: lastReadChapter ?? this.lastReadChapter,
      lastReadPosition: lastReadPosition ?? this.lastReadPosition,
    );
  }
}
