String stripHtmlWithEmojis(String htmlText) {
  // Remove HTML tags while preserving emojis and text
  final htmlRegex = RegExp(r'<[^>]*>');
  final textWithEmojis = htmlText.replaceAll(htmlRegex, '');

  // Unescape HTML entities (like &amp; → &)
  final unescaped = _unescapeHtmlEntities(textWithEmojis);

  return unescaped;
}

String _unescapeHtmlEntities(String text) {
  return text
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#039;', "'")
      .replaceAll('&nbsp;', ' ');
}
