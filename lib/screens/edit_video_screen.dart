import 'package:flutter/material.dart';
import 'package:intern_connect/models/intern_video.dart';
import 'package:intern_connect/services/video_service.dart';
import 'package:intern_connect/theme/app_colors.dart';

class EditVideoScreen extends StatefulWidget {
  final InternVideo video;
  const EditVideoScreen({super.key, required this.video});

  @override
  State<EditVideoScreen> createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends State<EditVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _academicController;
  late TextEditingController _interestsController;

  bool _isSaving = false;
  final VideoService _videoService = VideoService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.video.name);
    _nicknameController = TextEditingController(text: widget.video.nickname);
    _academicController = TextEditingController(text: widget.video.academicBackground);
    _interestsController = TextEditingController(text: widget.video.techInterests);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _videoService.updateVideo(
        widget.video.id,
        _nameController.text.trim(),
        _nicknameController.text.trim(),
        _academicController.text.trim(),
        _interestsController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true); // return true to signal success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
        title: Text('Edit your badge', style: Theme.of(context).textTheme.headlineSmall),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 24, width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                        )
                      : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
