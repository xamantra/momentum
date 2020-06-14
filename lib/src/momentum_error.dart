/// The type that momentum throws when an error
/// occurs.
class MomentumError implements Exception {
  /// Description of the error.
  final String cause;

  /// The type that momentum throws when an error
  /// occurs.
  MomentumError(this.cause);
}
