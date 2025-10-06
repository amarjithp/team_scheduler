import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _OnboardingPageState extends State<OnboardingPage> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  XFile? _selectedImage;
  String? _nameErrorText;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await context.read<AuthCubit>().pickImage();
    if (image != null && mounted) setState(() => _selectedImage = image);
  }

  void _continue() {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameErrorText = 'Please enter your name';
      });
      return;
    }

    setState(() {
      _nameErrorText = null;
    });
    context.read<AuthCubit>().signInOrCreateUser(
          name: _nameController.text.trim(),
          imageFile: _selectedImage,
        );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1A1A2D);
    const accentColor = Color(0xFFE0218A);

    return Scaffold(
      backgroundColor: primaryColor,
      body: BlocListener<AuthCubit, AuthState>(
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
        child: Stack(
          children: [
            const Positioned.fill(child: AuroraBackground()),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: _buildForm(context.watch<AuthCubit>().state is AuthLoading, accentColor),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(bool isLoading, Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min, 
      children: [
        Text(
          'Team Scheduler',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your team is waiting.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 32),

        GestureDetector(
          onTap: isLoading ? null : _pickImage,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black26,
              backgroundImage: _selectedImage != null
                  ? (kIsWeb
                      ? NetworkImage(_selectedImage!.path)
                      : FileImage(File(_selectedImage!.path))) as ImageProvider
                  : null,
              child: _selectedImage == null
                  ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white70)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _nameController,
          enabled: !isLoading,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          onSubmitted: (_) => _continue(),
          onChanged: (value) {
            if (_nameErrorText != null) {
              setState(() {
                _nameErrorText = null;
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.normal),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            errorText: _nameErrorText,
            errorStyle: GoogleFonts.inter(color: Colors.redAccent.shade100, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: isLoading ? null : _continue,
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                )
              : Text(
                  'Let\'s Go',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ],
    );
  }
}

class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: AuroraPainter(),
      child: Container(),
    );
  }
}

class AuroraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 200);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final pinkPaint = Paint()
      ..shader = const RadialGradient(colors: [Color(0xFFE0218A), Colors.transparent]).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 150);

    final bluePaint = Paint()
      ..shader = const RadialGradient(colors: [Color(0xFF1BFFFF), Colors.transparent]).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 200);

    canvas.saveLayer(rect, paint);
    canvas.translate(size.width * 0.1, size.height * 0.2);
    canvas.drawCircle(Offset.zero, 150, pinkPaint);
    canvas.translate(size.width * 0.8, size.height * 0.5);
    canvas.drawCircle(Offset.zero, 250, bluePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BlobClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path(); 
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}