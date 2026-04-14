import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import '../models/startup_models.dart';

class StartupService {
  final Dio _dio = DioClient.instance;

  /// 1. Lấy thông tin hồ sơ của tôi (Startup hiện tại)
  Future<ApiResponse<StartupProfileDto?>> getMyProfile() async {
    try {
      final response = await _dio.get('/api/startups/me');
      
      // Nếu Backend trả về null hoặc báo "not created", ApiResponse sẽ xử lý
      return ApiResponse<StartupProfileDto?>.fromJson(
        response.data,
        (data) => data != null ? StartupProfileDto.fromJson(data as Map<String, dynamic>) : null,
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 2. Tạo hồ sơ Startup lần đầu
  Future<ApiResponse<StartupProfileDto>> createProfile(CreateStartupProfileRequest request) async {
    try {
      final formData = await _convertToFormData(request);
      final response = await _dio.post('/api/startups', data: formData);
      
      return ApiResponse<StartupProfileDto>.fromJson(
        response.data,
        (data) => StartupProfileDto.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 3. Cập nhật hồ sơ Startup
  Future<ApiResponse<StartupProfileDto>> updateProfile(CreateStartupProfileRequest request) async {
    try {
      final formData = await _convertToFormData(request);
      final response = await _dio.put('/api/startups/me', data: formData);
      
      return ApiResponse<StartupProfileDto>.fromJson(
        response.data,
        (data) => StartupProfileDto.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<List<IndustryDto>>> getIndustries() async {
    try {
      final response = await _dio.get('/api/master/industries');
      return ApiResponse<List<IndustryDto>>.fromJson(
        response.data,
        (data) => (data as List).map((i) => IndustryDto.fromJson(i)).toList(),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 5. Bật/Tắt hiển thị hồ sơ
  Future<ApiResponse<void>> toggleVisibility(bool isVisible) async {
    try {
      final response = await _dio.put('/api/startups/me/visibility', data: {'isVisible': isVisible});
      return ApiResponse<void>.fromJson(response.data, null);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 6. Quản lý thành viên (Team Members)
  Future<ApiResponse<List<TeamMemberDto>>> getTeamMembers() async {
    try {
      final response = await _dio.get('/api/startups/me/team-members');
      return ApiResponse<List<TeamMemberDto>>.fromJson(
        response.data,
        (data) => (data as List).map((m) => TeamMemberDto.fromJson(m)).toList(),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<TeamMemberDto>> addTeamMember({
    required String fullName,
    required String role,
    String? bio,
    File? photo,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'FullName': fullName,
        'Role': role,
        'Bio': bio,
      };

      if (photo != null) {
        data['Image'] = await MultipartFile.fromFile(
          photo.path,
          filename: basename(photo.path)
        );
      }

      final formData = FormData.fromMap(data);
      final response = await _dio.post('/api/startups/me/team-members', data: formData);
      
      return ApiResponse<TeamMemberDto>.fromJson(
        response.data,
        (data) => TeamMemberDto.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<TeamMemberDto>> updateTeamMember(int id, {
    String? fullName,
    String? role,
    String? bio,
    File? photo,
  }) async {
    try {
      final Map<String, dynamic> data = {
        if (fullName != null) 'FullName': fullName,
        if (role != null) 'Role': role,
        if (bio != null) 'Bio': bio,
      };

      if (photo != null) {
        data['Image'] = await MultipartFile.fromFile(
          photo.path,
          filename: basename(photo.path)
        );
      }

      final formData = FormData.fromMap(data);
      final response = await _dio.put('/api/startups/me/team-members/$id', data: formData);
      
      return ApiResponse<TeamMemberDto>.fromJson(
        response.data,
        (data) => TeamMemberDto.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ApiResponse<void>> deleteTeamMember(int id) async {
    try {
      final response = await _dio.delete('/api/startups/me/team-members/$id');
      return ApiResponse<void>.fromJson(response.data, null);
    } catch (e) {
      return _handleError(e);
    }
  }

  // --- Helpers ---

  Future<FormData> _convertToFormData(CreateStartupProfileRequest req) async {
    final Map<String, dynamic> map = {
      'CompanyName': req.companyName,
      'OneLiner': req.oneLiner,
      'Stage': req.stage,
      'FullNameOfApplicant': req.fullNameOfApplicant,
      'RoleOfApplicant': req.roleOfApplicant,
      'ContactEmail': req.contactEmail,
      
      // Optional Fields - Chụp giá trị hoặc gửi mặc định 0 cho số
      'IndustryID': req.industryId,
      'SubIndustry': req.subIndustry,
      'Description': req.description,
      'FoundedDate': req.foundedDate?.toIso8601String(),
      'Website': req.website,
      'Location': req.location,
      'Country': req.country,
      'TeamSize': req.teamSize,
      'LinkedInURL': req.linkedInUrl,
      'ContactPhone': req.contactPhone,
      'MarketScope': req.marketScope,
      'ProductStatus': req.productStatus,
      'ProblemStatement': req.problemStatement,
      'SolutionSummary': req.solutionSummary,
      'MetricSummary': req.metricSummary,
      'FundingAmountSought': req.fundingAmountSought ?? 0.0,
      'CurrentFundingRaised': req.currentFundingRaised ?? 0.0,
      'Valuation': req.valuation ?? 0.0,
      'BusinessCode': req.businessCode,
      'PitchDeckUrl': req.pitchDeckUrl,
    };

    // Xử lý mảng CurrentNeeds (gửi nhiều phần tử cùng Key)
    if (req.currentNeeds != null && req.currentNeeds!.isNotEmpty) {
      // Dio hỗ trợ gửi mảng trong FormData bằng cách thêm nhiều item cùng key
      // Hoặc sử dụng định dạng key[] tùy theo backend, ở đây Swagger chỉ để CurrentNeeds
      map['CurrentNeeds'] = req.currentNeeds; 
    }

    // Files
    if (req.logoFile != null) {
      map['LogoUrl'] = await MultipartFile.fromFile(
        req.logoFile!.path,
        filename: basename(req.logoFile!.path)
      );
    }
    
    if (req.fileCertificateBusiness != null) {
      map['FileCertificateBusiness'] = await MultipartFile.fromFile(
        req.fileCertificateBusiness!.path,
        filename: basename(req.fileCertificateBusiness!.path)
      );
    }

    return FormData.fromMap(map);
  }

  ApiResponse<T> _handleError<T>(Object e) {
    if (e is DioException) {
      final int? statusCode = e.response?.statusCode;
      
      if (statusCode == 401) {
        return ApiResponse<T>(
          success: false, 
          statusCode: 401,
          error: 'Phiên đăng nhập hết hạn. Vui lòng thử lại.'
        );
      }
      
      if (e.response != null && e.response!.data is Map) {
        final data = e.response!.data;
        
        if (data['errors'] != null && data['errors'] is Map) {
          final Map<String, dynamic> errors = data['errors'];
          final List<String> errorMessages = [];
          
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.add("$key: ${value.join(', ')}");
            } else {
              errorMessages.add("$key: $value");
            }
          });
          
          return ApiResponse<T>(
            success: false, 
            statusCode: statusCode,
            error: 'Lỗi dữ liệu: ${errorMessages.join('\n')}'
          );
        }

        final error = data['message'] ?? data['error'];
        return ApiResponse<T>(
          success: false, 
          statusCode: statusCode,
          error: error?.toString() ?? 'Lỗi từ máy chủ (API)'
        );
      }
      return ApiResponse<T>(
        success: false, 
        statusCode: statusCode,
        error: 'Lỗi kết nối mạng. Vui lòng kiểm tra lại internet.'
      );
    }
    return ApiResponse<T>(success: false, error: 'Đã xảy ra lỗi không xác định.');
  }
}
