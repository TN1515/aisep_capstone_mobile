import 'dart:io';
import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';

class DocumentViewModel extends ChangeNotifier {
  final DocumentService _service = DocumentService();

  List<DocumentModel> _documents = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DocumentModel> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DocumentViewModel() {
    loadDocuments();
  }

  // 1. Tải danh sách tài liệu
  Future<void> loadDocuments({bool isArchived = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.getDocuments(isArchived: isArchived);
      if (response.success) {
        _documents = response.data ?? [];
      } else {
        _errorMessage = response.error;
      }
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi kết nối: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Tải lên tài liệu
  Future<bool> uploadDocument({
    required File file,
    required DocumentType type,
    String? title,
    String? version,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.uploadDocument(
      file: file,
      type: type,
      title: title,
      version: version,
    );

    _isLoading = false;
    if (response.success) {
      if (response.data != null) {
        _documents.insert(0, response.data!);
      }
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.error;
      notifyListeners();
      return false;
    }
  }

  // 3. Cập nhật Metadata
  Future<bool> updateMetadata(int id, {String? title, int? type, bool? isArchived}) async {
    final response = await _service.updateMetadata(id, title: title, type: type, isArchived: isArchived);
    if (response.success) {
      // Refresh local list
      await loadDocuments(isArchived: isArchived ?? false);
      return true;
    }
    return false;
  }

  // 4. Soft Delete / Archive
  Future<bool> deleteDocument(int id) async {
    final response = await _service.deleteDocument(id);
    if (response.success) {
      _documents.removeWhere((doc) => doc.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- BLOCKCHAIN ACTIONS ---

  // Tính Hash
  Future<bool> computeHash(int id) async {
    final response = await _service.computeHash(id);
    if (response.success) {
      await _refreshDocument(id);
      return true;
    }
    return false;
  }

  // Submit to Chain
  Future<bool> submitToChain(int id) async {
    final response = await _service.submitToChain(id);
    if (response.success) {
      await _refreshDocument(id);
      return true;
    }
    return false;
  }

  // Check Status
  Future<void> checkTxStatus(int id) async {
    await _service.checkTxStatus(id);
    await _refreshDocument(id);
  }

  // Verify
  Future<String?> verifyOnChain(int id) async {
    final response = await _service.verifyOnChain(id);
    if (response.success) {
      await _refreshDocument(id);
      return response.data; // e.g. "Verified"
    }
    return null;
  }

  // Legacy stub
  Future<void> restoreVersion(int docId, String versionId) async {
    // Placeholder for future implementation
    notifyListeners();
  }

  // Helper to refresh a single document in the list
  Future<void> _refreshDocument(int id) async {
    // For simplicity, reload all for now, or find specific if API supports it
    // In a production app, we would have a GET /api/documents/{id}
    await loadDocuments();
  }
}
