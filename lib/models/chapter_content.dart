class ChapterContent {
  final String id;
  final String href;
  final String title;
  final String content; // HTML content
  final String text; // Plain text for copy
  final int order;

  ChapterContent({
    required this.id,
    required this.href,
    required this.title,
    required this.content,
    required this.text,
    required this.order,
  });

  factory ChapterContent.fromMap(Map<String, dynamic> map) {
    return ChapterContent(
      id: map['id'] ?? '',
      href: map['href'] ?? '',
      title: map['title'] ?? 'Untitled',
      content: map['content'] ?? '',
      text: map['text'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'href': href,
      'title': title,
      'content': content,
      'text': text,
      'order': order,
    };
  }
}
