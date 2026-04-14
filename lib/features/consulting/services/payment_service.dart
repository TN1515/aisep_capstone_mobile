import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/mentorship_models.dart';

class PaymentService {
  final Dio _dio = DioClient.instance;

  Future<PaymentInfoDto> createMentorshipPayment({
    required int amount,
    required int mentorshipId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/Payment/create-payment-link',
        data: {
          'amount': amount,
          'mentorshipId': mentorshipId,
        },
      );
      return PaymentInfoDto.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<PaymentInfoDto> upgradeSubscription({
    required int targetPlan,
    required int amount,
  }) async {
    try {
      final response = await _dio.post(
        '/api/Payment/subscription/create-payment-link',
        data: {
          'targetPlan': targetPlan,
          'amount': amount,
        },
      );
      return PaymentInfoDto.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }
}
