import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:team_scheduler/presentation/cubits/availability/availability_cubit.dart';
import 'package:team_scheduler/presentation/widgets/add_slot_dialog.dart';

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
    canvas.translate(size.width * 0.2, size.height * 0.9);
    canvas.drawCircle(Offset.zero, 250, pinkPaint);
    canvas.translate(size.width * 0.6, size.height * -0.4);
    canvas.drawCircle(Offset.zero, 200, bluePaint);
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AvailabilityPage extends StatelessWidget {
  const AvailabilityPage({super.key});

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
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            'My Availability',
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

                  Expanded(
                    child: Stack(
                      children: [
                        BlocBuilder<AvailabilityCubit, AvailabilityState>(
                          builder: (context, state) {
                            if (state is AvailabilityLoading || state is AvailabilityInitial) {
                              return const Center(child: CircularProgressIndicator(color: Colors.white));
                            }
                            if (state is AvailabilityError) {
                              return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.white70)));
                            }
                            if (state is AvailabilityLoaded) {
                              if (state.slots.isEmpty) {
                                return Center(
                                  child: Text(
                                    'You have no availability slots.\nAdd one to get started!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
                                  ),
                                );
                              }
                              return ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                itemCount: state.slots.length,
                                itemBuilder: (context, index) {
                                  final slot = state.slots[index];
                                  final dayFormatter = DateFormat('E, MMM d, yyyy');
                                  final timeFormatter = DateFormat('h:mm a');

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        dayFormatter.format(slot.startTime),
                                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        '${timeFormatter.format(slot.startTime)} - ${timeFormatter.format(slot.endTime)}',
                                        style: GoogleFonts.inter(color: Colors.white70),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete_forever_outlined, color: Colors.red.shade300),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (dialogContext) => AlertDialog(
                                              backgroundColor: const Color(0xFF27274D),
                                              title: Text('Delete Slot?', style: GoogleFonts.inter(color: Colors.white)),
                                              content: Text('This action cannot be undone.', style: GoogleFonts.inter(color: Colors.white70)),
                                              actionsAlignment: MainAxisAlignment.spaceBetween,
                                              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(dialogContext).pop(),
                                                  child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white70)),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    context.read<AvailabilityCubit>().deleteSlot(slot.id);
                                                    Navigator.of(dialogContext).pop();
                                                  },
                                                  child: Text('Delete', style: GoogleFonts.inter(color: accentColor)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                            return const Center(child: Text('An unexpected error occurred.', style: TextStyle(color: Colors.white70)));
                          },
                        ),
                      
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 80.0),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<AvailabilityCubit>(),
                                    child: const AddSlotDialog(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: Text('Add New Slot', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ),
                      ],
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