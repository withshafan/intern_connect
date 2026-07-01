import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:intern_connect/models/intern_video.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intern_connect/services/video_service.dart';
import 'package:intern_connect/screens/edit_video_screen.dart';
import 'package:share_plus/share_plus.dart';

class VideoPlayerScreen extends StatefulWidget {
  final InternVideo video;
  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (widget.video.videoUrl.startsWith('http')) {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl));
    } else {
      _videoPlayerController = VideoPlayerController.file(File(widget.video.videoUrl));
    }

    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
               final fileUrl = widget.video.videoUrl;
               if (fileUrl.startsWith('http')) {
                 Share.share('Check out this intern intro video: $fileUrl');
               } else {
                 await Share.shareXFiles([XFile(fileUrl)], text: 'Check out my Intern intro!');
               }
            },
          ),
          if (FirebaseAuth.instance.currentUser?.email == widget.video.uploadedBy)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditVideoScreen(video: widget.video),
                    ),
                  ).then((_) {
                    Navigator.pop(context); // Go back to feed so it refreshes cleanly
                  });
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Video'),
                      content: const Text('Are you sure you want to delete this video?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await VideoService().deleteVideo(widget.video);
                    if (mounted) Navigator.pop(context);
                  }
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit details'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete video', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_chewieController != null)
            AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            )
          else
            const Center(child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${widget.video.name}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Nickname: ${widget.video.nickname}'),
                const SizedBox(height: 4),
                Text('Academic: ${widget.video.academicBackground}'),
                const SizedBox(height: 4),
                Text('Tech Interests: ${widget.video.techInterests}'),
                const SizedBox(height: 4),
                Text('Uploaded by: ${widget.video.uploadedBy}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
