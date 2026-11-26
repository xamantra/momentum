import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:material_ui/material_ui.dart';

import 'momentum_error.dart';
import 'momentum_event.dart';
import 'momentum_router.dart';
import 'momentum_types.dart';

Type _getType<T>() => T;

/// Set the bootstrap behavior for controllers if lazy mode is `true`.
enum BootstrapStrategy {
  /// *(default)*. Bootstrap will be called on first
  /// `MomentumBuilder` usage of a controller if lazy mode is `true`.
  lazyFirstBuild,

  /// Bootstrap will be called on first `Momentum.controller<T>(context)`
  /// call if `lazy` mode is `true`.
  ///
  /// ```dart
  /// var someController = Momentum.controller<SomeController>(context); // will bootstrap.
  ///
  /// // in other widget ...
  /// var someController = Momentum.controller<SomeController>(context); // will NOT bootstrap.
  /// ```
  lazyFirstCall,
}

MomentumError _invalidService = const MomentumError(
  'You are not allowed to grab '
  '"InjectService" directly. You might have done one of these:\n'
  '1. Momentum.service<InjectService>(...)\n'
  '2. service<InjectService>(...)',
);

/// Used internally.
/// Simplify trycatch blocks.
T? trycatch<T>(T Function() body, [T? defaultValue]) {
  try {
    var result = body();
    return result ?? defaultValue;
  } catch (e) {
    return defaultValue;
  }
}

/// Used internally.
/// Simplify trycatch blocks.
/// Async version.
Future<T?> tryasync<T>(Future<T?> Function() body, [T? defaultValue]) async {
  try {
    var result = await body();
    return result ?? defaultValue;
  } catch (e) {
    return defaultValue;
  }
}

class _MomentumListener<M> {
  final MomentumState state;

  final void Function(M, bool) invoke;

  _MomentumListener({required this.state, required this.invoke});
}

/// A mixin for [MomentumController] that adds the capability to
/// handle route changes from momentum's built-in routing system.
mixin RouterMixin on _ControllerBase {
  /// Get the current route parameters specified using
  /// the `params` parameter in `MomentumRouter.goto(...)` method.
  ///
  /// ### Example:
  /// ```dart
  /// // setting the route params.
  /// MomentumRouter.goto(context, DashboardPage, params: DashboardParams(...));
  ///
  /// // accessing the route params inside widgets.
  /// var params = MomentumRouter.getParam<DashboardParams>(context);
  ///
  /// // accessing the route params inside controllers.
  /// var params = getParam<DashboardParams>();
  /// ```
  T? getParam<T extends RouterParam>() {
    if (_mRootContext == null && _tester != null) {
      var router = _tester!._getRouterIfPresent();
      if (router != null) {
        var param = router.getCurrentParam<T>();
        if (param != null && param.runtimeType == _getType<T>()) {
          return param;
        }
        print('getParam<$T>() ---> Invalid type: The active/current route param is of type "${param.runtimeType}" while the parameter you want to access is of type "$T". Momentum will return a null instead.');
      }
      return null;
    }
    var result = MomentumRouter.getParam<T>(_mRootContext!);
    return result;
  }

  /// A callback whenever [momentum_router.MomentumRouter.goto]
  /// or [momentum_router.MomentumRouter.pop] is called.
  /// The [RouterParam] is also provided.
  void onRouteChanged(RouterParam? param) {}
}

/// The class which holds the state of your app.
/// This is tied with [MomentumController].
@immutable
abstract class MomentumModel<Controller extends MomentumController> {
  /// The instance of the controller this model is attached to.
  final Controller controller;

  /// The class which holds the state of your app.
  /// This is tied with [MomentumController].
  const MomentumModel(this.controller);

  /// A getter that exposes the controller
  /// name that this model is attached to.
  /// Just for debugging purposes.
  String get controllerName => '$Controller';

  /// The method for updating this model.
  /// Like a `setState(...)` but immutable.
  void update();

  /// A method which must be explicitly called
  /// inside your `update()` implementation.
  @protected
  void updateMomentum() {
    controller._setMomentum(this);
  }

  /// This is different from the usual factory `fromJson` method.
  /// It's an instance member because you wouldn't be able to access
  /// the `controller` property otherwise.
  MomentumModel? fromJson(Map<String, dynamic>? json) => null;

  /// Method to generate a map from this model.
  Map<String, dynamic>? toJson() => null;
}

mixin _ControllerBase {
  BuildContext? _mRootContext;
  MomentumTester? _tester;
}

/// The class which holds the logic for your app.
/// This is tied with [MomentumModel].
abstract class MomentumController<M extends MomentumModel<dynamic>> with _ControllerBase {
  /// Dependency injection method for getting other controllers.
  /// Useful for accessing other controllers' function
  /// and model properties without dragging the widget context around.
  T controller<T extends MomentumController>() {
    var type = _getType<T>();
    if (runtimeType == type) {
      throw MomentumError(_formatMomentumLog('[$this]: called '
          '"controller<$T>()" on itself, you\'re not '
          'allowed to do that.'));
    }
    T? result;
    if (_mRootContext != null) {
      result = Momentum._ofInternal<T>(_mRootContext!);
    } else if (_tester != null) {
      result = _tester!.controller<T>();
    }
    if (result == null) {
      throw MomentumError(_formatMomentumLog('[$this]: called '
          '"controller<$T>()", but no controller of type '
          '[$T] had been found.\nTry checking your "Momentum" '
          'root widget implementation if the controller '
          '"$T" was instantiated there.'));
    }
    return result;
  }

  /// A method for getting a service marked with
  /// [MomentumService] that are injected into
  /// [Momentum] root widget.
  T service<T extends MomentumService>({bool runtimeType = true, dynamic alias}) {
    try {
      if (_mRootContext == null && _tester != null) {
        return _tester!.service<T>(runtimeType: runtimeType, alias: alias);
      }
      var result = Momentum.service<T>(_mRootContext!, runtimeType: runtimeType, alias: alias);
      return result;
    } catch (e) {
      if (_momentumLogging!) {
        print(e);
      }
      throw MomentumError(_formatMomentumLog('[$this]: called '
          '"service<$T>()", but no service of type [$T] '
          'had been found.\nTry checking your "Momentum" '
          'root widget implementation if the service "$T" '
          'was instantiated there.'));
    }
  }

  bool _booted = false;
  bool _bootedAsync = false;
  bool _onReadyCalled = false;

