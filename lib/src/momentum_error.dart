/// The type that momentum throws when an error
/// occurs.
class MomentumError implements Exception {
  /// Description of the error.
  final String cause;

  /// The type that momentum throws when an error
  /// occurs.
  const MomentumError(this.cause);

  @override
  String toString() => 'MomentumError: $cause';
}
