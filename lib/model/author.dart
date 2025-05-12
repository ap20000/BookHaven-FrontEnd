class Author {
  final int authorID;
  final String name;

  Author({required this.authorID, required this.name});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(authorID: json['authorID'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'name': name};
}