  /// An optional callback for synchronous initialization.
  /// If lazy loading is disabled this will be called right when
  /// the app starts. Use `bootstrapAsync()` if you want asynchronous.
  ///
  /// ### Execution Order:
  /// When the app runs, this is how Momentum execute all callbacks:
  /// - Momentum root - `initializer()` (awaited)
  /// - Initialize all **Services**
  /// - *All Controllers* - `T init()`
  /// - *All non-lazy Controllers* - `bootstrap()`
  /// - *All non-lazy Controllers* - `bootstrapAsync()` (awaited)
  /// - *All Controllers* - `onReady()`
  void bootstrap() {}
  void _bootstrap() {
    if (!_booted) {
      _booted = true;
      bootstrap();
      if (_momentumLogging!) {
        print(_formatMomentumLog('[$this] => bootstrap() '
            'called! { lazy: $_lazy }'));
      }
    }
  }

  /// An optional callback for asynchronous initialization.
  /// If lazy loading is disabled this will be called right when
  /// the app starts and displays a loading widget until the async
  /// operation is finished.
  ///
  /// ### Execution Order:
  /// When the app runs, this is how Momentum execute all callbacks:
  /// - Momentum root - `initializer()` (awaited)
  /// - Initialize all **Services**
  /// - *All Controllers* - `T init()`
  /// - *All non-lazy Controllers* - `bootstrap()`
  /// - *All non-lazy Controllers* - `bootstrapAsync()` (awaited)
  /// - *All Controllers* - `onReady()`
  Future<void> bootstrapAsync() async {}
  Future<void> _bootstrapAsync() async {
    if (!_bootedAsync) {
      _bootedAsync = true;
      if (_momentumLogging!) {
        print(_formatMomentumLog('[$this] => executing '
            'bootstrapAsync() { lazy: $_lazy } ...'));
      }
      var started = DateTime.now().millisecondsSinceEpoch;
      await bootstrapAsync();
      var finished = DateTime.now().millisecondsSinceEpoch;
      var diff = finished - started;
      if (_momentumLogging!) {
        print(_formatMomentumLog('[$this] => bootstrapAsync() '
            'completed! { lazy: $_lazy, took: ${diff}ms }'));
      }
    }
  }

  /// Added on `v2.0.0`
  ///
  /// A callback that gets executed when **all** non-lazy controllers' bootstrap
  /// method gets called.
  ///
  /// ### Execution Order:
  /// When the app runs, this is how Momentum execute all callbacks:
  /// - Momentum root - `initializer()` (awaited)
  /// - Initialize all **Services**
  /// - *All Controllers* - `T init()`
  /// - *All non-lazy Controllers* - `bootstrap()`
  /// - *All non-lazy Controllers* - `bootstrapAsync()` (awaited)
  /// - *All Controllers* - `onReady()`
  void onReady() {}
  void _onReady() {
    if (!_onReadyCalled) {
      _onReadyCalled = true;
      onReady();
      if (_momentumLogging!) {
        print(_formatMomentumLog('[$this] => onReady() '
            'called!}'));
      }
    }
  }

  List<_MomentumListener> _momentumListeners = [];
  List<_MomentumListener<M>> _externalMomentumListeners = [];
  final List<MomentumEvent> _eventHandlers = List.from([], growable: true);

  M? _currentActiveModel;

  M? _prevModel;
  M? _nextModel;

  /// Previous model state.
  /// Will only have value if time travel is enabled.
  M? get prevModel => _prevModel;

  /// Next model state.
  /// Will only have a value if time travel
  /// is enabled and `backward()` was called.
  M? get nextModel => _nextModel;

  /// The current model state.
  /// The initial value is specified in your
  /// `init()` implementation.
  M get model => _currentActiveModel!;

  List<M>? _momentumModelHistory;

  int _historyIndex = 0;

  bool _momentumControllerInitialized = false;

  Future<void> _initializeMomentumController() async {
    if (!_momentumControllerInitialized) {
      _momentumControllerInitialized = true;
      _momentumModelHistory ??= [];
      _currentActiveModel = init();
      var persistedModel = await _getPersistedModel();
      if (persistedModel != null) {
        _currentActiveModel = persistedModel;
      }
      _momentumModelHistory!.add(_currentActiveModel!);
      _historyIndex = 0;
      if (_momentumLogging!) {
        print(_formatMomentumLog('[$this] has been '
            'initialized. {maxTimeTravelSteps: $_maxTimeTravelSteps}'));
      }
    }
  }

  /// Initialize the model of this controller.
  /// Required to be implemented.
  @protected
  M init();

  void _setMomentum(
    M? model, {
    bool backward = false,
    bool forward = false,
  }) {
    var isTimeTravel = backward || forward;
    if (isTimeTravel) {
      _currentActiveModel = _momentumModelHistory![_historyIndex];
    } else {
      // equatable check, do not update model if values are the same.
      if (_currentActiveModel == model) {
        return;
      }

      if (_historyIndex < _momentumModelHistory!.length - 1) {
        _momentumModelHistory!.removeRange(
          _historyIndex + 1,
          _momentumModelHistory!.length,
        );
      }

      if (_momentumModelHistory!.length >= _maxTimeTravelSteps!) {
        _momentumModelHistory!.removeAt(0);
      }

      _currentActiveModel = model;
      _momentumModelHistory!.add(_currentActiveModel!);
      _historyIndex = _momentumModelHistory!.length - 1;

      _nextModel = null;
      _prevModel = _historyIndex > 0 ? _momentumModelHistory![_historyIndex - 1] : null;
    }

    _persistModel(_currentActiveModel);
    _notifyListeners(isTimeTravel);
  }

  void _notifyListeners(bool isTimeTravel) {
    _cleanupListeners();

    for (var listener in _momentumListeners) {
      if (listener.state.mounted && !listener.state.deactivated) {
        listener.invoke(_currentActiveModel, isTimeTravel);
      }
    }

    for (var externalListener in _externalMomentumListeners) {
      var isMounted = externalListener.state.mounted;
      var isDeactivated = externalListener.state.deactivated;
      if (isMounted && !isDeactivated) {
        externalListener.invoke(_currentActiveModel!, isTimeTravel);
      }
    }

    if (_momentumLogging!) {
      var inActiveListeners = _momentumListeners.where(
        (l) => l.state.deactivated,
      );
      var _totalCount = _momentumListeners.length;
      var _inActiveCount = inActiveListeners.length;
      var activeListeners = _totalCount - _inActiveCount;
      print(_formatMomentumLog('[$this] the model "$M" has '
          'been updated, listeners => ACTIVE: $activeListeners '
          '(notified), INACTIVE: ${inActiveListeners.length} (ignored)'));
    }
  }

