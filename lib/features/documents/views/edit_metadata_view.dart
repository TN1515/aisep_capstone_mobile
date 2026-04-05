import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/document_model.dart';
import '../view_models/document_view_model.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/core/utils/toast_utils.dart';

class EditMetadataView extends StatefulWidget {
  final DocumentModel document;

  const EditMetadataView({super.key, required this.document});

  @override
  State<EditMetadataView> createState() => _EditMetadataViewState();
}

class _EditMetadataViewState extends State<EditMetadataView> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late String _selectedType;
  late DocumentVisibility _selectedVisibility;

  final List<String> _types = ['Pitch Deck', 'Tài chính', 'Pháp lý', 'Nghiên cứu', 'Khác'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.document.fileName);
    _descController = TextEditingController(text: widget.document.description ?? '');
    _selectedType = widget.document.type;
    _selectedVisibility = widget.document.visibility;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: StartupOnboardingTheme.navySurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                  color: Colors.white.withOpacity(0.1),
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
                color: StartupOnboardingTheme.softIvory,
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField('Tên tài liệu', _nameController, LucideIcons.fileText),
            const SizedBox(height: 20),
            _buildDropdownField('Loại tài liệu', _selectedType, _types, (val) {
              if (val != null) setState(() => _selectedType = val);
            }, LucideIcons.tag),
            const SizedBox(height: 20),
            _buildTextField('Mô tả', _descController, LucideIcons.alignLeft, maxLines: 3),
            const SizedBox(height: 20),
            _buildVisibilitySelector(),
            const SizedBox(height: 32),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.goldAccent.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: StartupOnboardingTheme.goldAccent.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.black.withOpacity(0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: StartupOnboardingTheme.goldAccent)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, Function(String?) onChanged, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.goldAccent.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: StartupOnboardingTheme.navySurface,
              icon: const Icon(LucideIcons.chevronDown, size: 18, color: StartupOnboardingTheme.goldAccent),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 16, color: StartupOnboardingTheme.goldAccent.withOpacity(0.5)),
                      const SizedBox(width: 12),
                      Text(item, style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quyền riêng tư',
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.goldAccent.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: DocumentVisibility.values.map((v) {
            final isSelected = _selectedVisibility == v;
            return ChoiceChip(
              label: Text(_getVisibilityLabel(v), style: GoogleFonts.workSans(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedVisibility = v);
              },
              selectedColor: StartupOnboardingTheme.goldAccent,
              backgroundColor: Colors.white.withOpacity(0.05),
              labelStyle: TextStyle(color: isSelected ? StartupOnboardingTheme.navyBg : StartupOnboardingTheme.softIvory),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getVisibilityLabel(DocumentVisibility v) {
    switch (v) {
      case DocumentVisibility.private: return 'Cá nhân';
      case DocumentVisibility.investor: return 'Nhà đầu tư';
      case DocumentVisibility.advisor: return 'Cố vấn';
      case DocumentVisibility.both: return 'Công khai';
    }
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<DocumentViewModel>().updateDocumentMetadata(
          widget.document.id,
          fileName: _nameController.text,
          type: _selectedType,
          description: _descController.text,
          visibility: _selectedVisibility,
        );
        Navigator.pop(context);
        ToastUtils.showTopToast(context, 'Đã cập nhật metadata thành công.');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: StartupOnboardingTheme.goldAccent,
        foregroundColor: StartupOnboardingTheme.navyBg,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        'Lưu thay đổi',
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      ),
    );
  }
}
