import 'package:flutter/material.dart';

// Kiểu tài liệu (Enum từ Backend)
enum DocumentType {
  pitchDeck, // 0
  businessPlan, // 1
  financials, // 2 (Mở rộng)
  legal, // 3 (Mở rộng)
  other, // 4 (Mở rộng)
}

extension DocumentTypeExtension on DocumentType {
  int get value {
    switch (this) {
      case DocumentType.pitchDeck: return 0;
      case DocumentType.businessPlan: return 1;
      case DocumentType.financials: return 2;
      case DocumentType.legal: return 3;
      case DocumentType.other: return 4;
    }
  }

  static DocumentType fromInt(int val) {
    switch (val) {
      case 0: return DocumentType.pitchDeck;
      case 1: return DocumentType.businessPlan;
      case 2: return DocumentType.financials;
      case 3: return DocumentType.legal;
      default: return DocumentType.other;
    }
  }

  String get label {
    switch (this) {
      case DocumentType.pitchDeck: return 'Pitch Deck';
      case DocumentType.businessPlan: return 'Business Plan';
      case DocumentType.financials: return 'Tài chính';
      case DocumentType.legal: return 'Pháp lý';
      case DocumentType.other: return 'Khác';
    }
  }
}

// Trạng thái Blockchain (ProofStatus từ Backend)
enum ProofStatus {
  anchored, // 0 - Thành công
  none, // 1 - Chưa có gì
  hashComputed, // 2 - Đã tính Hash
  pending, // 3 - Đang chờ gửi hoặc chờ block
  failed, // 4 - Thất bại
}

extension ProofStatusExtension on ProofStatus {
  int get value {
    switch (this) {
      case ProofStatus.anchored: return 0;
      case ProofStatus.none: return 1;
      case ProofStatus.hashComputed: return 2;
      case ProofStatus.pending: return 3;
      case ProofStatus.failed: return 4;
    }
  }

  static ProofStatus fromInt(int val) {
    switch (val) {
      case 0: return ProofStatus.anchored;
      case 1: return ProofStatus.none;
      case 2: return ProofStatus.hashComputed;
      case 3: return ProofStatus.pending;
      case 4: return ProofStatus.failed;
      default: return ProofStatus.none;
    }
  }

  String get label {
    switch (this) {
      case ProofStatus.anchored: return 'Đã xác thực (Anchored)';
      case ProofStatus.none: return 'Chưa xác thực';
      case ProofStatus.hashComputed: return 'Đã tính mã Hash';
      case ProofStatus.pending: return 'Chờ Blockchain...';
      case ProofStatus.failed: return 'Thất bại';
    }
  }

  Color get color {
    switch (this) {
      case ProofStatus.anchored: return Colors.green;
      case ProofStatus.none: return Colors.grey;
      case ProofStatus.hashComputed: return Colors.blue;
      case ProofStatus.pending: return Colors.orange;
      case ProofStatus.failed: return Colors.red;
    }
  }
}

// Trạng thái duyệt (DocumentReviewStatus)
enum DocumentReviewStatus {
  pending, // 0
  verified, // 1
  approved, // 2
  rejected, // 3
}

class DocumentModel {
  final int id;
  final String? title;
  final String fileName;
  final String fileUrl;
  final DocumentType documentType;
  final double sizeInBytes;
  final String? version;
  final bool isArchived;
  final DateTime uploadDate;
  
  // Blockchain info
  final ProofStatus proofStatus;
  final String? fileHash;
  final String? transactionHash;
  
  // Review info
  final DocumentReviewStatus reviewStatus;

  DocumentModel({
    required this.id,
    this.title,
    required this.fileName,
    required this.fileUrl,
    required this.documentType,
    required this.sizeInBytes,
    this.version,
    this.isArchived = false,
    required this.uploadDate,
    this.proofStatus = ProofStatus.none,
    this.fileHash,
    this.transactionHash,
    this.reviewStatus = DocumentReviewStatus.pending,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString(),
      fileName: json['fileName']?.toString() ?? 'Unnamed',
      fileUrl: json['fileUrl']?.toString() ?? '',
      documentType: DocumentTypeExtension.fromInt(int.tryParse(json['documentType']?.toString() ?? '0') ?? 0),
      sizeInBytes: double.tryParse(json['sizeInBytes']?.toString() ?? '0') ?? 0.0,
      version: json['version']?.toString(),
      isArchived: json['isArchived'] == true || json['isArchived'] == 'true',
      uploadDate: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
      proofStatus: _parseProofStatus(json['proofStatus']),
      fileHash: json['fileHash']?.toString(),
      transactionHash: json['transactionHash']?.toString(),
      reviewStatus: _parseReviewStatus(json['reviewStatus']),
    );
  }

  static ProofStatus _parseProofStatus(dynamic val) {
    if (val == null) return ProofStatus.none;
    
    // Handle both integer and string (enum name) from Backend
    if (val is int) return ProofStatusExtension.fromInt(val);
    
    String strVal = val.toString().toLowerCase();
    switch (strVal) {
      case '0':
      case 'anchored': return ProofStatus.anchored;
      case '1':
      case 'none': return ProofStatus.none;
      case '2':
      case 'hashcomputed': return ProofStatus.hashComputed;
      case '3':
      case 'pending': return ProofStatus.pending;
      case '4':
      case 'failed': return ProofStatus.failed;
      default: return ProofStatus.none;
    }
  }

  static DocumentReviewStatus _parseReviewStatus(dynamic val) {
    int intVal = int.tryParse(val?.toString() ?? '0') ?? 0;
    switch (intVal) {
      case 0: return DocumentReviewStatus.pending;
      case 1: return DocumentReviewStatus.verified;
      case 2: return DocumentReviewStatus.approved;
      case 3: return DocumentReviewStatus.rejected;
      default: return DocumentReviewStatus.pending;
    }
  }

  // Legacy compatibility getters
  String get type => documentType.label;
  int get status {
    // Return index for legacy integer comparisons
    if (proofStatus == ProofStatus.anchored) return 0;
    if (proofStatus == ProofStatus.none) return 1;
    if (proofStatus == ProofStatus.hashComputed) return 2;
    if (proofStatus == ProofStatus.pending) return 3;
    if (proofStatus == ProofStatus.failed) return 4;
    return 1; // Fallback
  }
  List<DocumentVersion>? get versions => null; 

  double get sizeInMb => sizeInBytes / (1024 * 1024);
  String get displayTitle => title ?? fileName;
}

// Add a dummy DocumentStatus to fix undefined name errors in legacy widgets
class DocumentStatus {
  static const int anchored = 0;
  static const int none = 1;
  static const int hashComputed = 2;
  static const int pendingBlockchain = 3;
  static const int failed = 4;
  
  // Aliases for review status
  static const int verified = 1; 
  static const int approved = 2;
  static const int rejected = 3;

  // Mock statuses that might be used in legacy code
  static const int uploaded = 10;
  static const int hashing = 11;
  static const int aiEvaluating = 12;
  static const int aiCompleted = 13;
  static const int blockchainFailed = 14;
}

class DocumentVersion {
  final String id;
  final String version;
  final DateTime date;
  final String author;
  final double sizeInMb;

  DocumentVersion({
    required this.id, 
    required this.version, 
    required this.date, 
    required this.author, 
    required this.sizeInMb
  });
}