  /// You can use this method to
  /// enable/disable persistence
  /// for this controller.
  /// Returns `null` by default.
  /// Because this is asynchronous,
  /// you can do any asynchronous code.
  Future<bool?> skipPersist() async => null;

  Future<bool> _shouldPersistState() async {
    var skip = await skipPersist();
    if (skip == null) {
      return !_disablePersistentState!;
    }
    return !skip;
  }

  bool _persistenceConfigured() {
    var hasSaver = false;
    var hasGet = false;
    if (_mRootContext != null) {
      var momentum = Momentum._getMomentumInstance(_mRootContext!);
      hasSaver = momentum._persistSave != null;
      hasGet = momentum._persistGet != null;
    } else if (_tester != null) {
      hasSaver = _tester!._momentum._persistSave != null;
      hasGet = _tester!._momentum._persistGet != null;
    }
    var configured = hasSaver && hasGet;
    return configured;
  }

  String? _persistenceKey;

  /// The key used internally by momentum
  /// for persistence with this controller.
  /// You can also use this to clear the data
  /// or even override the persisted json value
  /// (**use with caution**).
  String get persistenceKey {
    if (_persistenceKey == null) {
      _persistenceKey = '$Momentum[$this<$M>]'.replaceAll('\'', '');
    }
    return _persistenceKey!;
  }

  Future<void> _persistModel(M? model) async {
    if (model == null) return;
    var skip = !(await _shouldPersistState());
    if (skip || !_persistenceConfigured()) return;

    Momentum? momentum;
    PersistSaver? _persistSave;
    if (_mRootContext != null) {
      momentum = Momentum._getMomentumInstance(_mRootContext!);
      _persistSave = momentum._persistSave;
    } else if (_tester != null) {
      _persistSave = _tester!._momentum._persistSave;
    }
    if (_persistSave != null) {
      Map<String, dynamic>? json;
      String? modelRawJson;
      try {
        json = model.toJson();
        if (json == null) return;
        modelRawJson = jsonEncode(json);
      } catch (e, stackTrace) {
        print(e);
        print(stackTrace);
        return;
      }
      await _persistSave(
        _mRootContext,
        persistenceKey,
        modelRawJson,
      );
    }
  }

  Future<M?> _getPersistedModel() async {
    var skip = !(await _shouldPersistState());
    if (skip || !_persistenceConfigured()) return null;
    M? result;
    Momentum? momentum;
    PersistGet? _persistGet;
    if (_mRootContext != null) {
      momentum = Momentum._getMomentumInstance(_mRootContext!);
      _persistGet = momentum._persistGet;
    } else if (_tester != null) {
      _persistGet = _tester!._momentum._persistGet;
    }
    if (_persistGet != null) {
      String? modelRawJson = await tryasync(
        (() => _persistGet!(_mRootContext, persistenceKey)),
      );
      if (modelRawJson == null || modelRawJson.isEmpty) {
        return null;
      }
      var decoded = trycatch(() => jsonDecode(modelRawJson));
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      try {
        result = model.fromJson(decoded) as M?;
      } catch (e, stackTrace) {
        print(e);
        print(stackTrace);
      }
    }
    return result;
  }

  /// Time travel method.
  /// An `undo` function for states.
  /// This method will set the model state one step behind.
  void backward() {
    if (_momentumModelHistory != null && _historyIndex > 0) {
      _historyIndex--;
      _prevModel = _historyIndex > 0 ? _momentumModelHistory![_historyIndex - 1] : null;
      _nextModel = _momentumModelHistory![_historyIndex + 1];
      _setMomentum(null, backward: true);
    }
  }

  /// Time travel method.
  /// A `redo` function for states.
  /// If `backward()` was called before, this method will
  /// set the model state one step ahead.
  void forward() {
    if (_momentumModelHistory != null && _historyIndex < _momentumModelHistory!.length - 1) {
      _historyIndex++;
      _prevModel = _momentumModelHistory![_historyIndex - 1];
      _nextModel = _historyIndex < _momentumModelHistory!.length - 1
          ? _momentumModelHistory![_historyIndex + 1]
          : null;
      _setMomentum(null, forward: true);
    }
  }

  void _addListenerInternal(_MomentumListener _momentumListener) {
    _momentumListeners.add(_momentumListener);
    _momentumListener.state._addDisposeCallback(() {
      _momentumListeners.remove(_momentumListener);
    });
  }

  /// **UPDATE NOTE:** For showing dialogs/snackbars/toast/alerts/etc or navigation
  /// , use the new [MomentumController.listen] instead for better flow.
  ///
  /// Add a listener for this controller.
  /// Requires [MomentumState].
  /// Example uses is manipulating your text fields for undo/redo function.
  /// It is highly recommended to only call this
  /// inside [MomentumState.initMomentumState].
  void addListener({
    required MomentumState state,
    required void Function(M, bool) invoke,
  }) {
    var listener = _MomentumListener<M>(
      state: state,
      invoke: (model, isTimeTravel) {
        invoke(model, isTimeTravel);
      },
    );
    _externalMomentumListeners.add(listener);
    state._addDisposeCallback(() {
      _externalMomentumListeners.remove(listener);
    });
  }

  /// **NEW FEATURE**
  ///
  /// Listen for the event of type `T`.
  /// Requires [MomentumState].
  /// Example uses is for displaying dialogs, snackbars, and navigation.
  /// It is highly recommended to only call this
  /// inside [MomentumState.initMomentumState].
  ///
  /// **NOTE:** For dialogs/snackbars/toast/etc, this is better than
  /// [addListener] because [addListener] only reacts to `model.update(...)`
  /// which forces you to update your state where showing dialogs/snackbars/toast/etc
  /// doesn't actually need it. With [listen], You can send any kinds of data
  /// to the widgets.
  void listen<T>({
    required MomentumState state,
    required void Function(T data) invoke,
  }) {
    var newHandler = MomentumEvent<T>(state);
    var subscription = newHandler.on().listen((data) {
      invoke(data);
    });
    _eventHandlers.add(newHandler);
    state._addDisposeCallback(() {
      subscription.cancel();
      newHandler.destroy();
      _eventHandlers.remove(newHandler);
    });
  }

