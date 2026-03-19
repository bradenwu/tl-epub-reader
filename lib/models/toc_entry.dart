class TOCEntry {
  final String title;
  final String href;
  final String fileHref;
  final String anchor;
  final List<TOCEntry> children;

  TOCEntry({
    required this.title,
    required this.href,
    required this.fileHref,
    this.anchor = '',
    this.children = const [],
  });

  factory TOCEntry.fromMap(Map<String, dynamic> map) {
    return TOCEntry(
      title: map['title'] ?? 'Untitled',
      href: map['href'] ?? '',
      fileHref: map['fileHref'] ?? '',
      anchor: map['anchor'] ?? '',
      children: (map['children'] as List<dynamic>?)
              ?.map((e) => TOCEntry.fromMap(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'href': href,
      'fileHref': fileHref,
      'anchor': anchor,
      'children': children.map((e) => e.toMap()).toList(),
    };
  }
}
