import 'flavor.dart';

/// Global access to the active [FlavorConfig]. Set exactly once, from the
/// flavor entrypoint, before `runApp`.
class Env {
  Env._();

  static const String apiPrefix = '/api/v1';

  static late FlavorConfig _config;
  static bool _initialised = false;

  static void init(FlavorConfig config) {
    _config = config;
    _initialised = true;
  }

  static FlavorConfig get config {
    assert(
      _initialised,
      'Env.init() must be called from the flavor entrypoint.',
    );
    return _config;
  }

  static Flavor get flavor => config.flavor;
  static bool get isProd => config.isProd;

  /// Fully-qualified API root, e.g. `https://api.bizops360.app/api/v1`.
  static String get apiRoot => '${config.apiBaseUrl}$apiPrefix';
}