  /// Send event data to all listeners of data type `T`.
  /// Listeners are created using [MomentumController.listen].
  /// This should be used for notifying the widgets to show
  /// dialogs/snackbars/toast/alerts/etc.
  void sendEvent<T>(T data) {
    _eventHandlers.removeWhere((x) {
      if (x.streamController.isClosed || !x.state.mounted) {
        if (!x.streamController.isClosed) {
          x.destroy();
        }
        return true;
      }
      return false;
    });
    for (var event in List<MomentumEvent>.from(_eventHandlers)) {
      event.triggerIfMatch(data);
    }
  }

  void _cleanupListeners() {
    _momentumListeners.removeWhere((x) => !x.state.mounted);
    _externalMomentumListeners.removeWhere((x) => !x.state.mounted);
  }

  /// Reset the model of this controller.
  /// The implementation of `init()` is used.
  ///
  /// UPDATE: You can now optionally clear the
  /// state history with `clearHistory` parameter.
  /// Please note that it would also reset your
  /// undo/redo state.
  void reset({bool? clearHistory}) {
    var initialModel = init();
    if (clearHistory ?? false) {
      _momentumModelHistory!.clear();
      _currentActiveModel = initialModel;
      _momentumModelHistory!.add(_currentActiveModel!);
      _historyIndex = 0;
      _nextModel = null;
      _prevModel = null;
      _persistModel(_currentActiveModel);
      _notifyListeners(false);
    } else {
      _setMomentum(initialModel);
    }
    if (_momentumLogging!) {
      print(_formatMomentumLog('[$this] has been reset.'));
    }
  }

  /// Added on `v2.0.0`
  ///
  /// Reset the undo/redo state history.
  ///
  /// This does not reset the current state.
  void clearStateHistory() {
    _momentumModelHistory!.clear();
    _momentumModelHistory!.add(_currentActiveModel!);
    _historyIndex = 0;
    _nextModel = null;
    _prevModel = null;
  }

  bool? _momentumLogging;
  bool? _disablePersistentState;

  /// Indicates whether persistence is enabled or disabled for this controller.
  ///
  /// **NOTE:** This is overridden by `skipPersist()`.
  bool? get persistentStateDisabled => _disablePersistentState;

  /// Indicates whether debug logging for this controller is enable or not.
  bool? get loggingEnabled => _momentumLogging;
  int? _maxTimeTravelSteps;

  /// Maximum number of steps this controller can undo and redo states.
  int? get maxTimeTravelSteps => _maxTimeTravelSteps;
  bool? _lazy;

  /// A getter that indicates if this controller is lazy loaded or not.
  bool? get isLazy => _lazy;
  bool _configMethodCalled = false;

  /// The bootstrap behavior for controllers if lazy is `true`.
  ///
  /// #### lazyFirstBuild
  /// *(default)*. Bootstrap will be called on first
  /// `MomentumBuilder` usage of a controller.
  ///
  /// #### lazyFirstCall
  /// Bootstrap will be called on first
  /// `Momentum.controller<T>(context)` call.
  ///
  /// ```dart
  /// var someController = Momentum.controller<SomeController>(context); // will bootstrap.
  ///
  /// // in other widget ...
  /// var someController = Momentum.controller<SomeController>(context); // will NOT bootstrap.
  /// ```
  BootstrapStrategy? get strategy => _strategy;
  BootstrapStrategy? _strategy;

  /// Configure this controller to set some custom behaviors.
  void config({
    bool? enableLogging,
    int? maxTimeTravelSteps,
    bool? lazy,
    BootstrapStrategy? strategy,
  }) {
    if (!_configMethodCalled) {
      _configMethodCalled = true;
      _momentumLogging = enableLogging;
      _maxTimeTravelSteps = maxTimeTravelSteps?.clamp(1, 250);
      _lazy = lazy;
      _strategy = strategy;
    }
  }

  void _configInternal({
    bool? disabledPersistentState,
    bool? enableLogging,
    int? maxTimeTravelSteps,
    bool? lazy,
    BootstrapStrategy? strategy,
  }) {
    _disablePersistentState = disabledPersistentState ?? false;
    _momentumLogging ??= enableLogging ?? false;
    _maxTimeTravelSteps ??= (maxTimeTravelSteps ?? 1).clamp(1, 250);
    _lazy ??= lazy ?? true;
    _strategy ??= strategy ?? BootstrapStrategy.lazyFirstBuild;
  }

  String _formatMomentumLog(String log) {
    return log.replaceAll('Instance of ', 'Momentum -> ');
  }
}

/// Use for marking any classes as services
/// to inject them into the `services` parameter
/// of [Momentum] root widget and use them
/// down the tree.
abstract class MomentumService {
  BuildContext? _context;
  MomentumTester? _tester;

  /// A method for getting a service marked with
  /// [MomentumService] that are injected into
  /// [Momentum] root widget.
  T service<T extends MomentumService>({bool runtimeType = true, dynamic alias}) {
    if (_context == null && _tester != null) {
      return _tester!.service<T>(runtimeType: runtimeType, alias: alias);
    }
    var momentum = Momentum._getMomentumInstance(_context!);
    return momentum._getService<T>(runtimeType: runtimeType, alias: alias);
  }
}

/// Use this class to inject multiple services of the
/// same type with different configurations using alias.
class InjectService<S extends MomentumService> extends MomentumService {
  final dynamic _alias;
  final S _service;

  /// The service instance attached to this injector.
  S get value => _service;

  /// Use this class to inject multiple services of the
  /// same type with different configurations using alias.
  InjectService(
    dynamic alias,
    S service,
  )   : _alias = alias,
        _service = service;
}

/// A [State] class with additional properties.
/// Also allows you to add listeners for controllers.
abstract class MomentumState<T extends StatefulWidget> extends State<T> {
  final List<void Function()> _disposeCallbacks = [];
  bool _stateDeactivated = false;

  void _addDisposeCallback(void Function() callback) {
    _disposeCallbacks.add(callback);
  }

  /// A property that indicates if the [StatefulWidget] for this [State]
  /// or the parent is active on the navigation stack.
  bool get deactivated => _stateDeactivated;

  @override
  void initState() {
    _stateDeactivated = false;
    super.initState();
  }

  @override
  void activate() {
    super.activate();
    _stateDeactivated = false;
  }

  @override
  void deactivate() {
    _stateDeactivated = true;
    super.deactivate();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _stateDeactivated = false;
  }

  @override
  void dispose() {
    for (var callback in List<void Function()>.from(_disposeCallbacks)) {
      callback();
    }
    _disposeCallbacks.clear();
    super.dispose();
  }

  bool ___momentumInitialized = false;

