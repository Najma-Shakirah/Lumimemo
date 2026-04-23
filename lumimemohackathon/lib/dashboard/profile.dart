import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'dashboard_viewmodel.dart';
import 'widget.dart';

class ProfileTab extends StatelessWidget {
  final DashboardViewModel vm;
  const ProfileTab({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final user = vm.user;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 20),

          // Avatar
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              color: C.brownMid, shape: BoxShape.circle,
              border: Border.all(color: C.white, width: 3),
              boxShadow: [BoxShadow(color: C.brown.withOpacity(0.22), blurRadius: 20)],
            ),
            child: Center(child: Text(user?.initial ?? 'A',
                style: GoogleFonts.poppins(color: C.white, fontSize: 34, fontWeight: FontWeight.w600))),
          ),
          const SizedBox(height: 14),
          Text(user?.displayName ?? 'Friend',
              style: GoogleFonts.poppins(color: C.textDark, fontSize: 20, fontWeight: FontWeight.w700)),
          Text(user?.email ?? '', style: GoogleFonts.poppins(color: C.textGrey, fontSize: 13)),
          const SizedBox(height: 28),

          // Menu items
          ProfileTile(icon: Icons.person_outline_rounded,         label: 'Edit Profile',         color: C.blue),
          ProfileTile(icon: Icons.notifications_outlined,         label: 'Reminders',            color: C.amber),
          ProfileTile(icon: Icons.medical_information_outlined,   label: 'Medical Info',         color: C.red),
          ProfileTile(icon: Icons.people_outline_rounded,         label: 'Emergency Contacts',   color: C.teal),
          ProfileTile(icon: Icons.settings_outlined,              label: 'Settings',             color: C.textGrey),
          const SizedBox(height: 16),

          // Sign out
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => vm.signOut(() {}),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: Text('Sign Out',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: C.red, foregroundColor: C.white, elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}