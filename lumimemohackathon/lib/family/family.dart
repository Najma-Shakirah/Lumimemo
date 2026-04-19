import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../apptheme.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _familyRef => FirebaseFirestore.instance
      .collection('patients')
      .doc(_uid)
      .collection('family');

  void _openAddSheet({DocumentSnapshot? doc}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FamilyFormSheet(
        familyRef: _familyRef,
        existing: doc,
      ),
    );
  }

  void _confirmDelete(String docId, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove $name?',
            style: GoogleFonts.dmSerifDisplay(color: AppTheme.textPrimary)),
        content: Text('This will remove them from the family list.',
            style: GoogleFonts.dmSans(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await _familyRef.doc(docId).delete();
              if (mounted) Navigator.pop(context);
            },
            child: Text('Remove',
                style: GoogleFonts.dmSans(
                    color: AppTheme.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text('Family Members',
            style: GoogleFonts.dmSerifDisplay(
                color: AppTheme.textPrimary, fontSize: 22)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddSheet(),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
        elevation: 0,
        child: const Icon(Icons.person_add_rounded, size: 24),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _familyRef.orderBy('createdAt', descending: false).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _FamilyCard(
                data: data,
                onEdit: () => _openAddSheet(doc: doc),
                onDelete: () => _confirmDelete(doc.id, data['name'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline_rounded,
                color: AppTheme.textSecondary.withOpacity(0.4), size: 64),
            const SizedBox(height: 16),
            Text('No Family Members Yet',
                style: GoogleFonts.dmSerifDisplay(
                    color: AppTheme.textPrimary, fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add a family member so the patient can recognise them.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Family Card ───────────────────────────────────────────────────────────────
class _FamilyCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FamilyCard({
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? 'Unknown';
    final relationship = data['relationship'] ?? '';
    final phone = data['phone'] ?? 'No number';
    final photoBase64 = data['photoBase64'] as String?;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final badgeColor = _badgeColor(relationship);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // ── Photo ────────────────────────────────────────────────────────
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withOpacity(0.15),
            ),
            child: photoBase64 != null
                ? ClipOval(
                    child: Image.memory(
                      base64Decode(photoBase64),
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                    ),
                  )
                : Center(
                    child: Text(initial,
                        style: GoogleFonts.dmSerifDisplay(
                            color: AppTheme.primary, fontSize: 24)),
                  ),
          ),
          const SizedBox(width: 14),

          // ── Info ─────────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.dmSans(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
                const SizedBox(height: 4),

                // Relationship badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(relationship,
                      style: GoogleFonts.dmSans(
                          color: badgeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 6),

                // Phone
                Row(
                  children: [
                    Icon(Icons.phone_outlined,
                        color: AppTheme.textSecondary, size: 13),
                    const SizedBox(width: 4),
                    Text(phone,
                        style: GoogleFonts.dmSans(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // ── Actions ──────────────────────────────────────────────────────
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined,
                    color: AppTheme.primary, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 8),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded,
                    color: AppTheme.error.withOpacity(0.7), size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _badgeColor(String relationship) {
    switch (relationship.toLowerCase()) {
      case 'spouse':
      case 'husband':
      case 'wife':
        return const Color(0xFFE87B7B);
      case 'son':
      case 'daughter':
      case 'child':
        return const Color(0xFF7B8EE8);
      case 'father':
      case 'mother':
      case 'parent':
        return const Color(0xFF5CC8A0);
      case 'brother':
      case 'sister':
      case 'sibling':
        return const Color(0xFFE8A838);
      default:
        return AppTheme.textSecondary;
    }
  }
}

// ── Add / Edit Form Sheet ─────────────────────────────────────────────────────
class _FamilyFormSheet extends StatefulWidget {
  final CollectionReference familyRef;
  final DocumentSnapshot? existing;

  const _FamilyFormSheet({required this.familyRef, this.existing});

  @override
  State<_FamilyFormSheet> createState() => _FamilyFormSheetState();
}

class _FamilyFormSheetState extends State<_FamilyFormSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedRelationship = 'Son';
  File? _imageFile;
  String? _existingPhotoBase64;
  bool _isSaving = false;

  final List<String> _relationships = [
    'Spouse', 'Husband', 'Wife',
    'Son', 'Daughter',
    'Father', 'Mother',
    'Brother', 'Sister',
    'Grandfather', 'Grandmother',
    'Uncle', 'Aunt',
    'Caregiver', 'Friend', 'Other',
  ];

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final data = widget.existing!.data() as Map<String, dynamic>;
      _nameCtrl.text = data['name'] ?? '';
      _phoneCtrl.text = data['phone'] ?? '';
      _selectedRelationship = data['relationship'] ?? 'Son';
      _existingPhotoBase64 = data['photoBase64'];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  // Convert image file to base64 string
  Future<String?> _imageToBase64() async {
    if (_imageFile == null) return _existingPhotoBase64;
    final bytes = await _imageFile!.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in name and phone number',
              style: GoogleFonts.dmSans()),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Convert image to base64 — no Storage needed!
      final photoBase64 = await _imageToBase64();

      final data = {
        'name': _nameCtrl.text.trim(),
        'relationship': _selectedRelationship,
        'phone': _phoneCtrl.text.trim(),
        'photoBase64': photoBase64,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_isEditing) {
        await widget.familyRef.doc(widget.existing!.id).update(data);
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        await widget.familyRef.add(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isEditing ? 'Updated successfully!' : 'Family member added!',
                style: GoogleFonts.dmSans()),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.dmSans()),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(_isEditing ? 'Edit Family Member' : 'Add Family Member',
                style: GoogleFonts.dmSerifDisplay(
                    color: AppTheme.textPrimary, fontSize: 22)),
            const SizedBox(height: 6),
            Text('Help the patient recognise their loved ones.',
                style: GoogleFonts.dmSans(
                    color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),

            // ── Photo Picker ────────────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.surfaceAlt,
                      ),
                      child: _imageFile != null
                          ? ClipOval(
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                                width: 90,
                                height: 90,
                              ),
                            )
                          : _existingPhotoBase64 != null
                              ? ClipOval(
                                  child: Image.memory(
                                    base64Decode(_existingPhotoBase64!),
                                    fit: BoxFit.cover,
                                    width: 90,
                                    height: 90,
                                  ),
                                )
                              : const Icon(Icons.person_outline_rounded,
                                  color: AppTheme.textSecondary, size: 36),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_outlined,
                            color: AppTheme.background, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('Tap to add photo',
                  style: GoogleFonts.dmSans(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ),
            const SizedBox(height: 20),

            // ── Full Name ───────────────────────────────────────────────
            _label('Full Name'),
            _textField(
              controller: _nameCtrl,
              hint: 'e.g. Ahmad bin Ali',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 14),

            // ── Relationship ────────────────────────────────────────────
            _label('Relationship'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRelationship,
                  isExpanded: true,
                  dropdownColor: AppTheme.surfaceAlt,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textSecondary),
                  style: GoogleFonts.dmSans(
                      color: AppTheme.textPrimary, fontSize: 14),
                  items: _relationships
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedRelationship = val!),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Phone Number ────────────────────────────────────────────
            _label('Phone Number'),
            _textField(
              controller: _phoneCtrl,
              hint: 'e.g. 0123456789',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 28),

            // ── Save Button ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: AppTheme.background),
                      )
                    : Text(
                        _isEditing ? 'Save Changes' : 'Add Family Member',
                        style: GoogleFonts.dmSans(
                            color: AppTheme.background,
                            fontWeight: FontWeight.w700,
                            fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: GoogleFonts.dmSans(
                color: AppTheme.textSecondary, fontSize: 12)),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.dmSans(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.dmSans(color: AppTheme.textSecondary, fontSize: 14),
          prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
          filled: true,
          fillColor: AppTheme.surfaceAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
        ),
      );
}