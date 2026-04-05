import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/document_model.dart';
import '../view_models/document_view_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UploadDocumentView extends StatefulWidget {
  final DocumentViewModel viewModel;

  const UploadDocumentView({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<UploadDocumentView> createState() => _UploadDocumentViewState();
}

class _UploadDocumentViewState extends State<UploadDocumentView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _versionController = TextEditingController();
  String _selectedType = 'Pitch Deck';
  bool _isBlockchainEnabled = true;
  String _visibilityMode = 'Riêng tư'; // 'Riêng tư' or 'Công khai'
  DocumentVisibility _sharedWith = DocumentVisibility.investor; 

  final List<String> _documentTypes = ['Pitch Deck', 'Pháp lý', 'Tài chính', 'Kỹ thuật', 'Khác'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StartupOnboardingTheme.navyBg,
      appBar: AppBar(
        backgroundColor: StartupOnboardingTheme.navyBg,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: StartupOnboardingTheme.softIvory),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tải lên tài liệu',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.softIvory,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. File Upload Area (Simulated)
              _buildFileUploadArea(),
              const SizedBox(height: 32),

              // 2. Metadata Form
              Text(
                'THÔNG TIN TÀI LIỆU',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: StartupOnboardingTheme.goldAccent,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _buildFieldLabel('Tên tài liệu'),
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory),
                decoration: _getInputDecoration('VD: AISEP_Pitch_Deck_2024.pdf'),
                validator: (v) => v?.isEmpty ?? true ? 'Vui lòng nhập tên file' : null,
              ),
              const SizedBox(height: 20),

              _buildFieldLabel('Loại tài liệu'),
              DropdownButtonFormField<String>(
                value: _selectedType,
                dropdownColor: StartupOnboardingTheme.navySurface,
                icon: const Icon(LucideIcons.chevronDown, color: StartupOnboardingTheme.goldAccent, size: 20),
                style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory),
                decoration: _getInputDecoration(null),
                items: _documentTypes.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t),
                )).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 20),

              _buildFieldLabel('Phiên bản'),
              TextFormField(
                controller: _versionController,
                style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory),
                decoration: _getInputDecoration('VD: 1.2.0'),
              ),
              const SizedBox(height: 20),

              _buildFieldLabel('Mô tả (Tùy chọn)'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory),
                decoration: _getInputDecoration('Nhập tóm tắt ngắn về tài liệu này...'),
              ),

              const SizedBox(height: 16),

              // 3. Blockchain Switch
              _buildBlockchainOption(),
              const SizedBox(height: 24),

              // 4. Visibility Control
              _buildVisibilitySection(),
              const SizedBox(height: 48),

              // 4. Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleUpload,
                  child: const Text('Xác nhận & Tải lên'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: StartupOnboardingTheme.softIvory.withOpacity(0.9),
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.workSans(
        color: StartupOnboardingTheme.slateGray.withOpacity(0.5),
      ),
      filled: true,
      fillColor: StartupOnboardingTheme.navySurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: StartupOnboardingTheme.goldAccent, width: 1.5),
      ),
    );
  }

  Widget _buildFileUploadArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: StartupOnboardingTheme.goldAccent.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid, // Note: Dash border requires custom painter or package, using solid for now
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.upload, size: 48, color: StartupOnboardingTheme.goldAccent),
          const SizedBox(height: 16),
          Text(
            'Chọn tệp hoặc kéo thả trực tiếp',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: StartupOnboardingTheme.softIvory,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hỗ trợ PDF, DOCX, XLSX, IMG (Max 10MB)',
            style: GoogleFonts.workSans(
              fontSize: 12,
              color: StartupOnboardingTheme.slateGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Chế độ hiển thị'),
        DropdownButtonFormField<String>(
          value: _visibilityMode,
          dropdownColor: StartupOnboardingTheme.navySurface,
          icon: const Icon(LucideIcons.chevronDown, color: StartupOnboardingTheme.goldAccent, size: 20),
          style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory),
          decoration: _getInputDecoration(null),
          items: ['Riêng tư', 'Công khai'].map((m) => DropdownMenuItem(
            value: m,
            child: Text(m),
          )).toList(),
          onChanged: (v) => setState(() => _visibilityMode = v!),
        ),
        if (_visibilityMode == 'Công khai') ...[
          const SizedBox(height: 20),
          _buildFieldLabel('Chia sẻ với'),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: StartupOnboardingTheme.navySurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                _buildVisibilityOption(
                  'Nhà đầu tư (Investor)', 
                  LucideIcons.trendingUp, 
                  DocumentVisibility.investor
                ),
                const Divider(color: Colors.white10, height: 1),
                _buildVisibilityOption(
                  'Cố vấn (Advisor)', 
                  LucideIcons.shield, 
                  DocumentVisibility.advisor
                ),
                const Divider(color: Colors.white10, height: 1),
                _buildVisibilityOption(
                  'Tất cả (Both)', 
                  LucideIcons.users, 
                  DocumentVisibility.both
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVisibilityOption(String label, IconData icon, DocumentVisibility value) {
    final bool isSelected = _sharedWith == value;
    return InkWell(
      onTap: () => setState(() => _sharedWith = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.softIvory.withOpacity(0.3)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  color: isSelected ? StartupOnboardingTheme.softIvory : StartupOnboardingTheme.softIvory.withOpacity(0.5),
                ),
              ),
            ),
            if (isSelected)
              const Icon(LucideIcons.check, size: 18, color: StartupOnboardingTheme.goldAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockchainOption() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StartupOnboardingTheme.goldAccent.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.shieldCheck, color: StartupOnboardingTheme.goldAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xác thực Blockchain',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: StartupOnboardingTheme.softIvory,
                  ),
                ),
                Text(
                  'Tạo mã băm và lưu trữ timestamp.',
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: StartupOnboardingTheme.slateGray,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isBlockchainEnabled,
            onChanged: (v) => setState(() => _isBlockchainEnabled = v),
            activeColor: StartupOnboardingTheme.goldAccent,
          ),
        ],
      ),
    );
  }

  void _handleUpload() {
    if (_formKey.currentState?.validate() ?? false) {
      final newDoc = DocumentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: _nameController.text.isNotEmpty ? _nameController.text : 'Tài liệu không tên.pdf',
        type: _selectedType,
        uploadDate: DateTime.now(),
        sizeInMb: 2.5,
        status: DocumentStatus.uploaded,
        visibility: _visibilityMode == 'Riêng tư' ? DocumentVisibility.private : _sharedWith,
        description: _descriptionController.text,
        version: _versionController.text,
      );

      widget.viewModel.uploadDocument(newDoc);
      Navigator.pop(context, true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đang bắt đầu bảo mật tài liệu: ${newDoc.fileName}'),
          backgroundColor: StartupOnboardingTheme.goldAccent,
        ),
      );
    }
  }
}
