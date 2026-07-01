import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intern_connect/models/intern_video.dart';

class VideoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload video and save metadata
  Future<void> uploadVideo({
    required File videoFile,
    required String name,
    required String nickname,
    required String academicBackground,
    required String techInterests,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    // 1. Upload video to Storage
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${user.uid}.mp4';
    final ref = _storage.ref().child('introduction_videos/$fileName');
    await ref.putFile(videoFile);
    final videoUrl = await ref.getDownloadURL();

    // 2. Save metadata to Firestore
    await _firestore.collection('videos').add({
      'name': name,
      'nickname': nickname,
      'academicBackground': academicBackground,
      'techInterests': techInterests,
      'videoUrl': videoUrl,
      'uploadedBy': user.email ?? 'unknown',
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get all videos ordered by upload time (newest first)
  Stream<List<InternVideo>> getVideos() {
    return _firestore
        .collection('videos')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InternVideo.fromMap(doc.id, doc.data()))
            .toList());
  }
}
