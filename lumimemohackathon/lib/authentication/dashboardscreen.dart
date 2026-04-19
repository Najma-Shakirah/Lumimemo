import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../apptheme.dart';
import 'loginscreen.dart';
import '../family/family.dart';
import '../memories/memory.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final User? _user = FirebaseAuth.instance.currentUser;

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  List<Widget> get _pages => [
        _HomeContent(user: _user, onProfileTap: () => _showProfileSheet(context)),
        const MemoryScreen(),
        const FamilyScreen(),
        _ProfilePage(user: _user, onSignOut: _signOut),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.surfaceAlt, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          selectedLabelStyle: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.photo_library_outlined), activeIcon: Icon(Icons.photo_library_rounded), label: 'Memories'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline_rounded), activeIcon: Icon(Icons.people_rounded), label: 'Family'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.background,
              elevation: 0,
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.surfaceAlt, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(_user?.displayName?.split(' ').first ?? 'Friend', style: GoogleFonts.dmSerifDisplay(color: AppTheme.textPrimary, fontSize: 22)),
            const SizedBox(height: 4),
            Text(_user?.email ?? '', style: GoogleFonts.dmSans(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 28),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppTheme.error),
              title: Text('Sign Out', style: GoogleFonts.dmSans(color: AppTheme.error, fontWeight: FontWeight.w600)),
              onTap: () { Navigator.pop(context); _signOut(); },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ── Home Content ──────────────────────────────────────────────────────────────
class _HomeContent extends StatelessWidget {
  final User? user;
  final VoidCallback onProfileTap;
  const _HomeContent({required this.user, required this.onProfileTap});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _displayName => user?.displayName?.split(' ').first ?? 'Friend';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$_greeting,', style: GoogleFonts.dmSans(color: AppTheme.textSecondary, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(_displayName, style: GoogleFonts.dmSerifDisplay(color: AppTheme.textPrimary, fontSize: 26)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?',
                          style: GoogleFonts.dmSerifDisplay(color: AppTheme.primary, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Row(
                children: [
                  _StatCard(label: 'Memories', value: '0', icon: Icons.photo_album_outlined),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Family', value: '0', icon: Icons.people_outline_rounded),
                  const SizedBox(width: 12),
                  _StatCard(label: 'Stories', value: '0', icon: Icons.auto_stories_outlined),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Memories', style: GoogleFonts.dmSerifDisplay(color: AppTheme.textPrimary, fontSize: 20)),
                  Text('See all', style: GoogleFonts.dmSans(color: AppTheme.primary, fontSize: 13)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.surfaceAlt.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.photo_library_outlined, color: AppTheme.textSecondary.withOpacity(0.4), size: 52),
                    const SizedBox(height: 16),
                    Text('No memories yet', style: GoogleFonts.dmSerifDisplay(color: AppTheme.textSecondary, fontSize: 18)),
                    const SizedBox(height: 6),
                    Text('Start by adding your first memory', style: GoogleFonts.dmSans(color: AppTheme.textSecondary.withOpacity(0.6), fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 14),
              child: Text('Quick Actions', style: GoogleFonts.dmSerifDisplay(color: AppTheme.textPrimary, fontSize: 20)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: const [
                  _QuickActionCard(icon: Icons.add_photo_alternate_outlined, label: 'Add Memory', color: Color(0xFFE8A838)),
                  _QuickActionCard(icon: Icons.people_alt_outlined, label: 'Invite Family', color: Color(0xFF5CC8A0)),
                  _QuickActionCard(icon: Icons.auto_stories_outlined, label: 'Create Story', color: Color(0xFF7B8EE8)),
                  _QuickActionCard(icon: Icons.explore_outlined, label: 'Explore', color: Color(0xFFE87B7B)),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── Profile Page ──────────────────────────────────────────────────────────────
class _ProfilePage extends StatelessWidget {
  final User? user;
  final VoidCallback onSignOut;
  const _ProfilePage({required this.user, required this.onSignOut});

  String get _displayName => user?.displayName?.split(' ').first ?? 'Friend';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 2),
              ),
              child: Center(
                child: Text(
                  _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?',
                  style: GoogleFonts.dmSerifDisplay(color: AppTheme.primary, fontSize: 36),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(user?.displayName ?? 'Friend', style: GoogleFonts.dmSerifDisplay(color: AppTheme.textPrimary, fontSize: 24)),
            const SizedBox(height: 4),
            Text(user?.email ?? '', style: GoogleFonts.dmSans(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account Info', style: GoogleFonts.dmSerifDisplay(color: AppTheme.textPrimary, fontSize: 16)),
                  const SizedBox(height: 16),
                  _InfoRow(icon: Icons.person_outline_rounded, label: 'Name', value: user?.displayName ?? '-'),
                  const SizedBox(height: 12),
                  _InfoRow(icon: Icons.mail_outline_rounded, label: 'Email', value: user?.email ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSignOut,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text('Sign Out', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.dmSans(color: AppTheme.textSecondary, fontSize: 11)),
            Text(value, style: GoogleFonts.dmSans(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 22),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.dmSerifDisplay(color: AppTheme.textPrimary, fontSize: 22)),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.dmSans(color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── Quick Action Card ─────────────────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickActionCard({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          Text(label, style: GoogleFonts.dmSans(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}