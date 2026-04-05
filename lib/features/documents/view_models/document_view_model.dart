import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../models/ai_evaluation_model.dart';
import 'dart:async';

class DocumentViewModel extends ChangeNotifier {
  List<DocumentModel> _documents = [];
  List<AiEvaluationModel> _evaluationHistory = [];
  bool _isLoading = false;

  List<DocumentModel> get documents => _documents;
  List<AiEvaluationModel> get evaluationHistory => _evaluationHistory;
  bool get isLoading => _isLoading;

  DocumentViewModel() {
    _loadInitialDocuments();
  }

  void _loadInitialDocuments() {
    // 1. Mock Documents
    _documents = [
      DocumentModel(
        id: '1',
        fileName: 'Pitch_Deck_V2.pdf',
        type: 'Pitch Deck',
        uploadDate: DateTime.now().subtract(const Duration(days: 2)),
        sizeInMb: 4.2,
        status: DocumentStatus.aiCompleted,
        txHash: '0x71C7656EC7ab88b098defB751B7401B5f6d8976F',
        fileHash: 'SHA256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        visibility: DocumentVisibility.both,
        aiScore: 8.5,
        aiReportId: 'rep_1',
        version: '2.0',
        versions: [
          DocumentVersion(id: 'v1', version: '1.0', date: DateTime.now().subtract(const Duration(days: 10)), author: 'Founder', sizeInMb: 3.8),
          DocumentVersion(id: 'v2', version: '2.0', date: DateTime.now().subtract(const Duration(days: 2)), author: 'Founder', sizeInMb: 4.2),
        ],
      ),
      DocumentModel(
        id: '2',
        fileName: 'Financial_Report_Q1_2024.xlsx',
        type: 'Tài chính',
        uploadDate: DateTime.now().subtract(const Duration(hours: 5)),
        sizeInMb: 1.8,
        status: DocumentStatus.pendingBlockchain,
        txHash: '0xbc93...a1f2',
        visibility: DocumentVisibility.investor,
        version: '1.0',
        versions: [
          DocumentVersion(id: 'v1', version: '1.0', date: DateTime.now().subtract(const Duration(hours: 5)), author: 'CFO', sizeInMb: 1.8),
        ],
      ),
      DocumentModel(
        id: '3',
        fileName: 'Business_License.png',
        type: 'Pháp lý',
        uploadDate: DateTime.now().subtract(const Duration(days: 10)),
        sizeInMb: 0.5,
        status: DocumentStatus.verified,
        visibility: DocumentVisibility.advisor,
        version: '1.1',
        versions: [
          DocumentVersion(id: 'v1', version: '1.0', date: DateTime.now().subtract(const Duration(days: 15)), author: 'Legal', sizeInMb: 0.4),
          DocumentVersion(id: 'v2', version: '1.1', date: DateTime.now().subtract(const Duration(days: 10)), author: 'Legal', sizeInMb: 0.5),
        ],
      ),
      DocumentModel(
        id: '4',
        fileName: 'Market_Research_2024.pdf',
        type: 'Nghiên cứu',
        uploadDate: DateTime.now().subtract(const Duration(days: 5)),
        sizeInMb: 12.5,
        status: DocumentStatus.uploaded,
        visibility: DocumentVisibility.private,
        version: '1.0',
        versions: [
          DocumentVersion(id: 'v1', version: '1.0', date: DateTime.now().subtract(const Duration(days: 5)), author: 'Marketing', sizeInMb: 12.5),
        ],
      ),
    ];

    // 2. Mock AI Evaluations
    _evaluationHistory = [
      AiEvaluationModel(
        id: 'rep_1',
        documentId: '1',
        documentName: 'Pitch_Deck_V2.pdf',
        overallScore: 8.5,
        evaluationDate: DateTime.now().subtract(const Duration(days: 2)),
        summary: 'Startup có tiềm năng tăng trưởng cao nhờ giải pháp công nghệ đột phá trong mảng Fintech.',
        metrics: {
          'Quy mô thị trường': 9.0,
          'Đội ngũ sáng lập': 8.5,
          'Sản phẩm/Công nghệ': 8.0,
          'Mô hình kinh doanh': 8.5,
        },
        strengths: [
          'Đội ngũ founder có kinh nghiệm sâu trong ngành.',
          'Sản phẩm đã có traction tốt tại thị trường địa phương.',
        ],
        weaknesses: [
          'Chi phí vận hành còn cao.',
          'Cạnh tranh từ các đối thủ lớn đang gia tăng.',
        ],
        fullReportUrl: 'https://aisep.io/reports/123',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void updateDocumentMetadata(String id, {String? fileName, String? type, String? description, DocumentVisibility? visibility}) {
    final index = _documents.indexWhere((doc) => doc.id == id);
    if (index != -1) {
      _documents[index] = _documents[index].copyWith(
        fileName: fileName,
        type: type,
        description: description,
        visibility: visibility,
      );
      notifyListeners();
    }
  }

  Future<void> restoreVersion(String docId, String versionId) async {
    _isLoading = true;
    notifyListeners();

    // Simulate restoring (1.5 seconds)
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final index = _documents.indexWhere((doc) => doc.id == docId);
    if (index != -1) {
      final selectedVersion = _documents[index].versions?.firstWhere((v) => v.id == versionId);
      if (selectedVersion != null) {
        _documents[index] = _documents[index].copyWith(
          version: selectedVersion.version,
          status: DocumentStatus.verified, // Assume restored version is verified
        );
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> requestAiEvaluation(String docId) async {
    final index = _documents.indexWhere((d) => d.id == docId);
    if (index == -1) return;

    _documents[index] = _documents[index].copyWith(status: DocumentStatus.aiEvaluating);
    notifyListeners();

    // Simulate AI processing (4 seconds)
    await Future.delayed(const Duration(seconds: 4));

    final newReportId = 'rep_${DateTime.now().millisecondsSinceEpoch}';
    final score = 7.5 + (DateTime.now().millisecond % 20) / 10.0;

    _documents[index] = _documents[index].copyWith(
      status: DocumentStatus.aiCompleted,
      aiScore: score,
      aiReportId: newReportId,
    );

    _evaluationHistory.insert(0, AiEvaluationModel(
      id: newReportId,
      documentId: docId,
      documentName: _documents[index].fileName,
      overallScore: score,
      evaluationDate: DateTime.now(),
      summary: 'Phân tích tự động dựa trên tài liệu mới tải lên. Startup cho thấy sự ổn định về mặt pháp lý.',
      metrics: {'Thanh khoản': 7.0, 'Rủi ro': 8.0, 'Tăng trưởng': 7.5},
      strengths: ['Tài liệu đầy đủ', 'Tuân thủ pháp lý'],
      weaknesses: ['Chưa rõ kế hoạch exit'],
      fullReportUrl: 'https://aisep.io/reports/$newReportId',
    ));

    notifyListeners();
  }

  Future<void> verifyOnChain(String docId) async {
    final index = _documents.indexWhere((d) => d.id == docId);
    if (index == -1) return;

    // Simulate verification check (2 seconds)
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real app, this would check if the hash in DB matches on-chain hash
    _updateDocStatus(docId, DocumentStatus.verified);
  }

  Future<void> uploadDocument(DocumentModel newDoc) async {
    // 1. Initial Upload
    _documents.insert(0, newDoc.copyWith(status: DocumentStatus.uploaded));
    notifyListeners();

    // 2. Simulate Hashing (2 seconds)
    await Future.delayed(const Duration(seconds: 2));
    _updateDocStatus(newDoc.id, DocumentStatus.hashing);

    // 3. Simulate Blockchain Submission (3 seconds)
    await Future.delayed(const Duration(seconds: 3));
    _updateDocStatus(newDoc.id, DocumentStatus.pendingBlockchain, 
      txHash: '0x${DateTime.now().millisecondsSinceEpoch}pending...',
      fileHash: 'SHA256:${DateTime.now().hashCode}hash...'
    );

    // 4. Simulate Final Confirmation (5 seconds)
    await Future.delayed(const Duration(seconds: 5));
    _updateDocStatus(newDoc.id, DocumentStatus.verified,
      txHash: '0x${DateTime.now().millisecondsSinceEpoch}verified'
    );
  }

  void _updateDocStatus(String id, DocumentStatus status, {String? txHash, String? fileHash}) {
    final index = _documents.indexWhere((doc) => doc.id == id);
    if (index != -1) {
      _documents[index] = _documents[index].copyWith(
        status: status,
        txHash: txHash,
        fileHash: fileHash,
      );
      notifyListeners();
    }
  }

  void refresh() {
    _loadInitialDocuments();
  }
}