  @override
  @mustCallSuper
  void didChangeDependencies() {
    if (!___momentumInitialized) {
      ___momentumInitialized = true;
      initMomentumState();
    }
    super.didChangeDependencies();
  }

  /// A callback that is called before `build(...)`.
  /// You can call any functions here that requires [BuildContext].
  /// Only called once within the lifecycle of this [State].
  @protected
  void initMomentumState() {}
}

/// The widget class for displaying your model properties.
class MomentumBuilder extends StatefulWidget {
  /// Optional used for detailed error logs.
  /// Simply specify with `owner: this` for
  /// [StatelessWidget] and `owner: widget`
  /// for [StatefulWidget], to set the
  /// current widget as the owner.
  final Widget? owner;

  /// The list of controllers you want to inject
  /// into this [MomentumBuilder].
  @protected
  final List<Type>? controllers;

  /// An optional callback. If provided, this will be called
  /// right before [MomentumBuilder.builder].
  /// If returns `true`, it will skip rebuild for this [MomentumBuilder].
  final BuildSkipper? dontRebuildIf;

  /// The parameter for building your model snapshots.
  /// Returns a widget and must not be null.
  @protected
  final MomentumBuilderFunction builder;

  /// Create a widget to display your model properties.
  /// Parameter `builder` is required.
  const MomentumBuilder({
    Key? key,
    this.owner,
    this.controllers,
    required this.builder,
    this.dontRebuildIf,
  }) : super(key: key);

  @protected
  @override
  _MomentumBuilderState createState() => _MomentumBuilderState();
}

class _MomentumBuilderState extends MomentumState<MomentumBuilder> {
  List<MomentumController> ctrls = [];
  final List<_MomentumListener> _attachedListeners = [];

  String get _logHeader {
    var noOwner = widget.owner == null;
    var h = '[$Momentum > $MomentumBuilder]:';
    var oh = '[$Momentum > ${widget.owner.runtimeType} > $MomentumBuilder]:';
    return noOwner ? h : oh;
  }

  bool _momentumBuilderInitialized = false;
  MomentumError? _error;

  bool _controllersChanged(List<Type>? oldList, List<Type>? newList) {
    var a = oldList ?? const <Type>[];
    var b = newList ?? const <Type>[];
    if (a.length != b.length) return true;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return true;
    }
    return false;
  }

  void _detachListeners() {
    for (var i = 0; i < ctrls.length && i < _attachedListeners.length; i++) {
      ctrls[i]._momentumListeners.remove(_attachedListeners[i]);
    }
    _attachedListeners.clear();
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    if (!_momentumBuilderInitialized) {
      _momentumBuilderInitialized = true;
      _init();
    }
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(MomentumBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controllersChanged(oldWidget.controllers, widget.controllers)) {
      _detachListeners();
      _error = null;
      _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      throw _error!;
    }
    return widget.builder(context, _modelSnapshotOfType);
  }

  void _init() {
    ctrls = <MomentumController>[];
    _attachedListeners.clear();
    for (var t in (widget.controllers ?? <Type>[])) {
      var c = Momentum._ofType(context, t);
      if (c != null) {
        ctrls.add(c);
      } else {
        _error = MomentumError('$_logHeader The controller of type "$t" doesn\'t exists '
            'or was not initialized from the "controllers" parameter '
            'in the Momentum constructor.');
      }
    }
    if (ctrls.isNotEmpty) {
      for (var i = 0; i < ctrls.length; i++) {
        var bootstrap = ctrls[i].strategy == BootstrapStrategy.lazyFirstBuild;
        if (ctrls[i]._lazy! && bootstrap) {
          ctrls[i]._bootstrap();
          ctrls[i]._bootstrapAsync();
        }
        var listener = _MomentumListener(
          state: this,
          invoke: (data, isTimeTravel) {
            if (mounted) {
              var dontRebuild = false;
              if (widget.dontRebuildIf != null) {
                dontRebuild = widget.dontRebuildIf!(
                  _getController,
                  isTimeTravel,
                );
              }
              if (!dontRebuild) {
                _rebuild();
              }
            }
          },
        );
        _attachedListeners.add(listener);
        ctrls[i]._addListenerInternal(listener);
      }
    }
    return;
  }

  T _modelSnapshotOfType<T>([Type? c]) {
    var type = _getType<T>();
    var controllers = ctrls
        .where(
          (x) => x.model.runtimeType == type,
        )
        .toList();
    if (controllers.isEmpty) {
      throw MomentumError('$_logHeader The controller '
          'for the model of type "$T" is either not injected in this '
          '${widget.runtimeType} or not initialized in the Momentum root '
          'widget or can be both.\nPossible solutions:\n\t1. Check if '
          'you initialized the controller attached to this model on the '
          'Momentum root widget.\n\t2. Check the controller attached '
          'to this model if it is injected into this ${widget.runtimeType}');
    }
    if (controllers.length > 1 && c == null) {
      throw MomentumError('$_logHeader The model of type "$T" is being '
          'used by multiple controllers. Please specify a specific controller '
          'using the syntax "snapshot<ModelType>(ControllerType)".');
    }
    if (controllers.length > 1 && c != null) {
      var controller = controllers.firstWhereOrNull(
        (x) => x.runtimeType == c,
      );
      if (controller == null) {
        throw MomentumError('$_logHeader The controller of type "$c" '
            'for the model of type "$T" is either not injected in this '
            '${widget.runtimeType} or not initialized in the Momentum root '
            'widget.');
      }
      return controller.model as T;
    }
    var model = controllers
        .firstWhere(
          (c) => c.model.runtimeType == type,
        )
        .model;
    return model as T;
  }

  T _getController<T extends MomentumController>() {
    var type = _getType<T>();
    var controller = ctrls.firstWhereOrNull(
      (x) => x.runtimeType == type,
    );
    if (controller == null) {
      throw MomentumError('$_logHeader A controller of '
          'type "$T" is either not injected in this ${widget.runtimeType} '
          'or not initialized in the Momentum root widget or can be both.'
          '\nPossible solutions:\n\t1. Check if you initialized "$T" on the '
          'Momentum root widget.\n\t2. Check "$T" if it is injected '
          'into this ${widget.runtimeType}');
    }
    return controller as T;
  }

  void _rebuild() {
    try {
      setState(_);
    } catch (e) {
      // ignore the setState error because
      // it is allowed to call "model.update(...)"
      // inside initState or when the widget tree is
      // not finish building yet.
    }
  }

  _() {}
}

