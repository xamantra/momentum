/// MVC pattern for flutter. Works as state management, dependency injection and service locator.
library momentum;

export 'src/momentum_base.dart'
    show
        Momentum,
        MomentumModel,
        MomentumController,
        BootstrapStrategy,
        MomentumBuilder,
        MomentumState,
        MomentumService,
        InjectService,
        MomentumTester,
        RouterMixin;
export 'src/momentum_router.dart' show MomentumRouter, RouterPage, RouterParam;
// ignore: deprecated_member_use_from_same_package
// export 'src/momentum_router.old.dart' show Router;
