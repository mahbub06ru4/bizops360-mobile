import '../../core/network/api_client.dart';
import '../../core/network/api_envelope.dart';

/// Thin wrapper over the `expenses` endpoints. `expense.view` is required to
/// list — staff without it get a 403 which surfaces as a "no access" state.
class FinanceRemoteDataSource {
  FinanceRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> expenses() async {
    final res = await _client.get<Map<String, dynamic>>(
      '/expenses',
      query: {'per_page': 100},
    );
    return envelopeList(res.data);
  }

  Future<Map<String, dynamic>> createExpense(Map<String, dynamic> body) async {
    final res = await _client.post<Map<String, dynamic>>(
      '/expenses',
      body: body,
    );
    return envelopeObject(res.data);
  }
}
