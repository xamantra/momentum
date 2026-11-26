import 'package:material_ui/material_ui.dart';

import 'momentum_base.dart';

/// A function passed to [MomentumBuilder.builder] for retrieving a model snapshot of type `T`.
typedef MomentumSnapshot = T Function<T>([Type]);

/// The builder function signature used by [MomentumBuilder].
typedef MomentumBuilderFunction = Widget Function(
  BuildContext,
  MomentumSnapshot,
);

/// Callback signature for [Momentum]'s `onResetAll` parameter.
typedef ResetAll = void Function(
  BuildContext,
  void Function(BuildContext) resetAll,
);

/// Callback signature for [MomentumBuilder.dontRebuildIf].
typedef BuildSkipper = bool Function(
  T Function<T extends MomentumController>(),
  bool isTimeTravel,
);

/// Callback signature for [Momentum]'s `persistSave` parameter.
typedef PersistSaver = Future<bool> Function(
  BuildContext? context,
  String key,
  String? value,
);

/// Callback signature for [Momentum]'s `persistGet` parameter.
typedef PersistGet = Future<String?> Function(
  BuildContext? context,
  String key,
);
