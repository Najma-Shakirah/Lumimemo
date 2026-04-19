import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../apptheme.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _memoriesRef => FirebaseFirestore.instance
      .collection('patients')
      .doc(_uid)
      .collection('memories');

  void _openAddSheet({DocumentSnapshot? doc}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MemoryFormSheet(
        memoriesRef: _memoriesRef,
        existing: doc,
      ),
    );
  }

  void _openDetail(Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _MemoryDetailScreen(data: data),
      ),
    );
  }

  void _confirmDelete(String docId, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete "$title"?',
            style: GoogleFonts.dmSerifDisplay(color: AppTheme.textPrimary)),
        content: Text('This memory will be permanently deleted.',
            style: GoogleFonts.dmSans(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await _memoriesRef.doc(docId).delete();
              if (mounted) Navigator.pop(context);
            },
            child: Text('Delete',
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
        title: Text('Memories',
            style: GoogleFonts.dmSerifDisplay(
                color: AppTheme.textPrimary, fontSize: 22)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddSheet(),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
        elevation: 0,
        child: const Icon(Icons.add_photo_alternate_outlined, size: 24),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _memoriesRef
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final docs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _MemoryCard(
                data: data,
                onTap: () => _openDetail(data),
                onEdit: () => _openAddSheet(doc: doc),
                onDelete: () => _confirmDelete(doc.id, data['title'] ?? ''),
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
            Icon(Icons.photo_library_outlined,
                color: AppTheme.textSecondary.withOpacity(0.4), size: 64),
            const SizedBox(height: 16),
            Text('No Memories Yet',
                style: GoogleFonts.dmSerifDisplay(
                    color: AppTheme.textPrimary, fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add a precious memory with a photo and story.',
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

// ── Memory Card ───────────────────────────────────────────────────────────────
class _MemoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MemoryCard({
    required this.data,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? 'Untitled';
    final description = data['description'] ?? '';
    final photoUrl = data['photoUrl'] as String?;
    final addedBy = data['addedBy'] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: photoUrl != null
                    ? Image.network(
                        photoUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _photoPlaceholder(),
                      )
                    : _photoPlaceholder(),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with menu
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          color: AppTheme.surfaceAlt,
                          icon: const Icon(Icons.more_vert_rounded,
                              color: AppTheme.textSecondary, size: 16),
                          onSelected: (val) {
                            if (val == 'edit') onEdit();
                            if (val == 'delete') onDelete();
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(children: [
                                const Icon(Icons.edit_outlined,
                                    size: 16, color: AppTheme.primary),
                                const SizedBox(width: 8),
                                Text('Edit',
                                    style: GoogleFonts.dmSans(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13)),
                              ]),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(children: [
                                Icon(Icons.delete_outline_rounded,
                                    size: 16,
                                    color: AppTheme.error.withOpacity(0.8)),
                                const SizedBox(width: 8),
                                Text('Delete',
                                    style: GoogleFonts.dmSans(
                                        color: AppTheme.error, fontSize: 13)),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                            color: AppTheme.textSecondary, fontSize: 11)),
                  ],

                  if (addedBy.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 10, color: AppTheme.primary),
                        const SizedBox(width: 3),
                        Text(addedBy,
                            style: GoogleFonts.dmSans(
                                color: AppTheme.primary, fontSize: 10)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoPlaceholder() => Container(
        color: AppTheme.surfaceAlt,
        child: const Center(
          child: Icon(Icons.image_outlined,
              color: AppTheme.textSecondary, size: 40),
        ),
      );
}

// ── Memory Detail Screen ──────────────────────────────────────────────────────
class _MemoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const _MemoryDetailScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? 'Untitled';
    final description = data['description'] ?? '';
    final photoUrl = data['photoUrl'] as String?;
    final addedBy = data['addedBy'] ?? '';
    final createdAt = data['createdAt'] as Timestamp?;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Photo header
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppTheme.background,
            flexibleSpace: FlexibleSpaceBar(
              background: photoUrl != null
                  ? Image.network(photoUrl, fit: BoxFit.cover)
                  : Container(
                      color: AppTheme.surfaceAlt,
                      child: const Icon(Icons.image_outlined,
                          color: AppTheme.textSecondary, size: 64),
                    ),
            ),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.background.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.textPrimary, size: 18),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(title,
                      style: GoogleFonts.dmSerifDisplay(
                          color: AppTheme.textPrimary, fontSize: 28)),
                  const SizedBox(height: 12),

                  // Meta row
                  Row(
                    children: [
                      if (addedBy.isNotEmpty) ...[
                        const Icon(Icons.person_outline_rounded,
                            size: 14, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text('Added by $addedBy',
                            style: GoogleFonts.dmSans(
                                color: AppTheme.primary, fontSize: 12)),
                        const SizedBox(width: 16),
                      ],
                      if (createdAt != null) ...[
                        const Icon(Icons.calendar_today_outlined,
                            size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(createdAt.toDate()),
                          style: GoogleFonts.dmSans(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: AppTheme.surfaceAlt),
                  const SizedBox(height: 20),

                  // Description
                  if (description.isNotEmpty)
                    Text(description,
                        style: GoogleFonts.dmSans(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            height: 1.7)),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ── Add / Edit Form Sheet ─────────────────────────────────────────────────────
class _MemoryFormSheet extends StatefulWidget {
  final CollectionReference memoriesRef;
  final DocumentSnapshot? existing;

  const _MemoryFormSheet({required this.memoriesRef, this.existing});

  @override
  State<_MemoryFormSheet> createState() => _MemoryFormSheetState();
}

class _MemoryFormSheetState extends State<_MemoryFormSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addedByCtrl = TextEditingController();
  File? _imageFile;
  String? _existingPhotoUrl;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final data = widget.existing!.data() as Map<String, dynamic>;
      _titleCtrl.text = data['title'] ?? '';
      _descCtrl.text = data['description'] ?? '';
      _addedByCtrl.text = data['addedBy'] ?? '';
      _existingPhotoUrl = data['photoUrl'];
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _addedByCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose Photo',
                style: GoogleFonts.dmSerifDisplay(
                    color: AppTheme.textPrimary, fontSize: 18)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppTheme.primary),
              title: Text('Gallery',
                  style: GoogleFonts.dmSans(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppTheme.primary),
              title: Text('Camera',
                  style: GoogleFonts.dmSans(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadPhoto() async {
    if (_imageFile == null) return _existingPhotoUrl;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseStorage.instance
        .ref()
        .child('memory_photos/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(_imageFile!);
    return await ref.getDownloadURL();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a title', style: GoogleFonts.dmSans()),
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
      final photoUrl = await _uploadPhoto();

      final data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'addedBy': _addedByCtrl.text.trim(),
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_isEditing) {
        await widget.memoriesRef.doc(widget.existing!.id).update(data);
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        await widget.memoriesRef.add(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isEditing ? 'Memory updated!' : 'Memory saved!',
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
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(_isEditing ? 'Edit Memory' : 'Add Memory',
                style: GoogleFonts.dmSerifDisplay(
                    color: AppTheme.textPrimary, fontSize: 22)),
            const SizedBox(height: 6),
            Text('Capture a precious moment to remember.',
                style: GoogleFonts.dmSans(
                    color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),

            // Photo picker
            GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!), fit: BoxFit.cover)
                      : _existingPhotoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(_existingPhotoUrl!),
                              fit: BoxFit.cover)
                          : null,
                ),
                child: (_imageFile == null && _existingPhotoUrl == null)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined,
                              color: AppTheme.primary, size: 40),
                          const SizedBox(height: 8),
                          Text('Tap to add photo',
                              style: GoogleFonts.dmSans(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13)),
                        ],
                      )
                    : Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_outlined,
                                color: AppTheme.background, size: 14),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Memory title
            _label('Memory Title *'),
            _textField(
              controller: _titleCtrl,
              hint: 'e.g. Family Trip to Langkawi',
              icon: Icons.title_rounded,
            ),
            const SizedBox(height: 14),

            // Description
            _label('Description'),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              style: GoogleFonts.dmSans(
                  color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText:
                    'Write something about this memory...',
                hintStyle: GoogleFonts.dmSans(
                    color: AppTheme.textSecondary, fontSize: 14),
                filled: true,
                fillColor: AppTheme.surfaceAlt,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppTheme.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Added by
            _label('Added By'),
            _textField(
              controller: _addedByCtrl,
              hint: 'e.g. Daughter, Ahmad',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 28),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.background),
                      )
                    : Text(
                        _isEditing ? 'Save Changes' : 'Save Memory',
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
  }) =>
      TextField(
        controller: controller,
        style: GoogleFonts.dmSans(
            color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(
              color: AppTheme.textSecondary, fontSize: 14),
          prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
          filled: true,
          fillColor: AppTheme.surfaceAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
        ),
      );
}