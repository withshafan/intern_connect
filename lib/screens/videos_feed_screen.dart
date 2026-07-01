import 'package:flutter/material.dart';
import 'package:intern_connect/models/intern_video.dart';
import 'package:intern_connect/services/video_service.dart';
import 'upload_video_screen.dart';
import 'video_player_screen.dart';

class VideosFeedScreen extends StatefulWidget {
  const VideosFeedScreen({super.key});

  @override
  State<VideosFeedScreen> createState() => _VideosFeedScreenState();
}

class _VideosFeedScreenState extends State<VideosFeedScreen> {
  final VideoService _videoService = VideoService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Intern Videos')),
      body: StreamBuilder<List<InternVideo>>(
        stream: _videoService.getVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final videos = snapshot.data ?? [];
          if (videos.isEmpty) {
            return const Center(
              child: Text('No introduction videos yet.\nTap + to upload yours!',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(video.name),
                  subtitle: Text(video.academicBackground),
                  trailing: const Icon(Icons.play_circle_fill),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerScreen(video: video),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadVideoScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
