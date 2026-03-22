class SubjectResponse {
  final int id;
  final String code;
  final String name;
  final String? description;

  SubjectResponse({
    required this.id,
    required this.code,
    required this.name,
    this.description,
  });

  factory SubjectResponse.fromJson(Map<String, dynamic> json) {
    return SubjectResponse(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}
