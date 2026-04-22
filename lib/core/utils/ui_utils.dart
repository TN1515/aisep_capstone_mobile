import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:developer' as dev;
import '../config/app_config.dart';

class UIUtils {
  static void showImagePreview(BuildContext context, {String? imageUrl, File? imageFile, String? tag}) {
    if ((imageUrl == null || imageUrl.isEmpty) && imageFile == null) return;
    if (imageUrl != null && imageUrl.contains('placeholder')) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.black.withOpacity(0.9),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: tag != null
                  ? Hero(
                      tag: tag,
                      child: _buildImage(imageUrl, imageFile),
                    )
                  : _buildImage(imageUrl, imageFile),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(LucideIcons.x, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildImage(String? imageUrl, File? imageFile) {
    if (imageFile != null) {
      return Image.file(imageFile, fit: BoxFit.contain);
    }
    return Image.network(
      imageUrl!,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      },
    );
  }

  static String? getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    
    final baseUrl = AppConfig.apiBaseUrl;
    // Normalize path: replace backslashes with forward slashes and remove leading slash
    final normalizedPath = path.replaceAll('\\', '/');
    final cleanPath = normalizedPath.startsWith('/') ? normalizedPath.substring(1) : normalizedPath;
    
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    
    final fullUrl = '$cleanBaseUrl$cleanPath';
    dev.log('Built Image URL: $fullUrl', name: 'NETWORK');
    return fullUrl;
  }

  static String formatExpertiseLabel(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('capital') || lower.contains('raising') || lower.contains('goi_von')) return 'Gọi vốn';
    if (lower.contains('strategy') || lower.contains('chien_luoc')) return 'Chiến lược SP';
    if (lower.contains('market') || lower.contains('gtm') || lower.contains('go_to_market')) return 'Go-to-market';
    if (lower.contains('finance') || lower.contains('tai_chinh')) return 'Tài chính';
    if (lower.contains('legal') || lower.contains('phap_ly')) return 'Pháp lý & SHTT';
    if (lower.contains('operations') || lower.contains('van_hanh')) return 'Vận hành';
    if (lower.contains('technology') || lower.contains('cong_nghe')) return 'Công nghệ';
    if (lower.contains('marketing')) return 'Marketing';
    if (lower.contains('human') || lower.contains('nhan_su') || lower.contains('hr') || lower.contains('team_building')) return 'Nhân sự';
    return label.replaceAll('_', ' ').split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}' : '').join(' ');
  }
}
