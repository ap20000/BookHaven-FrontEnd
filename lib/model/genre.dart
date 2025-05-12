class Genre {
  final int genreID;
  final String name;

  Genre({required this.genreID, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(genreID: json['genreID'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'name': name};
}
