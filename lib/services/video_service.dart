import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intern_connect/models/intern_video.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class VideoService {
  static final VideoService _instance = VideoService._internal();
  factory VideoService() => _instance;
  VideoService._internal();

  Database? _db;
  final _videosStreamController = StreamController<List<InternVideo>>.broadcast();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    _broadcastVideos();
    return _db!;
  }

  Future<Database> _initDB() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'videos.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE videos(
            id TEXT PRIMARY KEY,
            name TEXT,
            nickname TEXT,
            academicBackground TEXT,
            techInterests TEXT,
            videoUrl TEXT,
            thumbnailUrl TEXT,
            uploadedBy TEXT,
            uploadedAt INTEGER
          )
        ''');
      },
    );
  }

  // Upload video and save metadata locally
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
    final docsDir = await getApplicationDocumentsDirectory();

    // 1. Copy video to local storage
    final videoFileName = '${timestamp}_${user.uid}.mp4';
    final savedVideoPath = p.join(docsDir.path, videoFileName);
    await videoFile.copy(savedVideoPath);

    // 2. Generate thumbnail and save it
    final thumbFileName = '${timestamp}_${user.uid}_thumb.jpg';
    final savedThumbPath = p.join(docsDir.path, thumbFileName);
    
    final tempDir = await getTemporaryDirectory();
    final tempThumbPath = await VideoThumbnail.thumbnailFile(
      video: savedVideoPath,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 512,
      quality: 75,
    );

    if (tempThumbPath != null) {
      await File(tempThumbPath).copy(savedThumbPath);
    }

    // 3. Save metadata to SQLite
    final db = await database;
    final videoId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final newVideo = InternVideo(
      id: videoId,
      name: name,
      nickname: nickname,
      academicBackground: academicBackground,
      techInterests: techInterests,
      videoUrl: savedVideoPath,
      thumbnailUrl: tempThumbPath != null ? savedThumbPath : '',
      uploadedBy: user.email ?? 'unknown',
      uploadedAt: DateTime.now(),
    );

    await db.insert('videos', newVideo.toMap());

    // 4. Update the stream
    _broadcastVideos();
  }

  Future<void> _broadcastVideos() async {
    final db = await database;
    final maps = await db.query('videos', orderBy: 'uploadedAt DESC');
    final videos = maps.map((map) => InternVideo.fromMap(map['id'] as String, map)).toList();
    _videosStreamController.add(videos);
  }

  // Get all videos ordered by upload time (newest first)
  Stream<List<InternVideo>> getVideos() {
    // Ensure DB is initialized
    database;
    return _videosStreamController.stream;
  }
}
