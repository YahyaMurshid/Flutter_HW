class CourseModel {
  final int id;
  final String owner;
  final String title;
  final String subject;
  final String overview;
  final String? photo;  // جعلناها nullable لأنها قد تكون null
  final int totalStudents;
  final int totalModules;
  final String created;

  CourseModel({
    required this.id,
    required this.owner,
    required this.title,
    required this.subject,
    required this.overview,
    this.photo,  // optional
    required this.totalStudents,
    required this.totalModules,
    required this.created,
  });

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'] ?? 0,
      owner: map['owner'] ?? '',
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      overview: map['overview'] ?? '',
      photo: map['photo'],  // يمكن أن تكون null
      totalStudents: map['total_students'] ?? 0,
      totalModules: map['total_modules'] ?? 0,
      created: map['created'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner': owner,
      'title': title,
      'subject': subject,
      'overview': overview,
      'photo': photo,
      'total_students': totalStudents,
      'total_modules': totalModules,
      'created': created,
    };
  }
} 