class _MomentumRoot extends StatefulWidget {
  final Future<void> Function()? initializer;
  final Widget? child;
  final Widget? appLoader;
  final List<MomentumController> controllers;
  final List<MomentumService> services;
  final bool? disabledPersistentState;
  final bool? enableLogging;
  final int? maxTimeTravelSteps;
  final bool? lazy;
  final int? minimumBootstrapTime;
  final BootstrapStrategy? strategy;

  const _MomentumRoot({
    Key? key,
    required this.initializer,
    required this.child,
    required this.appLoader,
    required this.controllers,
    required this.services,
    required this.disabledPersistentState,
    required this.enableLogging,
    required this.maxTimeTravelSteps,
    required this.lazy,
    required this.minimumBootstrapTime,
    required this.strategy,
  }) : super(key: key);
  @override
  _MomentumRootState createState() => _MomentumRootState();
}

class _MomentumRootState extends State<_MomentumRoot> {
  MomentumEvent<RouterSignal>? _momentumEvent;
  StreamSubscription<RouterSignal>? _routerSubscription;
  Future<bool>? _initFuture;
  bool _mErrorFound = false;
  String? _error;

  @override
  void dispose() {
    _routerSubscription?.cancel();
    _routerSubscription = null;
    _momentumEvent?.destroy();
    _momentumEvent = null;
    super.dispose();
  }

  Future<bool> _init() async {
    try {
      if (widget.initializer != null) {
        await widget.initializer!();
      }
      if (!mounted) return false;

      _momentumEvent ??= MomentumEvent<RouterSignal>(this);
      await _initServices(widget.services);
      if (!mounted) return false;
      await _initControllerModel(widget.controllers);
      if (!mounted) return false;
      _bootstrapControllers(widget.controllers);
      await _bootstrapControllersAsync(widget.controllers);
      if (!mounted) return false;
      _onReadyControllers(widget.controllers);
      return true;
    } catch (e, stackTrace) {
      // Print the stacktrace of the caught exception
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      _error = '[Momentum]: Failed to initialize your app. '
          'Check the above stacktrace for details.';
      throw MomentumError(_error);
    }
  }

  Future<void> _initControllerModel(
    List<MomentumController> controllers,
  ) async {
    for (var controller in controllers) {
      controller._mRootContext = context;
      controller._configInternal(
        disabledPersistentState: widget.disabledPersistentState,
        enableLogging: widget.enableLogging,
        maxTimeTravelSteps: widget.maxTimeTravelSteps,
        lazy: widget.lazy,
        strategy: widget.strategy,
      );
      await controller._initializeMomentumController();
      if (!mounted) return;
    }
  }

  Future<void> _initServices(List<MomentumService> services) async {
    var momentum = Momentum._getMomentumInstance(context);
    for (var service in services) {
      service._context = context;
      if (service is InjectService) {
        service._service._context = context;
      }
      if (service is MomentumRouter) {
        _routerSubscription ??= _momentumEvent!.on().listen((event) {
          for (var controller in widget.controllers) {
            if (controller is RouterMixin) {
              (controller as RouterMixin).onRouteChanged(event.param);
            }
          }
        });
        service.setFunctions(
          context,
          momentum._persistSave,
          momentum._persistGet,
          _momentumEvent,
        );

        await service.init();
        if (!mounted) return;
      }
    }
  }

  void _bootstrapControllers(List<MomentumController> controllers) {
    var nonLazyControllers = widget.controllers.where((e) {
      return !e._lazy!;
    });
    for (var nonLazyController in nonLazyControllers) {
      nonLazyController._bootstrap();
    }
  }

  void _onReadyControllers(List<MomentumController> controllers) {
    for (var controller in controllers) {
      controller._onReady();
    }
  }

  Future<void> _bootstrapControllersAsync(
    List<MomentumController> controllers,
  ) async {
    var started = DateTime.now().millisecondsSinceEpoch;
    var nonLazyControllers = widget.controllers.where((e) {
      return !e._lazy!;
    });
    var futures = nonLazyControllers.map<Future>((e) => e._bootstrapAsync());
    await Future.wait(futures);
    var finished = DateTime.now().millisecondsSinceEpoch;
    var diff = finished - started;
    num min = (widget.minimumBootstrapTime ?? 0).clamp(0, 9999999);
    var waitTime = (min - diff).clamp(0, min);
    await Future.delayed(Duration(milliseconds: waitTime as int));
  }

  @override
  Widget build(BuildContext context) {
    var momentum = Momentum._getMomentumInstance(context);
    _error ??= momentum._validateControllers(
      widget.controllers,
    );
    _error ??= momentum._validateInjectService(
      widget.services,
    );
    if (_error != null) {
      if (!_mErrorFound) {
        _mErrorFound = true;
        throw MomentumError(_error);
      }
      return const SizedBox.shrink();
    }
    _initFuture ??= _init();
    return FutureBuilder<bool>(
      future: _initFuture,
      initialData: false,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (!_mErrorFound) {
            _mErrorFound = true;
            throw snapshot.error!;
          }
          return const SizedBox.shrink();
        }
        if (snapshot.hasData && snapshot.data!) {
          return widget.child!;
        }
        return widget.appLoader ??
            MaterialApp(
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: SizedBox(
                    height: 36,
                    width: 36,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            );
      },
    );
  }
}

/// The root widget for configuring [Momentum].
class Momentum extends InheritedWidget {
  const Momentum._internal({
    Key? key,
    required Widget child,
    Future<void> Function()? initializer,
    List<MomentumController>? controllers,
    List<MomentumService>? services,
    bool? disabledPersistentState,
    bool? enableLogging,
    int? maxTimeTravelSteps,
    bool? lazy,
    BootstrapStrategy? strategy,
    int? minimumBootstrapTime,
    ResetAll? onResetAll,
    PersistSaver? persistSave,
    PersistGet? persistGet,
    void Function()? restartCallback,
  })  : _initializer = initializer,
        _controllers = controllers ?? const [],
        _onResetAll = onResetAll,
        _services = services ?? const [],
        _disabledPersistentState = disabledPersistentState ?? false,
        _enableLogging = enableLogging ?? false,
        _maxTimeTravelSteps = maxTimeTravelSteps ?? 1,
        _lazy = lazy ?? true,
        _strategy = strategy ?? BootstrapStrategy.lazyFirstBuild,
        _minimumBootstrapTime = minimumBootstrapTime ?? 0,
        _persistSave = persistSave,
        _persistGet = persistGet,
        _restartCallback = restartCallback,
        super(key: key, child: child);

