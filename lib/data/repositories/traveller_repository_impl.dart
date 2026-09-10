import '../../core/error/result.dart';
import '../../domain/entities/traveller.dart';
import '../../domain/repositories/traveller_repository.dart';
import '../datasources/traveller_remote_datasource.dart';
import '../models/travel_mappers.dart';
import 'remote_guard.dart';

/// HTTP-backed [TravellerRepository] — `GET /travellers`, `GET /travellers/{id}`.
class TravellerRepositoryImpl implements TravellerRepository {
  TravellerRepositoryImpl(this._remote);

  final TravellerRemoteDataSource _remote;

  @override
  Future<Result<List<Traveller>>> travellers() {
    return guardRequest(
      () async =>
          (await _remote.list()).map(travellerFromJson).toList(growable: false),
    );
  }

  @override
  Future<Result<Traveller>> byId(String id) {
    return guardRequest(() async => travellerFromJson(await _remote.byId(id)));
  }

  @override
  Future<Result<List<TravelHistoryEntry>>> history(String id) {
    // No dedicated traveller-history endpoint yet; the detail screen tolerates
    // an empty timeline. Wire to the real endpoint when it lands.
    return Future.value(const Result.ok(<TravelHistoryEntry>[]));
  }
}
