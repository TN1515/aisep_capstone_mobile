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
    String? getValue(String key) {
      String pascalKey = key[0].toUpperCase() + key.substring(1);
      return draftMap?[key] ?? draftMap?[pascalKey] ?? 
             summary?[key] ?? summary?[pascalKey] ?? 
             json[key] ?? json[pascalKey];
    }

    return StartupKYCStatusDto(
      status: KYCStatus.fromString(json['workflowStatus'] ?? json['status']),
      rejectionReason: json['remarks'] ?? json['rejectionReason'],
      updatedAt: (json['updatedAt'] ?? json['lastUpdated']) != null 
          ? DateTime.parse(json['updatedAt'] ?? json['lastUpdated']) 
          : null,
      legalFullName: getValue('legalFullName'),
      enterpriseCode: getValue('enterpriseCode'),
      projectName: getValue('projectName'),
      taxOrDescription: getValue('taxOrDescription'),
      representativeFullName: getValue('representativeFullName'),
      representativeRole: getValue('representativeRole'),
      workEmail: getValue('workEmail'),
      publicLink: getValue('publicLink'),
      startupVerificationType: getValue('startupVerificationType'),
    );
  }
}

/// Model đóng gói thông tin file để upload
class KYCEvidenceFile {
  final File file;
  final EvidenceFileKind kind;

  KYCEvidenceFile({
    required this.file,
    required this.kind,
  });
}