  /// Configure your app with [Momentum] root widget.
  ///
  /// The parameter `child` is not required for *unit testing*.
  factory Momentum({
    Key? key,
    Future<void> Function()? initializer,
    Widget? child,
    Widget? appLoader,
    required List<MomentumController> controllers,
    List<MomentumService>? services,
    ResetAll? onResetAll,
    bool? disabledPersistentState,
    bool? enableLogging,
    int? maxTimeTravelSteps,
    bool? lazy,
    int? minimumBootstrapTime,
    BootstrapStrategy? strategy,
    PersistSaver? persistSave,
    PersistGet? persistGet,
    void Function()? restartCallback,
  }) {
    return Momentum._internal(
      key: key,
      child: _MomentumRoot(
        initializer: initializer,
        child: child,
        appLoader: appLoader,
        controllers: controllers,
        services: services ?? [],
        disabledPersistentState: disabledPersistentState,
        enableLogging: enableLogging,
        maxTimeTravelSteps: maxTimeTravelSteps,
        lazy: lazy,
        minimumBootstrapTime: minimumBootstrapTime,
        strategy: strategy,
      ),
      initializer: initializer,
      controllers: controllers,
      services: services,
      disabledPersistentState: disabledPersistentState,
      enableLogging: enableLogging,
      maxTimeTravelSteps: maxTimeTravelSteps,
      lazy: lazy,
      strategy: strategy,
      minimumBootstrapTime: minimumBootstrapTime,
      onResetAll: onResetAll,
      persistSave: persistSave,
      persistGet: persistGet,
      restartCallback: restartCallback,
    );
  }

  String? _validateControllers(List<MomentumController> controllers) {
    var passedIn = '';
    for (var controller in controllers) {
      passedIn += '\n   ${controller.runtimeType}(),';
    }
    passedIn = 'controllers: [$passedIn\n]\n';
    for (var controller in controllers) {
      var count = controllers
          .where(
            (x) => x.runtimeType == controller.runtimeType,
          )
          .length; // filter controllers (remove duplicates).
      if (count > 1) {
        return '[$Momentum] -> Duplicate controller of type '
            '"${controller.runtimeType}" is found. You passed '
            'in "$count" instance of "${controller.runtimeType}".'
            '\n\nControllers config:\n\n$passedIn';
      }
    }
    return null;
  }

  String? _validateInjectService(List<MomentumService> services) {
    var injectedServices = services.where(
      (s) {
        return trycatch(() => (s as InjectService)._alias) != null;
      },
    ).cast<InjectService>();
    for (var inject in injectedServices) {
      var count = injectedServices
          .where(
            (x) => x._alias == inject._alias,
          )
          .length;
      if (count > 1) {
        return '[$Momentum] -> Duplicate alias is found. You passed '
            'in $count "${inject._alias}"';
      }
    }
    return null;
  }

  final Future<void> Function()? _initializer;

  final List<MomentumController> _controllers;

  final List<MomentumService> _services;

  final bool _disabledPersistentState;
  final bool _enableLogging;
  final int _maxTimeTravelSteps;
  final bool _lazy;
  final BootstrapStrategy _strategy;
  final int _minimumBootstrapTime;

  final ResetAll? _onResetAll;

  final PersistSaver? _persistSave;
  final PersistGet? _persistGet;

  final void Function()? _restartCallback;

  T? _getController<T extends MomentumController?>([bool isInternal = false]) {
    var type = _getType<T>();
    var controller = _controllers.firstWhereOrNull(
      (c) => c.runtimeType == type,
    );
    if (controller == null && !isInternal) {
      throw MomentumError('The controller of type "$T" doesn\'t exists '
          'or was not initialized from the "controllers" parameter '
          'in the Momentum constructor.');
    }
    return controller as T?;
  }

  T _getService<T extends MomentumService>({bool runtimeType = true, dynamic alias}) {
    var type = _getType<T>();
    if (type == _getType<InjectService<MomentumService>>()) {
      throw _invalidService;
    }
    if (type == _getType<InjectService<dynamic>>()) {
      throw _invalidService;
    }
    var isGrabbingWithInject = <T>[] is List<InjectService>;
    T? result;
    if (!runtimeType) {
      if (alias == null) {
        result = _services.firstWhereOrNull((s) => s is T) as T?;
        if (result == null && !isGrabbingWithInject) {
          result = _services
              .whereType<InjectService>()
              .firstWhereOrNull((i) => i._service is T)
              ?._service as T?;
        }
      } else {
        var injectors = _services
            .whereType<InjectService>()
            .where((s) => s._alias == alias);
        if (isGrabbingWithInject) {
          result = injectors.firstWhereOrNull((s) => s is T) as T?;
        } else {
          result = injectors
              .firstWhereOrNull((s) => s._service is T)
              ?._service as T?;
        }
      }
    } else {
      var injectType = _getType<InjectService<T>>();
      if (alias == null) {
        result = _services.firstWhereOrNull(
          (c) => c.runtimeType == type,
        ) as T?;
        if (result == null) {
          var injectors = _services
              .where(
                (s) => s.runtimeType == injectType,
              )
              .cast<InjectService>()
              .toList();
          if (injectors.isNotEmpty) {
            result = injectors
                .firstWhereOrNull(
                  (i) => i._service.runtimeType == type,
                )
                ?._service as T?;
          }
        }
      } else {
        var injectors = _services
            .whereType<InjectService>()
            .where((s) => s._alias == alias)
            .toList();
        if (isGrabbingWithInject) {
          result = injectors.firstWhereOrNull(
            (s) => s.runtimeType == type || s.runtimeType == injectType,
          ) as T?;
        } else {
          result = injectors
              .firstWhereOrNull(
                (s) => s.runtimeType == type || s.runtimeType == injectType,
              )
              ?._service as T?;
        }
      }
    }
    if (result == null) {
      throw MomentumError('The service class of type "$T" doesn\'t exists or '
          'was not initialized from the "services" parameter '
          'in the Momentum constructor.');
    }
    return result;
  }

  T? _getControllerOfType<T extends MomentumController>([Type? t]) {
    var controller = _controllers.firstWhereOrNull(
      (c) => c.runtimeType == t,
    );
    if (controller == null) {
      return null;
    }
    return controller as T;
  }

  static Momentum _getMomentumInstance(BuildContext context) {
    final momentum = context.getInheritedWidgetOfExactType<Momentum>();
    if (momentum == null) {
      throw const MomentumError(
        '[Momentum]: No Momentum widget found in the widget tree. '
        'Make sure your app is wrapped with a Momentum root widget.',
      );
    }
    return momentum;
  }

