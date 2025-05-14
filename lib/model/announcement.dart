class Announcement {
  final int? announcementID;
  final String title;
  final String message;
  final DateTime startDate;
  final DateTime endDate;
  final String applicationUserId;

  Announcement({
    this.announcementID,
    required this.title,
    required this.message,
    required this.startDate,
    required this.endDate,
    required this.applicationUserId,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      announcementID: json['announcementID'],
      title: json['title'],
      message: json['message'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      applicationUserId: json['applicationUserId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "message": message,
      "startDate": startDate.toUtc().toIso8601String(),
      "endDate": endDate.toUtc().toIso8601String(),
      "applicationUserId": applicationUserId,
    };
  }
}
