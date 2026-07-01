import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intern_connect/services/video_service.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _academicController = TextEditingController();
  final _interestsController = TextEditingController();

  File? _videoFile;
  bool _isUploading = false;
  final VideoService _videoService = VideoService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo(ImageSource source) async {
    final picked = await _picker.pickVideo(source: source);
    if (picked != null) {
      setState(() {
        _videoFile = File(picked.path);
      });
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or record a video first')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await _videoService.uploadVideo(
        videoFile: _videoFile!,
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim(),
        academicBackground: _academicController.text.trim(),
        techInterests: _interestsController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true); // return true to signal success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _academicController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Introduction Video')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Video preview / pick button
              GestureDetector(
                onTap: _isUploading ? null : () => _showPickerOptions(),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _videoFile != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            // Show a static icon to indicate video selected
                            const Icon(Icons.videocam, size: 60, color: Colors.deepPurple),
                            const Center(
                              child: Text('Video selected', style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_call, size: 60, color: Colors.deepPurple),
                            SizedBox(height: 8),
                            Text('Tap to select or record a video'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Preferred Nickname',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _academicController,
                decoration: const InputDecoration(
                  labelText: 'Academic Background (e.g., CS, 3rd year)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _interestsController,
                decoration: const InputDecoration(
                  labelText: 'Tech Interests (e.g., AI, Web Dev)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _upload,
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Upload Video'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Record Video'),
              onTap: () {
                Navigator.pop(ctx);
                _pickVideo(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickVideo(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
