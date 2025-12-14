class AlertModel {
  final String title;
  final String message;
  final bool resolved;
  final DateTime createdAt;

  AlertModel({
    required this.title,
    required this.message,
    this.resolved = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'message': message,
        'resolved': resolved,
        'createdAt': createdAt,
      };
}
