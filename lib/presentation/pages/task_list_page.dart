import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:team_scheduler/data/repositories/auth_repository.dart';
import 'package:team_scheduler/data/repositories/availability_repository.dart';
import 'package:team_scheduler/data/repositories/task_repository.dart';
import 'package:team_scheduler/presentation/cubits/auth/auth_cubit.dart';
import 'package:team_scheduler/presentation/cubits/availability/availability_cubit.dart';
import 'package:team_scheduler/presentation/cubits/task_creation/task_creation_cubit.dart';
import 'package:team_scheduler/presentation/cubits/task_list/task_list_cubit.dart';
import 'package:team_scheduler/presentation/pages/availability_page.dart';
import 'package:team_scheduler/presentation/pages/create_task_page.dart';
import 'package:team_scheduler/presentation/pages/onboarding_page.dart';
import 'package:team_scheduler/presentation/widgets/task_card.dart';

class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: AuroraPainter(), child: Container());
  }
}

class AuroraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 150);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final pinkPaint = Paint()
      ..shader = const RadialGradient(colors: [Color(0xFFE0218A), Colors.transparent]).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 150);
    final bluePaint = Paint()
      ..shader = const RadialGradient(colors: [Color(0xFF1BFFFF), Colors.transparent]).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 200);
    canvas.saveLayer(rect, paint);
    canvas.translate(size.width * -0.1, size.height * 0.1);
    canvas.drawCircle(Offset.zero, 200, pinkPaint);
    canvas.translate(size.width * 1.2, size.height * 0.8);
    canvas.drawCircle(Offset.zero, 300, bluePaint);
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1A1A2D);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          const Positioned.fill(child: AuroraBackground()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              BlocBuilder<TaskListCubit, TaskListState>(
                                builder: (context, state) {
                                  if (state.currentUser?.photoUrl != null) {
                                    return CircleAvatar(
                                      radius: 22,
                                      backgroundImage: NetworkImage(state.currentUser!.photoUrl!),
                                    );
                                  }
                                  return CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                    child: Text(
                                      state.currentUser?.name.substring(0, 1) ?? '?',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  );
                                },
                              ),

                              const Spacer(),

                              Text(
                                'Task List',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),

                              IconButton(
                                icon: const Icon(Icons.logout, color: Colors.white),
                                tooltip: 'Logout',
                                onPressed: () async {
                                  await context.read<AuthCubit>().signOut();
                                  if (mounted) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (_) => const OnboardingPage()),
                                      (route) => false,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _HeaderButton(
                                  icon: Icons.add_task,
                                  label: 'New Task',
                                  onPressed: () async {
                                    final result = await Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => BlocProvider(
                                        create: (context) => TaskCreationCubit(
                                          context.read<AuthRepository>(),
                                          context.read<TaskRepository>(),
                                        )..init(),
                                        child: const CreateTaskPage(),
                                      ),
                                    ));
                                    if (result == true && mounted) {
                                      context.read<TaskListCubit>().loadTasks();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _HeaderButton(
                                  icon: Icons.event_available,
                                  label: 'Manage Slots',
                                  onPressed: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => BlocProvider(
                                        create: (context) => AvailabilityCubit(
                                          context.read<AvailabilityRepository>(),
                                        )..loadAvailability(),
                                        child: const AvailabilityPage(),
                                      ),
                                    ));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 1, indent: 24, endIndent: 24),
                    Expanded(
                      child: BlocBuilder<TaskListCubit, TaskListState>(
                        builder: (context, state) {
                          if (state.status == TaskListStatus.loading || state.status == TaskListStatus.initial) {
                            return const Center(child: CircularProgressIndicator(color: Colors.white));
                          }
                          if (state.status == TaskListStatus.failure) {
                            return Center(child: Text('Error: ${state.errorMessage}', style: const TextStyle(color: Colors.white70)));
                          }
                          if (state.tasks.isEmpty) {
                            return const Center(child: Text('No tasks found. Create one to get started!', style: TextStyle(color: Colors.white70)));
                          }
                          return RefreshIndicator(
                            onRefresh: () => context.read<TaskListCubit>().loadTasks(),
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 8, bottom: 24),
                              itemCount: state.tasks.length,
                              itemBuilder: (context, index) {
                                final task = state.tasks[index];
                                return TaskCard(task: task);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _HeaderButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    );
  }
}