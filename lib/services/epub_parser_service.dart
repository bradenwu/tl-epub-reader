import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as p;
import '../models/book.dart';
import '../models/book_metadata.dart';
import '../models/chapter_content.dart';
import '../models/toc_entry.dart';
import 'package:uuid/uuid.dart';

class EPUBParserService {
  static final _uuid = Uuid();

  /// Parse an EPUB file and return a Book object
  static Future<Book> parse(String epubPath) async {
    final file = File(epubPath);
    if (!await file.exists()) {
      throw Exception('EPUB file not found: $epubPath');
    }

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // 1. Find and parse container.xml to get OPF path
    final containerXml = _findFile(archive, 'META-INF/container.xml');
    if (containerXml == null) {
      throw Exception('Invalid EPUB: container.xml not found');
    }

    final opfPath = _parseContainerXml(utf8.decode(containerXml.content));
    if (opfPath == null) {
      throw Exception('Invalid EPUB: OPF path not found in container.xml');
    }

    // 2. Parse OPF file
    final opfFile = _findFile(archive, opfPath);
    if (opfFile == null) {
      throw Exception('Invalid EPUB: OPF file not found');
    }

    final opfDir = p.dirname(opfPath);
    final opfContent = utf8.decode(opfFile.content);
    final opfData = _parseOPF(opfContent, opfDir);

    // 3. Extract metadata
    final metadata = BookMetadata(
      title: opfData['title'] ?? 'Untitled',
      language: opfData['language'] ?? 'en',
      authors: (opfData['authors'] as List<String>?) ?? [],
      description: opfData['description'],
      publisher: opfData['publisher'],
      date: opfData['date'],
    );

    // 4. Parse spine (reading order)
    final spineItems = (opfData['spine'] as List<Map<String, String>>?) ?? [];
    final manifest = (opfData['manifest'] as Map<String, String>?) ?? {};

    final chapters = <ChapterContent>[];
    for (int i = 0; i < spineItems.length; i++) {
      final item = spineItems[i];
      final href = item['href'] ?? '';
      final fullPath = opfDir.isEmpty ? href : '$opfDir/$href';

      final chapterFile = _findFile(archive, fullPath);
      if (chapterFile != null) {
        final content = utf8.decode(chapterFile.content);
        final text = _extractPlainText(content);
        final title = _extractTitle(content) ?? 'Chapter ${i + 1}';

        chapters.add(ChapterContent(
          id: item['id'] ?? 'chapter_$i',
          href: href,
          title: title,
          content: _cleanHtml(content),
          text: text,
          order: i,
        ));
      }
    }

    // 5. Parse TOC (simplified - just use spine order)
    final toc = chapters
        .map((ch) => TOCEntry(
              title: ch.title,
              href: ch.href,
              fileHref: ch.href,
            ))
        .toList();

    return Book(
      id: _uuid.v4(),
      metadata: metadata,
      spine: chapters,
      toc: toc,
      sourcePath: epubPath,
    );
  }

  static ArchiveFile? _findFile(Archive archive, String path) {
    // Normalize path
    final normalizedPath = path.replaceAll('\\', '/');

    for (final file in archive.files) {
      final filePath = file.name.replaceAll('\\', '/');
      if (filePath == normalizedPath || filePath.endsWith('/$normalizedPath')) {
        return file;
      }
    }
    return null;
  }

  static String? _parseContainerXml(String content) {
    final doc = XmlDocument.parse(content);
    final rootfiles = doc.findAllElements('rootfile');
    for (final rootfile in rootfiles) {
      final fullPath = rootfile.getAttribute('full-path');
      if (fullPath != null) {
        return fullPath;
      }
    }
    return null;
  }

  static Map<String, dynamic> _parseOPF(String content, String opfDir) {
    final doc = XmlDocument.parse(content);
    final result = <String, dynamic>{};

    // Parse manifest
    final manifest = <String, String>{};
    for (final item in doc.findAllElements('item')) {
      final id = item.getAttribute('id');
      final href = item.getAttribute('href');
      if (id != null && href != null) {
        manifest[id] = href;
      }
    }
    result['manifest'] = manifest;

    // Parse spine
    final spine = <Map<String, String>>[];
    for (final itemref in doc.findAllElements('itemref')) {
      final idref = itemref.getAttribute('idref');
      if (idref != null && manifest[idref] != null) {
        spine.add({'id': idref, 'href': manifest[idref]!});
      }
    }
    result['spine'] = spine;

    // Parse metadata
    final metadata = doc.findElements('metadata').firstOrNull;
    if (metadata != null) {
      result['title'] = _getDCElement(metadata, 'title');
      result['language'] = _getDCElement(metadata, 'language');
      result['description'] = _getDCElement(metadata, 'description');
      result['publisher'] = _getDCElement(metadata, 'publisher');
      result['date'] = _getDCElement(metadata, 'date');

      final authors = <String>[];
      for (final creator in metadata.findAllElements('creator')) {
        final text = creator.innerText.trim();
        if (text.isNotEmpty) {
          authors.add(text);
        }
      }
      result['authors'] = authors;
    }

    return result;
  }

  static String? _getDCElement(XmlElement metadata, String name) {
    for (final element in metadata.children) {
      if (element is XmlElement) {
        final localName = element.name.local;
        if (localName == name) {
          return element.innerText.trim();
        }
      }
    }
    return null;
  }

  static String _cleanHtml(String html) {
    // Remove scripts, styles, and extract body content
    var content = html;

    // Try to extract body content
    final bodyMatch = RegExp(r'<body[^>]*>([\s\S]*?)</body>', caseSensitive: false)
        .firstMatch(content);
    if (bodyMatch != null) {
      content = bodyMatch.group(1) ?? content;
    }

    // Remove script and style tags
    content = content.replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>', caseSensitive: false), '');
    content = content.replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false), '');
    content = content.replaceAll(RegExp(r'<nav[^>]*>[\s\S]*?</nav>', caseSensitive: false), '');

    return content.trim();
  }

  static String _extractPlainText(String html) {
    var text = html;

    // Remove all HTML tags
    text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');

    // Decode HTML entities
    text = text.replaceAll('&nbsp;', ' ');
    text = text.replaceAll('&amp;', '&');
    text = text.replaceAll('&lt;', '<');
    text = text.replaceAll('&gt;', '>');
    text = text.replaceAll('&quot;', '"');
    text = text.replaceAll('&#39;', "'");

    // Normalize whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }

  static String? _extractTitle(String html) {
    // Try to find h1, h2, or title tag
    final h1Match = RegExp(r'<h1[^>]*>([\s\S]*?)</h1>', caseSensitive: false)
        .firstMatch(html);
    if (h1Match != null) {
      return _extractPlainText(h1Match.group(1) ?? '').trim();
    }

    final h2Match = RegExp(r'<h2[^>]*>([\s\S]*?)</h2>', caseSensitive: false)
        .firstMatch(html);
    if (h2Match != null) {
      return _extractPlainText(h2Match.group(1) ?? '').trim();
    }

    final titleMatch = RegExp(r'<title[^>]*>([\s\S]*?)</title>', caseSensitive: false)
        .firstMatch(html);
    if (titleMatch != null) {
      return _extractPlainText(titleMatch.group(1) ?? '').trim();
    }

    return null;
  }
}
