import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../apptheme.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = [];
  List<Contact> _filtered = [];
  bool _isLoading = true;
  bool _permissionDenied = false;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    // Request permission
    if (await FlutterContacts.requestPermission()) {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      setState(() {
        _contacts = contacts;
        _filtered = contacts;
        _isLoading = false;
      });
    } else {
      setState(() {
        _permissionDenied = true;
        _isLoading = false;
      });
    }
  }

  void _search(String query) {
    setState(() {
      _filtered = _contacts
          .where((c) =>
              c.displayName.toLowerCase().contains(query.toLowerCase()) ||
              c.phones.any((p) => p.number.contains(query)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          'Contacts',
          style: GoogleFonts.dmSerifDisplay(
              color: AppTheme.textPrimary, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadContacts();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : _permissionDenied
              ? _buildPermissionDenied()
              : Column(
                  children: [
                    _buildSearchBar(),
                    _buildContactCount(),
                    Expanded(child: _buildContactList()),
                  ],
                ),
    );
  }

  // ── Search Bar ──────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _search,
        style: GoogleFonts.dmSans(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search name or number...',
          hintStyle:
              GoogleFonts.dmSans(color: AppTheme.textSecondary, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppTheme.textSecondary, size: 20),
          filled: true,
          fillColor: AppTheme.surfaceAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ── Contact Count ───────────────────────────────────────────────────────────
  Widget _buildContactCount() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Text(
            '${_filtered.length} contacts',
            style: GoogleFonts.dmSans(
                color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Contact List ────────────────────────────────────────────────────────────
  Widget _buildContactList() {
    if (_filtered.isEmpty) {
      return Center(
        child: Text('No contacts found',
            style:
                GoogleFonts.dmSans(color: AppTheme.textSecondary, fontSize: 14)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final contact = _filtered[index];
        return _ContactTile(contact: contact);
      },
    );
  }

  // ── Permission Denied ───────────────────────────────────────────────────────
  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.contacts_outlined,
                color: AppTheme.textSecondary.withOpacity(0.4), size: 64),
            const SizedBox(height: 16),
            Text('Contacts Permission Denied',
                style: GoogleFonts.dmSerifDisplay(
                    color: AppTheme.textPrimary, fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              'Please allow contacts permission in your phone settings to use this feature.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadContacts,
              child: Text('Try Again',
                  style: GoogleFonts.dmSans(
                      color: AppTheme.background, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Contact Tile ──────────────────────────────────────────────────────────────
class _ContactTile extends StatelessWidget {
  final Contact contact;
  const _ContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    final name = contact.displayName.isNotEmpty ? contact.displayName : 'Unknown';
    final phone = contact.phones.isNotEmpty
        ? contact.phones.first.number
        : 'No number';
    final initial = name[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Avatar
          contact.photo != null
              ? CircleAvatar(
                  radius: 22,
                  backgroundImage: MemoryImage(contact.photo!),
                )
              : CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.primary.withOpacity(0.2),
                  child: Text(initial,
                      style: GoogleFonts.dmSerifDisplay(
                          color: AppTheme.primary, fontSize: 18)),
                ),
          const SizedBox(width: 14),

          // Name & Number
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.dmSans(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(phone,
                    style: GoogleFonts.dmSans(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),

          // Call button
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call_outlined,
                color: AppTheme.primary, size: 20),
          ),
        ],
      ),
    );
  }
}