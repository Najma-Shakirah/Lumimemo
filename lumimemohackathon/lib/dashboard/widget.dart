import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

// ── Section Title ─────────────────────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Row(children: [
        Container(
          width: 3, height: 16,
          decoration: BoxDecoration(color: C.brown, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.poppins(color: C.textDark, fontSize: 15, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ── Hero Pill ─────────────────────────────────────────────────────────────────
class HeroPill extends StatelessWidget {
  final String label;
  final IconData icon;
  const HeroPill({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
    child: Row(children: [
      Icon(icon, color: C.white, size: 13),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.poppins(color: C.white, fontSize: 11, fontWeight: FontWeight.w500)),
    ]),
  );
}

// ── Mood Button ───────────────────────────────────────────────────────────────
class MoodBtn extends StatefulWidget {
  final String emoji;
  final String label;
  const MoodBtn({super.key, required this.emoji, required this.label});

  @override
  State<MoodBtn> createState() => _MoodBtnState();
}

class _MoodBtnState extends State<MoodBtn> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _selected = !_selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: _selected ? C.brown.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _selected ? C.brown : Colors.transparent, width: 1.5),
        ),
        child: Column(children: [
          Text(widget.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 2),
          Text(widget.label, style: GoogleFonts.poppins(
            color: _selected ? C.brown : C.textGrey,
            fontSize: 9,
            fontWeight: _selected ? FontWeight.w600 : FontWeight.w400,
          )),
        ]),
      ),
    );
  }
}

// ── Profile Tile ──────────────────────────────────────────────────────────────
class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const ProfileTile({super.key, required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: C.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: ListTile(
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label, style: GoogleFonts.poppins(color: C.textDark, fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right_rounded, color: C.textGrey.withOpacity(0.4), size: 20),
        onTap: () {},
      ),
    );
  }
}