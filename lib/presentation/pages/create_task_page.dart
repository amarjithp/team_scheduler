import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:team_scheduler/presentation/cubits/task_creation/task_creation_cubit.dart';

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
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 150);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final pinkPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFE0218A), Colors.transparent],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 150);
    final bluePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF1BFFFF), Colors.transparent],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 200);
    canvas.saveLayer(rect, paint);
    canvas.translate(size.width * 0.9, size.height * 0.1);
    canvas.drawCircle(Offset.zero, 200, pinkPaint);
    canvas.translate(size.width * -0.8, size.height * 0.8);
    canvas.drawCircle(Offset.zero, 250, bluePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});
  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _pageController = PageController();
  int _currentPage = 0;
  String? _titleErrorText;
  String? _collaboratorErrorText;
  final List<int> _durations = [15, 30, 45, 60];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPage(TaskCreationState state) {
    if (_currentPage == 2) {
      if (state.durationInMinutes != null &&
          state.selectedCollaborators.isNotEmpty) {
        context.read<TaskCreationCubit>().findSlots();
      } else {
        return;
      }
    }
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1A1A2D);
    const accentColor = Color(0xFFE0218A);

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
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              'Create Task',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24.0,
                        horizontal: 32.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(4, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 8,
                            width: 60,
                            decoration: BoxDecoration(
                              color: _currentPage >= index
                                  ? accentColor
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                    Expanded(
                      child: BlocConsumer<TaskCreationCubit, TaskCreationState>(
                        listener: (context, state) {
                        },
                        builder: (context, state) {
                          return PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            onPageChanged: (page) =>
                                setState(() => _currentPage = page),
                            children: [
                              _buildStep('Task Details', _buildTaskDetailsForm(state)),
                              _buildStep('Collaborators', _buildCollaboratorsList(state)),
                              _buildStep('Duration', _buildDurationSelector(state)),
                              _buildStep('Available Slots', _buildSlotList(state)),
                            ],
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

  Widget _buildStep(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildNavigationRow(TaskCreationState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _onPreviousPage,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 56),
                  side: BorderSide(color: Colors.white.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Back', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: _NextButton(
              label: _currentPage == 3 ? 'Create Task' : 'Next',
              onPressed: _currentPage == 3
                  ? (state.selectedSlot == null)
                      ? null
                      : () async {
                          final success = await context.read<TaskCreationCubit>().createTask();
                          if (success && mounted) {
                            Navigator.of(context).pop(true);
                          }
                        }
                  : () {
                      if (_currentPage == 0) {
                        if (context.read<TaskCreationCubit>().state.title.trim().isEmpty) {
                          setState(() => _titleErrorText = 'Title is required');
                        } else {
                          _onNextPage(state);
                        }
                      } else if (_currentPage == 1) {
                        if (context.read<TaskCreationCubit>().state.selectedCollaborators.isEmpty) {
                          setState(() => _collaboratorErrorText = 'Please select at least one collaborator');
                        } else {
                          _onNextPage(state);
                        }
                      } else {
                        _onNextPage(state);
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDetailsForm(TaskCreationState state) {
    return Column(
      children: [
        _CustomTextField(
          hintText: 'Task Title',
          errorText: _titleErrorText,
          onChanged: (value) {
            if (_titleErrorText != null) {
              setState(() {
                _titleErrorText = null;
              });
            }
            context.read<TaskCreationCubit>().titleChanged(value);
          },
        ),
        const SizedBox(height: 16),
        _CustomTextField(
          hintText: 'Description (optional)',
          onChanged: (value) =>
              context.read<TaskCreationCubit>().descriptionChanged(value),
          maxLines: 4,
        ),
        const Spacer(),
        _buildNavigationRow(state),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildCollaboratorsList(TaskCreationState state) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: state.allUsers.length,
            itemBuilder: (ctx, index) {
              final user = state.allUsers[index];
              final isSelected = state.selectedCollaborators.contains(user);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE0218A).withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CheckboxListTile(
                  title: Text(
                    user.name,
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  value: isSelected,
                  onChanged: (_) {
                    if (_collaboratorErrorText != null) {
                      setState(() => _collaboratorErrorText = null);
                    }
                    context.read<TaskCreationCubit>().collaboratorToggled(user);
                  },
                  activeColor: const Color(0xFFE0218A),
                  checkColor: Colors.white,
                ),
              );
            },
          ),
        ),
        if (_collaboratorErrorText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              _collaboratorErrorText!,
              style: GoogleFonts.inter(color: Colors.redAccent.shade100, fontWeight: FontWeight.w500),
            ),
          ),
        _buildNavigationRow(state), 
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildDurationSelector(TaskCreationState state) {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          value: state.durationInMinutes,
          onChanged: (value) {
            if (value != null) {
              context.read<TaskCreationCubit>().durationChanged(value);
            }
          },
          hint: Text(
            'Select Duration',
            style: GoogleFonts.inter(color: Colors.white70),
          ),
          items: _durations
              .map((d) => DropdownMenuItem(value: d, child: Text('$d minutes')))
              .toList(),
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: const Color(0xFF27274D),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const Spacer(),
        _buildNavigationRow(state),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSlotList(TaskCreationState state) {
    Widget content;
    switch (state.status) {
      case SlotFindingStatus.loading:
        content = const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
        break;
      case SlotFindingStatus.failure:
        content = const Center(
          child: Text(
            'Failed to find slots.',
            style: TextStyle(color: Colors.white70),
          ),
        );
        break;
      case SlotFindingStatus.success:
        if (state.availableSlots.isEmpty) {
          content = const Center(
            child: Text(
              'No common slots found.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        } else {
          content = ListView.builder(
            itemCount: state.availableSlots.length,
            itemBuilder: (ctx, index) {
              final slot = state.availableSlots[index];
              final formatter = DateFormat('E, MMM d  h:mm a');
              final isSelected = state.selectedSlot == slot;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE0218A).withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFE0218A)
                        : Colors.transparent,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    formatter.format(slot.start),
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  onTap: () =>
                      context.read<TaskCreationCubit>().selectSlot(slot),
                ),
              );
            },
          );
        }
        break;
      default:
        content = const Center(
          child: Text(
            'Select collaborators and duration.',
            style: TextStyle(color: Colors.white70),
          ),
        );
    }

    return Column(
      children: [
        Expanded(child: content),
        _buildNavigationRow(state),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;
  final int maxLines;
  final String? errorText; 

  const _CustomTextField({
    required this.hintText,
    required this.onChanged,
    this.maxLines = 1,
    this.errorText, 
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorText: errorText,
        errorStyle: GoogleFonts.inter(color: Colors.redAccent.shade100, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const _NextButton({this.onPressed, this.label = 'Next'});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE0218A),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}
