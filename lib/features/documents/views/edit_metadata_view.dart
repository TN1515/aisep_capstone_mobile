import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/document_model.dart';
import '../view_models/document_view_model.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';

class EditMetadataView extends StatefulWidget {
  final DocumentModel document;

  const EditMetadataView({super.key, required this.document});

  @override
  State<EditMetadataView> createState() => _EditMetadataViewState();
}

class _EditMetadataViewState extends State<EditMetadataView> {
  late TextEditingController _titleController;
  late DocumentType _selectedType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document.title ?? widget.document.fileName);
    _selectedType = widget.document.documentType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chỉnh sửa Metadata',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(context, 'Tiêu đề hiển thị', _titleController, LucideIcons.fileText),
            const SizedBox(height: 20),
            _buildTypeDropdown(context, textColor),
            const SizedBox(height: 32),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, TextEditingController controller, IconData icon) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.workSans(color: textColor),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: theme.primaryColor.withOpacity(0.5)),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.dividerColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.primaryColor)),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown(BuildContext context, Color textColor) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại tài liệu',
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DocumentType>(
              value: _selectedType,
              isExpanded: true,
              dropdownColor: theme.cardColor,
              icon: Icon(LucideIcons.chevronDown, size: 18, color: theme.primaryColor),
              items: DocumentType.values.map((t) => DropdownMenuItem(
                value: t,
                child: Text(t.label, style: GoogleFonts.workSans(color: textColor)),
              )).toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildSubmitButton(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.read<DocumentViewModel>();
    
    return ElevatedButton(
      onPressed: viewModel.isLoading ? null : () async {
        final success = await viewModel.updateMetadata(
          widget.document.id,
          title: _titleController.text,
          type: _selectedType.value,
        );
        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật metadata thành công')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: viewModel.isLoading
        ? const CircularProgressIndicator(color: Colors.white)
        : Text(
            'Lưu thay đổi',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
    );
  }
}
