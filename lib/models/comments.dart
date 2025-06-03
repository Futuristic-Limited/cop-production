class Comments {
  final int id;
  final String title;
  final String description;
  final String image;

  Comments(this.id, this.title, this.description , this.image);

  // reading from the database
  factory Comments.fromMap(Map<String, dynamic> json) {
    return Comments(
      json['id'],
      json['title'],
      json['description'],
      json['image'],
    );
  }

 //writing to database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
    };
  }
}
