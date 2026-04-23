import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'dashboard_viewmodel.dart';
import 'widget.dart';

class JournalTab extends StatelessWidget {
  final DashboardViewModel vm;
  const JournalTab({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final now    = DateTime.now();
    final days   = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Today's Journal",
              style: GoogleFonts.poppins(color: C.textDark, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(dateStr, style: GoogleFonts.poppins(color: C.textGrey, fontSize: 13)),
          const SizedBox(height: 20),

          // Mood picker
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: C.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('How are you feeling?',
                  style: GoogleFonts.poppins(color: C.textDark, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                MoodBtn(emoji: '😊', label: 'Great'),
                MoodBtn(emoji: '🙂', label: 'Good'),
                MoodBtn(emoji: '😐', label: 'Okay'),
                MoodBtn(emoji: '😔', label: 'Low'),
                MoodBtn(emoji: '😣', label: 'Bad'),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          // Journal entry
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: C.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Write today's entry",
                  style: GoogleFonts.poppins(color: C.textDark, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              TextField(
                onChanged: vm.setJournal,
                maxLines: 6,
                style: GoogleFonts.poppins(color: C.textDark, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'How was your day? How are you feeling?...',
                  hintStyle: GoogleFonts.poppins(color: C.textGrey, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Checklist
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: C.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Today's Checklist",
                  style: GoogleFonts.poppins(color: C.textDark, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              ...List.generate(vm.checklists.length, (i) {
                final c = vm.checklists[i];
                return InkWell(
                  onTap: () => vm.toggleChecklist(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      Icon(c.isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
                          color: c.isDone ? C.teal : C.textGrey.withOpacity(0.4), size: 20),
                      const SizedBox(width: 10),
                      Text(c.title, style: GoogleFonts.poppins(
                        color: c.isDone ? C.textGrey : C.textDark, fontSize: 13,
                        decoration: c.isDone ? TextDecoration.lineThrough : null,
                      )),
                    ]),
                  ),
                );
              }),
            ]),
          ),
          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: C.brown, foregroundColor: C.white, elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Save Journal Entry',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }
}