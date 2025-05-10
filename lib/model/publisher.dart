class Publisher {
  final int publisherID;
  final String name;

  Publisher({required this.publisherID, required this.name});

  factory Publisher.fromJson(Map<String, dynamic> json) {
    return Publisher(publisherID: json['publisherID'], name: json['name']);
  }
}
