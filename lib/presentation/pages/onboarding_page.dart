import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_scheduler/presentation/cubits/auth/auth_cubit.dart';
import 'package:team_scheduler/data/repositories/task_repository.dart';
import 'package:team_scheduler/presentation/cubits/task_list/task_list_cubit.dart';
import 'package:team_scheduler/presentation/pages/task_list_page.dart';


class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _nameController = TextEditingController();
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    final image = await context.read<AuthCubit>().pickImage();
    if (image != null) setState(() => _selectedImage = image);
  }

  void _continue() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    context.read<AuthCubit>().signInOrCreateUser(
          name: _nameController.text.trim(),
          imageFile: _selectedImage,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Team Scheduler')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
          if (state is AuthSuccess) {
            Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (context) => TaskListCubit(
          context.read<TaskRepository>(),
        )..loadTasks(),
        child: const TaskListPage(),
      ),
    ),
  );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: isLoading ? null : _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _selectedImage != null
                          ? (kIsWeb
                              ? NetworkImage(_selectedImage!.path)
                              : FileImage(File(_selectedImage!.path))) as ImageProvider
                          : null,
                      child: _selectedImage == null
                          ? Icon(Icons.camera_alt, size: 40, color: Colors.grey.shade700)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Your Name', border: OutlineInputBorder()),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: isLoading ? null : _continue,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}