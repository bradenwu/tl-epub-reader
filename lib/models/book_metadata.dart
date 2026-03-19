class BookMetadata {
  final String title;
  final String language;
  final List<String> authors;
  final String? description;
  final String? publisher;
  final String? date;

  BookMetadata({
    required this.title,
    this.language = 'en',
    this.authors = const [],
    this.description,
    this.publisher,
    this.date,
  });

  factory BookMetadata.fromMap(Map<String, dynamic> map) {
    return BookMetadata(
      title: map['title'] ?? 'Untitled',
      language: map['language'] ?? 'en',
      authors: (map['authors'] as List<dynamic>?)?.cast<String>() ?? [],
      description: map['description'],
      publisher: map['publisher'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'language': language,
      'authors': authors,
      'description': description,
      'publisher': publisher,
      'date': date,
    };
  }
}
