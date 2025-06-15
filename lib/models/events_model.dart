class Event {
  final int id;
  final String title;
  final String? content;
  final String? excerpt;
  final String? startDate;
  final String? endDate;
  final String? venue;
  final String? organizer;
  final String? website;
  final String? featuredImage;
  final String url;

  Event({
    required this.id,
    required this.title,
    this.content,
    this.excerpt,
    this.startDate,
    this.endDate,
    this.venue,
    this.organizer,
    this.website,
    this.featuredImage,
    required this.url,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return Event(
      id: int.tryParse(json['ID'].toString()) ?? 0,
      title: json['post_title'],
      content: json['post_content'],
      excerpt: json['post_excerpt'],
      startDate: meta['_EventStartDate'],
      endDate: meta['_EventEndDate'],
      venue: meta['_EventVenue'],
      organizer: meta['_EventOrganizer'],
      website: meta['_EventURL'],
      featuredImage: meta['_thumbnail_id'] != null
          ? _getFeaturedImageUrl(meta['_thumbnail_id'])
          : null,
      url: json['url'],
    );
  }

  static String? _getFeaturedImageUrl(dynamic thumbnailId) {
    // This would need to be implemented based on your WordPress setup
    // Typically it would be something like:
    // return 'https://your-site.com/wp-content/uploads/$thumbnailId.jpg';
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'post_title': title,
      'post_content': content,
      'post_excerpt': excerpt,
      'meta': {
        '_EventStartDate': startDate,
        '_EventEndDate': endDate,
        '_EventVenue': venue,
        '_EventOrganizer': organizer,
        '_EventURL': website,
        '_thumbnail_id': featuredImage,
      },
      'url': url,
    };
  }
}


