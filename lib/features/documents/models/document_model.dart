import 'package:flutter/material.dart';

enum DocumentStatus {
  uploaded,
  hashing,
  pendingBlockchain,
  verified,
  failed,
  aiEvaluating,
  aiCompleted,
  blockchainFailed,
}

enum DocumentVisibility {
  private,
  investor,
  advisor,
  both,
}

class DocumentVersion {
  final String id;
  final String version;
  final DateTime date;
  final String author;
  final double sizeInMb;

  const DocumentVersion({
    required this.id,
    required this.version,
    required this.date,
    required this.author,
    required this.sizeInMb,
  });
}

class DocumentModel {
  final String id;
  final String fileName;
  final String type; // e.g., 'Pitch Deck', 'Legal', 'Financial'
  final DateTime uploadDate;
  final double sizeInMb;
  final DocumentStatus status;
  final DocumentVisibility visibility;
  final String? description;
  final String? version;
  final List<DocumentVersion>? versions; // New: Version History
  final String? txHash;
  final String? fileHash;
  final double? aiScore;
  final String? aiReportId;

  DocumentModel({
    required this.id,
    required this.fileName,
    required this.type,
    required this.uploadDate,
    required this.sizeInMb,
    required this.status,
    required this.visibility,
    this.description,
    this.version,
    this.versions,
    this.txHash,
    this.fileHash,
    this.aiScore,
    this.aiReportId,
  });

  DocumentModel copyWith({
    DocumentStatus? status,
    DocumentVisibility? visibility,
    String? version,
    List<DocumentVersion>? versions,
    String? txHash,
    String? fileHash,
    double? aiScore,
    String? aiReportId,
    String? fileName,
    String? type,
    String? description,
  }) {
    return DocumentModel(
      id: id,
      fileName: fileName ?? this.fileName,
      type: type ?? this.type,
      uploadDate: uploadDate,
      sizeInMb: sizeInMb,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      description: description ?? this.description,
      version: version ?? this.version,
      versions: versions ?? this.versions,
      txHash: txHash ?? this.txHash,
      fileHash: fileHash ?? this.fileHash,
      aiScore: aiScore ?? this.aiScore,
      aiReportId: aiReportId ?? this.aiReportId,
    );
  }
}
