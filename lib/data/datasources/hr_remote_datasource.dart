import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the HR endpoints (attendance + leave). These require the
/// caller's account to be linked to an employee record; otherwise the API
/// returns a 422 which surfaces as an error state.
class HrRemoteDataSource {
  HrRemoteDataSource(this._client);

  final ApiClient _client;

  // Attendance --------------------------------------------------------------

  Future<List<Map<String, dynamic>>> attendance() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/attendance',
      query: {'per_page': 60},
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> checkIn() async {
    final res = await _client.post<Map<String, dynamic>>(
      '/attendance/check-in',
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> checkOut() async {
    final res = await _client.post<Map<String, dynamic>>(
      '/attendance/check-out',
    );
    return envelopeObject(res.data);
  }

  // Leave -----------------------------------------------------------------

  Future<List<Map<String, dynamic>>> leaveBalances() async {
    final res = await _client.get<Map<String, dynamic>>('/leave-balances');
    return envelopeList(res.data);
  }

  Future<List<Map<String, dynamic>>> leaveRequests({String? status}) async {
    final res = await _client.get<Map<String, dynamic>>(
      '/leave-requests',
      query: {'per_page': 60, 'status': ?status},
    );
    return envelopeList(res.data);
  }

  Future<List<Map<String, dynamic>>> leaveTypes() async {
    final res = await _client.get<Map<String, dynamic>>('/leave-types');
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> submitLeave(Map<String, dynamic> body) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/leave-requests',
      body: body,
    );
    return envelopeObject(res.data);
  }

  Future<Map<String, dynamic>> decideLeave(
    String id, {
    required bool approve,
    String? note,
  }) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/leave-requests/$id/${approve ? 'approve' : 'reject'}',
      body: {if (note != null && note.isNotEmpty) 'note': note},
    );
    return envelopeObject(res.data);
  }
}
