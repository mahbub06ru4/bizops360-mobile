import '../../core/error/result.dart';
import '../entities/traveller.dart';

abstract interface class TravellerRepository {
  Future<Result<List<Traveller>>> travellers();

  Future<Result<Traveller>> byId(String id);

  Future<Result<List<TravelHistoryEntry>>> history(String id);
}
