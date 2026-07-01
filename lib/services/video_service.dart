import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intern_connect/models/intern_video.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

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

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 1. Generate thumbnail
    final tempDir = await getTemporaryDirectory();
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 512, // reduce size for faster loading
      quality: 75,
    );

    // 2. Upload video to Storage
    final videoFileName = '${timestamp}_${user.uid}.mp4';
    final videoRef = _storage.ref().child('introduction_videos/$videoFileName');
    await videoRef.putFile(videoFile);
    final videoUrl = await videoRef.getDownloadURL();

    // 3. Upload thumbnail to Storage
    String thumbnailUrl = '';
    if (thumbnailPath != null) {
      final thumbFileName = '${timestamp}_${user.uid}_thumb.jpg';
      final thumbRef = _storage.ref().child('introduction_thumbnails/$thumbFileName');
      await thumbRef.putFile(File(thumbnailPath));
      thumbnailUrl = await thumbRef.getDownloadURL();
    }

    // 4. Save metadata to Firestore
    await _firestore.collection('videos').add({
      'name': name,
      'nickname': nickname,
      'academicBackground': academicBackground,
      'techInterests': techInterests,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
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
