import 'package:dio/dio.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import '../models/payment_models.dart';

class MembershipService {
  final Dio _dio = DioClient.instance;

  Future<ApiResponse<PaymentInfoDto>> createPaymentLink(SubscriptionPaymentRequest request) async {
    try {
      final response = await _dio.post(
        '/api/Payment/subscription/create-payment-link',
        data: request.toJson(),
      );
      return ApiResponse<PaymentInfoDto>.fromJson(
        response.data,
        (json) => PaymentInfoDto.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse.fromDioError<PaymentInfoDto>(e);
    }
  }
}
