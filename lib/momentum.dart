/// MVC pattern for flutter. Works as state management, dependency injection and service locator.
library momentum;

export 'src/momentum_base.dart' show Momentum, MomentumModel, MomentumController, BootstrapStrategy, MomentumBuilder, MomentumState, MomentumService, InjectService, MomentumTester, RouterMixin;
export 'src/momentum_error.dart' show MomentumError;
export 'src/momentum_router.dart' show MomentumRouter, RouterPage, RouterParam;
export 'src/momentum_types.dart' show MomentumSnapshot, MomentumBuilderFunction, ResetAll, BuildSkipper, PersistSaver, PersistGet;
