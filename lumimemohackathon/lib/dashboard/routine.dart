import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'dashboard_viewmodel.dart';

class RoutineTab extends StatelessWidget {
  final DashboardViewModel vm;
  const RoutineTab({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final done  = vm.routines.where((r) => r.isDone).length;
    final total = vm.routines.length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Daily Routine',
              style: GoogleFonts.poppins(color: C.textDark, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text("Tick what you've completed today",
              style: GoogleFonts.poppins(color: C.textGrey, fontSize: 13)),
          const SizedBox(height: 20),

          // Progress card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: C.heroBg, borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Progress',
                    style: GoogleFonts.poppins(color: C.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text('$done/$total',
                    style: GoogleFonts.poppins(color: C.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: total > 0 ? done / total : 0,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  color: C.white,
                  minHeight: 8,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // Routine list
          Container(
            decoration: BoxDecoration(
              color: C.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            ),
            child: Column(children: List.generate(vm.routines.length, (i) {
              final r = vm.routines[i];
              return InkWell(
                onTap: () => vm.toggleRoutine(i),
                borderRadius: i == 0
                    ? const BorderRadius.vertical(top: Radius.circular(16))
                    : i == vm.routines.length - 1
                        ? const BorderRadius.vertical(bottom: Radius.circular(16))
                        : BorderRadius.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: r.isDone ? C.teal.withOpacity(0.1) : const Color(0xFFF5EDE4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(r.icon, color: r.isDone ? C.teal : C.brown, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Text(r.label, style: GoogleFonts.poppins(
                      color: r.isDone ? C.textGrey : C.textDark, fontSize: 14,
                      decoration: r.isDone ? TextDecoration.lineThrough : null,
                    ))),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: r.isDone ? C.teal : Colors.transparent,
                        border: Border.all(
                            color: r.isDone ? C.teal : C.textGrey.withOpacity(0.3), width: 1.5),
                        shape: BoxShape.circle,
                      ),
                      child: r.isDone
                          ? const Icon(Icons.check_rounded, color: C.white, size: 14)
                          : null,
                    ),
                  ]),
                ),
              );
            })),
          ),
        ]),
      ),
    );
  }
}