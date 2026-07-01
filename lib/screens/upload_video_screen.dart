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
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        title: Text('Design your badge', style: Theme.of(context).textTheme.headlineSmall),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video preview / pick button
              GestureDetector(
                onTap: _isUploading ? null : () => _showPickerOptions(),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.badgeCream,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _videoFile != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            // Static indicator for now until the 4-step wizard
                            const Center(
                              child: Icon(Icons.videocam, size: 80, color: AppColors.foilAmber),
                            ),
                            const Positioned(
                              bottom: 16,
                              left: 0, right: 0,
                              child: Center(
                                child: Text('Video ready', style: TextStyle(fontSize: 16, color: AppColors.ink, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_call, size: 60, color: AppColors.foilAmber),
                            SizedBox(height: 12),
                            Text('Tap to record your intro', style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.ink),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: AppColors.slate),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nicknameController,
                style: const TextStyle(color: AppColors.ink),
                decoration: const InputDecoration(
                  labelText: 'Preferred Nickname',
                  labelStyle: TextStyle(color: AppColors.slate),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _academicController,
                style: const TextStyle(color: AppColors.ink),
                decoration: const InputDecoration(
                  labelText: 'Academic Background (e.g., CS, 3rd year)',
                  labelStyle: TextStyle(color: AppColors.slate),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _interestsController,
                style: const TextStyle(color: AppColors.ink),
                decoration: const InputDecoration(
                  labelText: 'Tech Interests (e.g., AI, Web Dev)',
                  labelStyle: TextStyle(color: AppColors.slate),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _upload,
                  child: _isUploading
                      ? const SizedBox(
                          height: 24, width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                        )
                      : const Text('Post your intro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      backgroundColor: AppColors.ink,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.foilAmber),
              title: const Text('Record Video', style: TextStyle(color: AppColors.badgeCream)),
              onTap: () {
                Navigator.pop(ctx);
                _pickVideo(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: AppColors.foilAmber),
              title: const Text('Choose from Gallery', style: TextStyle(color: AppColors.badgeCream)),
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