  static void _resetAll(
    BuildContext context, {
    bool? clearHistory,
  }) {
    var m = _getMomentumInstance(context);
    for (var controller in m._controllers) {
      controller.reset(clearHistory: clearHistory);
    }
  }

  /// Reset all controller models. All models will
  /// be set to their initial values provided in
  /// the [MomentumController.init] implementation.
  static void resetAll(
    BuildContext context, {
    bool? clearHistory,
  }) {
    var m = _getMomentumInstance(context);
    if (m._onResetAll != null) {
      m._onResetAll!(context, (ctx) => _resetAll(ctx, clearHistory: clearHistory));
    } else {
      _resetAll(context, clearHistory: clearHistory);
    }
  }

  /// Restart your app with the new momentum instance.
  /// It uses [Navigator.pushAndRemoveUntil]
  /// so it removes all previous routes.
  static void restart(BuildContext context, [Momentum? momentum]) {
    var m = momentum ?? Momentum._getMomentumInstance(context);
    if (m._restartCallback != null) {
      m._restartCallback!();
    } else if (momentum == null) {
      throw const MomentumError(
        '[Momentum]: Cannot restart without either a "momentum" argument '
        'or a "restartCallback" configured on Momentum.',
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => momentum),
        (r) => false,
      );
    }
  }

  /// The static method for getting controllers inside a widget.
  static T controller<T extends MomentumController>(BuildContext context) {
    T controller = _getMomentumInstance(context)._getController<T>()!;
    var lazyFirstCall = controller.strategy == BootstrapStrategy.lazyFirstCall;
    if (controller.isLazy! && lazyFirstCall) {
      controller._bootstrap();
      controller._bootstrapAsync();
    }
    return controller;
  }

  /// The static method for getting services inside a widget.
  /// The service must be marked with [MomentumService] and
  /// injected into [Momentum] root widget.
  static T service<T extends MomentumService>(
    BuildContext context, {
    bool runtimeType = true,
    dynamic alias,
  }) {
    return _getMomentumInstance(context)._getService<T>(runtimeType: runtimeType, alias: alias);
  }

  static T? _ofType<T extends MomentumController>(BuildContext context, Type t) {
    return _getMomentumInstance(context)._getControllerOfType<T>(t);
  }

  static T? _ofInternal<T extends MomentumController>(BuildContext context) {
    return _getMomentumInstance(context)._getController<T>(true);
  }

  @protected
  @override
  bool updateShouldNotify(Momentum oldWidget) => false;
}

/// Testing tool for momentum.
class MomentumTester {
  /// Testing tool for momentum.
  MomentumTester(Momentum momentum) : _momentum = momentum;
  final Momentum _momentum;

  List<MomentumController> get _controllers => _momentum._controllers;
  List<MomentumService> get _services => _momentum._services;
  bool get _disabledPersistentState => _momentum._disabledPersistentState;
  bool get _enableLogging => _momentum._enableLogging;
  int get _maxTimeTravelSteps => _momentum._maxTimeTravelSteps;
  bool get _lazy => _momentum._lazy;
  BootstrapStrategy get _strategy => _momentum._strategy;
  int get _minimumBootstrapTime => _momentum._minimumBootstrapTime;

  /// Initialize the dependencies the same way
  /// they are initialized in root widget.
  Future<void> init() async {
    try {
      if (_momentum._initializer != null) {
        await _momentum._initializer!();
      }
      _initServices();
      await _initControllerModel();
      _bootstrapControllers();
      await _bootstrapControllersAsync();
      _onReadyControllers();
    } catch (e, stackTrace) {
      print(e.toString());
      print(stackTrace.toString());
      throw MomentumError('[Momentum]: Failed to initialize your app. '
          'Check the above stacktrace for details.');
    }
  }

  void _initServices() {
    for (var service in _services) {
      service._tester = this;
      if (service is InjectService) {
        service._service._tester = this;
      }
    }
  }

  Future<void> _initControllerModel() async {
    for (var controller in _controllers) {
      controller._tester = this;
      controller._configInternal(
        disabledPersistentState: _disabledPersistentState,
        enableLogging: _enableLogging,
        maxTimeTravelSteps: _maxTimeTravelSteps,
        lazy: _lazy,
        strategy: _strategy,
      );
      await controller._initializeMomentumController();
    }
  }

  void _bootstrapControllers() {
    var nonLazyControllers = _controllers.where((e) {
      return !e._lazy!;
    });
    for (var nonLazyController in nonLazyControllers) {
      nonLazyController._bootstrap();
    }
  }

  Future<void> _bootstrapControllersAsync() async {
    var started = DateTime.now().millisecondsSinceEpoch;
    var nonLazyControllers = _controllers.where((e) {
      return !e._lazy!;
    });
    var futures = nonLazyControllers.map<Future>((e) => e._bootstrapAsync());
    await Future.wait(futures);
    var finished = DateTime.now().millisecondsSinceEpoch;
    var diff = finished - started;
    num min = _minimumBootstrapTime.clamp(0, 9999999);
    var waitTime = (min - diff).clamp(0, min);
    await Future.delayed(Duration(milliseconds: waitTime.toInt()));
  }

  void _onReadyControllers() {
    for (var controller in _controllers) {
      controller._onReady();
    }
  }

  /// Get a controller of type `T`.
  T? controller<T extends MomentumController?>() {
    var result = _controllers.firstWhereOrNull(
      (c) => c.runtimeType == _getType<T>(),
    );
    return result as T?;
  }

  /// Get a service of type `T`.
  T service<T extends MomentumService>({bool runtimeType = true, dynamic alias}) {
    return _momentum._getService<T>(runtimeType: runtimeType, alias: alias);
  }

  MomentumRouter? _getRouterIfPresent() {
    var result = trycatch(() => service<MomentumRouter>());
    return result;
  }

  /// Mock call `bootstrap()` and `bootstrapAsync()`
  /// for a specific lazy *controller* for testing.
  Future<void> mockLazyBootstrap<T extends MomentumController>() async {
    T ctrl = controller<T>()!;
    if (ctrl.isLazy!) {
      ctrl._bootstrap();
      await ctrl._bootstrapAsync();
    }
  }

  /// Mock router params for testing.
  void mockRouterParam(RouterParam param) {
    service<MomentumRouter>().mockParam(param);
    for (var controller in _controllers) {
      if (controller is RouterMixin) {
        (controller as RouterMixin).onRouteChanged(param);
      }
    }
    print('Mock params has been set (${param.runtimeType}): $param');
  }
}
