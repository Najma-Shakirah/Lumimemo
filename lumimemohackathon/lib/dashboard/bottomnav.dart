import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'dashboard_viewmodel.dart';

class BottomNav extends StatelessWidget {
  final DashboardViewModel vm;
  const BottomNav({super.key, required this.vm});

  void _showSOS(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.warning_rounded, color: C.red, size: 26),
          const SizedBox(width: 8),
          Text('SOS Emergency',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: C.red, fontSize: 16)),
        ]),
        content: Text('Call emergency services or your emergency contact?',
            style: GoogleFonts.poppins(fontSize: 13, color: C.textGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: C.textGrey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: C.red, foregroundColor: C.white, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.call_rounded, size: 16),
            label: Text('Call 999', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: C.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_rounded,         label: 'Home',    index: 0, vm: vm),
          _NavItem(icon: Icons.checklist_rounded,    label: 'Routine', index: 1, vm: vm),
          GestureDetector(
            onTap: () => _showSOS(context),
            child: Container(
              width: 56, height: 56,
              decoration: const BoxDecoration(
                color: C.red, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x44E05C5C), blurRadius: 16, offset: Offset(0, 4))],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.sos_rounded, color: C.white, size: 22),
                Text('SOS', style: GoogleFonts.poppins(
                    color: C.white, fontSize: 9, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
          _NavItem(icon: Icons.book_outlined,        label: 'Journal', index: 3, vm: vm),
          _NavItem(icon: Icons.person_outline_rounded, label: 'Profile', index: 4, vm: vm),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final DashboardViewModel vm;
  const _NavItem({required this.icon, required this.label, required this.index, required this.vm});

  @override
  Widget build(BuildContext context) {
    final selected = vm.selectedIndex == index;
    final color    = selected ? C.brown : C.textGrey;
    return GestureDetector(
      onTap: () => vm.setIndex(index),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.poppins(
            color: color, fontSize: 10,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
      ]),
    );
  }
}