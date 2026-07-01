class InternVideo {
  final String id;
  final String name;
  final String nickname;
  final String academicBackground;
  final String techInterests;
  final String videoUrl;
  final String uploadedBy; // email of the user who uploaded
  final DateTime uploadedAt;

  InternVideo({
    required this.id,
    required this.name,
    required this.nickname,
    required this.academicBackground,
    required this.techInterests,
    required this.videoUrl,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  // Convert from Firestore document
  factory InternVideo.fromMap(String id, Map<String, dynamic> map) {
    return InternVideo(
      id: id,
      name: map['name'] ?? '',
      nickname: map['nickname'] ?? '',
      academicBackground: map['academicBackground'] ?? '',
      techInterests: map['techInterests'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedAt: (map['uploadedAt'] as dynamic).toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nickname': nickname,
      'academicBackground': academicBackground,
      'techInterests': techInterests,
      'videoUrl': videoUrl,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt,
    };
  }
}
