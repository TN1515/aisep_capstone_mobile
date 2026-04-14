import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/document_model.dart';
import '../view_models/document_view_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';

class UploadDocumentView extends StatefulWidget {
  final DocumentViewModel viewModel;

  const UploadDocumentView({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<UploadDocumentView> createState() => _UploadDocumentViewState();
}

class _UploadDocumentViewState extends State<UploadDocumentView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _versionController = TextEditingController();
  DocumentType _selectedType = DocumentType.pitchDeck;
  File? _selectedFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tải lên tài liệu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. File Upload Area
              _buildFileUploadArea(context),
              const SizedBox(height: 32),

              // 2. Metadata Form
              _buildFormFields(context, textColor),
              const SizedBox(height: 48),

              // 3. Submit Button
              _buildSubmitButton(context, theme),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadArea(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _selectedFile != null ? Colors.greenAccent.withOpacity(0.5) : theme.primaryColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedFile != null ? LucideIcons.fileCheck : LucideIcons.upload, 
              size: 48, 
              color: _selectedFile != null ? Colors.greenAccent : theme.primaryColor
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFile != null 
                ? _selectedFile!.path.split('/').last 
                : 'Chọn tệp tài liệu',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFile != null 
                ? 'Đã chọn tệp. Nhấn để thay đổi.' 
                : 'Hỗ trợ PDF, PPTX, DOCX (Max 20MB)',
              style: GoogleFonts.workSans(
                fontSize: 12,
                color: textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(BuildContext context, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'THÔNG TIN TÀI LIỆU'),
        const SizedBox(height: 16),
        
        _buildFieldLabel(context, 'Tiêu đề hiển thị (Tùy chọn)'),
        TextFormField(
          controller: _titleController,
          style: GoogleFonts.workSans(color: textColor),
          decoration: _getInputDecoration(context, 'VD: Pitch Deck Q2 2024'),
        ),
        const SizedBox(height: 20),

        _buildFieldLabel(context, 'Loại tài liệu'),
        DropdownButtonFormField<DocumentType>(
          value: _selectedType,
          dropdownColor: Theme.of(context).cardColor,
          icon: const Icon(LucideIcons.chevronDown, size: 20),
          style: GoogleFonts.workSans(color: textColor),
          decoration: _getInputDecoration(context, null),
          items: DocumentType.values.map((t) => DropdownMenuItem(
            value: t,
            child: Text(t.label),
          )).toList(),
          onChanged: (v) => setState(() => _selectedType = v!),
        ),
        const SizedBox(height: 20),

        _buildFieldLabel(context, 'Phiên bản (Tùy chọn)'),
        TextFormField(
          controller: _versionController,
          style: GoogleFonts.workSans(color: textColor),
          decoration: _getInputDecoration(context, 'VD: 1.0.1'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.9),
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(BuildContext context, String? hint) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.workSans(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4)),
      filled: true,
      fillColor: theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: widget.viewModel.isLoading ? null : _handleUpload,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: theme.brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: widget.viewModel.isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              'Xác nhận & Tải lên',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
            ),
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'pptx'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn tệp tin')),
      );
      return;
    }

    final success = await widget.viewModel.uploadDocument(
      file: _selectedFile!,
      type: _selectedType,
      title: _titleController.text.isNotEmpty ? _titleController.text : null,
      version: _versionController.text.isNotEmpty ? _versionController.text : null,
    );

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.errorMessage ?? 'Tải lên thất bại'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
