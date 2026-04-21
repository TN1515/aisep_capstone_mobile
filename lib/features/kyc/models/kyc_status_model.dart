import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

enum KYCStatus {
  NOT_SUBMITTED,
  PENDING,
  REJECTED,
  APPROVED;

  factory KYCStatus.fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'NOT_SUBMITTED':
      case 'NONE':
        return KYCStatus.NOT_SUBMITTED;
      case 'PENDING':
      case 'UNDER_REVIEW':
        return KYCStatus.PENDING;
      case 'REJECTED':
      case 'FAILED':
        return KYCStatus.REJECTED;
      case 'APPROVED':
      case 'SUCCESS':
        return KYCStatus.APPROVED;
      default:
        return KYCStatus.NOT_SUBMITTED;
    }
  }
}

enum EvidenceFileKind {
  BUSINESS_REGISTRATION, // Giấy phép kinh doanh
  IDENTITY_CARD,          // CMND/CCCD founder
  COMPANY_LOGO,           // Logo công ty
  OTHER;                  // Tài liệu khác

  String get key {
    switch (this) {
      case EvidenceFileKind.BUSINESS_REGISTRATION:
        return 'BusinessRegistration';
      case EvidenceFileKind.IDENTITY_CARD:
        return 'IdentityCard';
      case EvidenceFileKind.COMPANY_LOGO:
        return 'CompanyLogo';
      case EvidenceFileKind.OTHER:
        return 'Other';
    }
  }
}

class StartupKYCStatusDto {
  final KYCStatus status;
  final String? rejectionReason;
  final DateTime? updatedAt;
  
  // Fields from submissionSummary/draftData
  final String? legalFullName;
  final String? enterpriseCode;
  final String? projectName;
  final String? taxOrDescription;
  final String? representativeFullName;
  final String? representativeRole;
  final String? workEmail;
  final String? publicLink;
  final String? startupVerificationType;
  final Map<EvidenceFileKind, String>? evidenceFiles;

  StartupKYCStatusDto({
    required this.status,
    this.rejectionReason,
    this.updatedAt,
    this.legalFullName,
    this.enterpriseCode,
    this.projectName,
    this.taxOrDescription,
    this.representativeFullName,
    this.representativeRole,
    this.workEmail,
    this.publicLink,
    this.startupVerificationType,
    this.evidenceFiles,
  });

  factory StartupKYCStatusDto.fromJson(Map<String, dynamic> json) {
    // Backend Spec: 'submissionSummary' or 'draftData' (often a JSON string)
    final summary = json['submissionSummary'] as Map<String, dynamic>?;
    Map<String, dynamic>? draftMap;
    
    // Try to parse draftData if it's a string
    final draftStr = json['draftData'];
    if (draftStr is String && draftStr.startsWith('{')) {
      try {
        draftMap = jsonDecode(draftStr) as Map<String, dynamic>?;
      } catch (e) {
        debugPrint('Lỗi giải mã draftData: $e');
      }
    } else if (draftStr is Map<String, dynamic>) {
      draftMap = draftStr;
    }

    // Helper to get value from multiple possible sources
    dynamic getValue(String key) {
      String pascalKey = key[0].toUpperCase() + key.substring(1);
      return draftMap?[key] ?? draftMap?[pascalKey] ?? 
             summary?[key] ?? summary?[pascalKey] ?? 
             json[key] ?? json[pascalKey];
    }

    // Trích xuất file info
    Map<EvidenceFileKind, String>? extractFiles() {
      final Map<EvidenceFileKind, String> results = {};
      bool found = false;

      // Cách 1: Tìm trong map evidenceFiles hoặc evidenceFileNames (nếu backend trả về dạng map)
      final fileData = getValue('evidenceFiles') ?? getValue('evidenceFileNames');
      if (fileData is Map) {
        for (var entry in fileData.entries) {
          try {
            final key = entry.key.toString();
            final kind = EvidenceFileKind.values.firstWhere((e) => e.key == key || e.name == key);
            results[kind] = entry.value.toString();
            found = true;
          } catch (_) {}
        }
      }

      // Cách 2: Tìm các trường đơn lẻ (ví dụ: BusinessRegistration, Other) 
      // Phòng trường hợp backend trả về flat list hoặc fields riêng lẻ
      for (var kind in EvidenceFileKind.values) {
        if (!results.containsKey(kind)) {
          final val = getValue(kind.key) ?? getValue(kind.name);
          if (val != null && val is String && val.isNotEmpty) {
            results[kind] = val;
            found = true;
          }
        }
      }
      return found ? results : null;
    }

    return StartupKYCStatusDto(
      status: KYCStatus.fromString(json['workflowStatus'] ?? json['status']),
      rejectionReason: json['remarks'] ?? json['rejectionReason'],
      updatedAt: (json['updatedAt'] ?? json['lastUpdated']) != null 
          ? DateTime.parse(json['updatedAt'] ?? json['lastUpdated']) 
          : null,
      legalFullName: getValue('legalFullName') as String?,
      enterpriseCode: getValue('enterpriseCode') as String?,
      projectName: getValue('projectName') as String?,
      taxOrDescription: getValue('taxOrDescription') as String?,
      representativeFullName: getValue('representativeFullName') as String?,
      representativeRole: getValue('representativeRole') as String?,
      workEmail: getValue('workEmail') as String?,
      publicLink: getValue('publicLink') as String?,
      startupVerificationType: getValue('startupVerificationType') as String?,
      evidenceFiles: extractFiles(),
    );
  }
}

/// Model đóng gói thông tin file để upload hoặc hiển thị thông tin đã tải lên
class KYCEvidenceFile {
  final File? file;        // Local file (for new upload)
  final String? remoteName; // Filename from server (for viewing)
  final EvidenceFileKind kind;

  KYCEvidenceFile({
    this.file,
    this.remoteName,
    required this.kind,
  });
}
