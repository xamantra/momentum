import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'momentum_types.dart';

/// A trycatch wrapper that shortens its syntax.
T _trycatch<T>(T Function() body, [T defaultValue]) {
  try {
    var result = body();
    return result ?? defaultValue;
  } finally {
    return defaultValue;
  }
}

@sealed
class _MomentumListener<M> {
  final MomentumState state;

  final void Function(M, bool) invoke;

  _MomentumListener({@required this.state, @required this.invoke});
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
  @required
  void update();

  /// A method which must be explicitly called
  /// inside your `update()` implementation.
  @protected
  void updateMomentum() {
    controller._setMomentum(this);
  }
}

/// The class which holds the logic for your app.
/// This is tied with [MomentumModel].
abstract class MomentumController<M> {
  BuildContext _momentumRootContext;

  // ignore: avoid_setters_without_getters
  set _setMomentumRootContext(BuildContext context) {
    _momentumRootContext = context;
  }

  /// Dependency injection method for getting other controllers.
  /// Useful for accessing other controllers' function
  /// and model properties without dragging the widget context around.
  @protected
  T dependOn<T extends MomentumController>() {
    if (this is T) {
      throw Exception(_formatMomentumLog('[$this]: called '
          '"dependOn<$T>()" on itself, you\'re not '
          'allowed to do that.'));
    }
    var result = Momentum._ofInternal<T>(_momentumRootContext);
    if (result == null) {
      throw Exception(_formatMomentumLog('[$this]: called '
          '"dependOn<$T>()", but no controller of type '
          '[$T] had been found.\nTry checking your "Momentum" '
          'root widget implementation if the controller '
          '"$T" was instantiated there.'));
    }
    return result;
  }

  /// A method for getting a service marked with
  /// [MomentumService] that are injected into
  /// [Momentum] root widget.
  @protected
  T getService<T extends MomentumService>() {
    var result = Momentum.getService<T>(_momentumRootContext);
    if (result == null) {
      throw Exception(_formatMomentumLog('[$this]: called '
          '"dependOn<$T>()", but no service of type [$T] '
          'had been found.\nTry checking your "Momentum" '
          'root widget implementation if the service "$T" '
          'was instantiated there.'));
    }
    return result;
  }

  bool _booted = false;
  bool _bootedAsync = false;

  /// An optional callback for synchronous initialization.
  /// If lazy loading is disabled this will be called right when
  /// the app starts. Use `bootstrapAsync()` if you want asynchronous.
  void bootstrap() {}
  void _bootstrap() {
    if (!_booted) {
      _booted = true;
      bootstrap();
      if (_momentumLogging) {
        print(_formatMomentumLog('[$this] => bootstrap() '
            'called! { lazy: $_lazy }'));
      }
    }
  }

  /// An optional callback for asynchronous initialization.
  /// If lazy loading is disabled this will be called right when
  /// the app starts and displays a loading widget until the async
  /// operation is finished.
  Future<void> bootstrapAsync() async {}
  Future<void> _bootstrapAsync() async {
    if (!_bootedAsync) {
      _bootedAsync = true;
      if (_momentumLogging) {
        print(_formatMomentumLog('[$this] => executing '
            'bootstrapAsync() { lazy: $_lazy } ...'));
      }
      var started = DateTime.now().millisecondsSinceEpoch;
      await bootstrapAsync();
      var finished = DateTime.now().millisecondsSinceEpoch;
      var diff = finished - started;
      if (_momentumLogging) {
        print(_formatMomentumLog('[$this] => bootstrapAsync() '
            'completed! { lazy: $_lazy, took: ${diff}ms }'));
      }
    }
  }

  List<_MomentumListener> _momentumListeners = [];
  List<_MomentumListener<M>> _externalMomentumListeners = [];

  M _currentActiveModel;

  M _prevModel;
  M _nextModel;

  /// Previous model state.
  /// Will only have a value if time travel is enabled.
  M get prevModel => _prevModel;

  /// Next model state.
  /// Will only have a value if time travel
  /// is enabled and `backward()` was called.
  M get nextModel => _nextModel;

  /// The current model state.
  /// The initial value is specified in your
  /// `init()` implementation.
  M get model => _currentActiveModel;

  List<M> _momentumModelHistory;

  M _initialMomentumModel;

  M _latestMomentumModel;

  bool _momentumControllerInitialized = false;

  M _initializeMomentumController() {
    _checkInitImplementation();
    if (!_momentumControllerInitialized) {
      _momentumControllerInitialized = true;
      _momentumListeners ??= [];
      _externalMomentumListeners ??= [];
      _momentumModelHistory ??= [];
      _currentActiveModel = init();
      _momentumModelHistory.add(_currentActiveModel);
      _initialMomentumModel ??= _momentumModelHistory[0];
      if (_momentumLogging) {
        print(_formatMomentumLog('[$this] has been '
            'initialized. {maxTimeTravelSteps: $_maxTimeTravelSteps}'));
      }
    }
    return model;
  }

  /// Initial the model of this controller.
  /// Required to be implemented.
  @protected
  @required
  M init();

  void _checkInitImplementation() {
    var initValue = init();
    if (initValue == null) {
      throw Exception(_formatMomentumLog('[$this]: your "init()" '
          'method implementation returns NULL, please return a '
          'valid instance of "$M"'));
    }
    if (!(initValue is M)) {
      throw Exception(_formatMomentumLog('[$this]: your "init()" '
          'method implementation does not return an instance of '
          'type "$M", please return a valid instance of "$M".'));
    }
    if ((initValue as MomentumModel).controller == null) {
      var name = '$this'.replaceAll('Instance of', '');
      throw Exception(_formatMomentumLog('[$this]: your "init()" '
          'method implementation returns an instance of "$M" but '
          'the "controller" property is null, please pass in a '
          'non-null value to it. But since "$M" is attached to '
          '$name and vice versa. You can just pass in this '
          'controller\'s instance like this:\n\nreturn '
          '$M(\n    this,\n    ...\n);'));
    }
    initValue = null;
    return;
  }

  void _setMomentum(
    M model, {
    bool backward = false,
    bool forward = false,
    bool timeTraveled = false,
  }) {
    var isTimeTravel = backward || forward;
    if (isTimeTravel) {
      _currentActiveModel = _momentumModelHistory.last;
    } else {
      if (_momentumModelHistory.length == _maxTimeTravelSteps) {
        _momentumModelHistory.removeAt(0);
        var historyCount = _momentumModelHistory.length;
        var firstItem = _momentumModelHistory[0];
        _initialMomentumModel = historyCount > 0 ? firstItem : model;
      }
      _currentActiveModel = model;
      _latestMomentumModel = _currentActiveModel;
      _momentumModelHistory.add(_currentActiveModel);

      _nextModel = null;
      _prevModel = _trycatch(
        () => _momentumModelHistory[_momentumModelHistory.length - 2],
      );
    }
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
        externalListener.invoke(_currentActiveModel, isTimeTravel);
      }
    }
    if (_momentumLogging) {
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

  /// Time travel method.
  /// An `undo` function for states.
  /// This method will set the model state one step behind.
  void backward() {
    if (_currentActiveModel != _initialMomentumModel) {
      var latestModel = _momentumModelHistory.last;
      _nextModel = latestModel;
      _momentumModelHistory.removeWhere((x) => x == latestModel);
      _momentumModelHistory.insert(0, latestModel);
      _prevModel = _trycatch(
        () => _momentumModelHistory[_momentumModelHistory.length - 2],
      );
      _setMomentum(null, backward: true);
    }
  }

  /// Time travel method.
  /// A `redo` function for states.
  /// If `backward()` was called before, this method will
  /// set the model state one step ahead.
  void forward() {
    var latestNotNull = _latestMomentumModel != null;
    var currentNotLatest = _currentActiveModel != _latestMomentumModel;
    if (latestNotNull && currentNotLatest) {
      var firstModel = _momentumModelHistory.first;
      _momentumModelHistory.removeWhere((x) => x == firstModel);
      _momentumModelHistory.add(firstModel);
      _prevModel = _trycatch(
        () => _momentumModelHistory[_momentumModelHistory.length - 2],
      );
      _nextModel = _trycatch(() => _momentumModelHistory[0]);
      if (_nextModel == _initialMomentumModel) {
        _nextModel = null;
      }
      _setMomentum(null, forward: true);
    }
  }

  void _addListenerInternal(_MomentumListener _momentumListener) {
    _momentumListeners.add(_momentumListener);
  }

  /// Add a listener for this controller.
  /// Requires [MomentumState].
  /// Example uses is for displaying dialogs, snackbars, and navigation.
  void addListener({
    @required MomentumState state,
    void Function(M, bool) invoke,
  }) {
    _externalMomentumListeners.add(_MomentumListener<M>(
      state: state,
      invoke: invoke,
    ));
  }

  void _cleanupListeners() {
    _momentumListeners.removeWhere((x) => !x.state.mounted);
    _externalMomentumListeners.removeWhere((x) => !x.state.mounted);
  }

  /// Reset the model of this controller.
  /// The implementation of `init()` is used.
  ///
  /// NOTE: The model history is not cleared
  /// so you can still use time-travel methods
  /// `backward()` and `forward()`.
  void reset() {
    _checkInitImplementation();
    _currentActiveModel = init();
    _setMomentum(_currentActiveModel);
    if (_momentumLogging) {
      print(_formatMomentumLog('[$this] has been reset.'));
    }
  }

  bool _momentumLogging;
  int _maxTimeTravelSteps;
  bool _lazy;

  /// A getter that indicates if this controller is lazy loaded or not.
  bool get isLazy => _lazy;
  bool _configMethodCalled = false;

  /// Configure this controller to set some custom behaviours.
  void config({
    bool enableLogging,
    int maxTimeTravelSteps,
    bool lazy,
  }) {
    if (!_configMethodCalled) {
      _configMethodCalled = true;
      _momentumLogging = enableLogging;
      _maxTimeTravelSteps = maxTimeTravelSteps?.clamp(1, 250);
      _lazy = lazy;
    }
  }

  void _configInternal({
    bool enableLogging,
    int maxTimeTravelSteps,
    bool lazy,
  }) {
    _momentumLogging ??= enableLogging ?? true;
    _maxTimeTravelSteps ??= (maxTimeTravelSteps ?? 1).clamp(1, 250);
    _lazy ??= lazy ?? true;
  }

  String _formatMomentumLog(String log) {
    return log.replaceAll('Instance of ', 'Momentum -> ');
  }
}

/// Use for marking any classes as services
/// to inject them into the `services` parameter
/// of [Momentum] root widget and use them
/// down the tree.
abstract class MomentumService {}

/// A [State] class with additional properties.
/// Also allows you to add listeners for controllers.
abstract class MomentumState<T extends StatefulWidget> extends State<T> {
  bool _stateDeactivated = false;

  /// A property that indicates if the [StatefulWidget] for this [State]
  /// or the parent is active on the navigation stack.
  bool get deactivated => _stateDeactivated;

  @override
  void initState() {
    _stateDeactivated = false;
    super.initState();
  }

  @override
  void deactivate() {
    _stateDeactivated = true;
    super.deactivate();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _stateDeactivated = false;
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

/// The widget class for display your model properties.
@sealed
class MomentumBuilder extends StatefulWidget {
  /// Optional used for detailed error logs.
  /// Simply specify with `owner: this` for
  /// [StatelessWidget] and `owner: widget`
  /// for [StatefulWidget], to set the
  /// current widget as the owner.
  final Widget owner;

  /// The list of controllers you want to inject
  /// into this [MomentumBuilder].
  @protected
  final List<Type> controllers;

  /// An optional callback. If provided, this will be called
  /// right before [MomentumBuilder.builder].
  /// If returns `true`, it will skip rebuild for this [MomentumBuilder].
  final BuildSkipper dontRebuildIf;

  /// The parameter for building your model snapshots.
  /// Returns a widget and must not be null.
  @protected
  final MomentumBuilderFunction builder;

  /// Create a widget for display your model properties.
  /// Parameter `controllers` and `builder` is required.
  const MomentumBuilder({
    Key key,
    this.owner,
    @required this.controllers,
    @required this.builder,
    this.dontRebuildIf,
  }) : super(key: key);

  @protected
  @override
  _MomentumBuilderState createState() => _MomentumBuilderState();
}

@sealed
class _MomentumBuilderState extends MomentumState<MomentumBuilder> {
  List<MomentumController> ctrls;

  final _models = <dynamic>[];

  String get _logHeader {
    var noOwner = widget.owner == null;
    var h = '[$Momentum > $MomentumBuilder]:';
    var oh = '[$Momentum > ${widget.owner.runtimeType} > $MomentumBuilder]:';
    return noOwner ? h : oh;
  }

  bool _momentumBuilderInitialized = false;

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
  Widget build(BuildContext context) {
    if (widget.builder == null) {
      throw Exception('$_logHeader The '
          'parameter "builder" for ${widget.runtimeType} widget '
          'must not be null.');
    }
    return widget.builder(context, _modelSnapshotOfType);
  }

  void _init() {
    ctrls = <MomentumController>[];
    for (var t in (widget.controllers ?? <Type>[])) {
      var c = Momentum._ofType(context, t);
      if (c != null) {
        ctrls.add(c);
      } else {
        throw Exception('$_logHeader The controller of type '
            '"$t" is not initialized in the Momentum root '
            'widget.\nPossible solutions:\n\tCheck if you '
            'initialized the controller attached to this '
            'model on the Momentum root widget.');
      }
    }
    if (ctrls.isNotEmpty) {
      _models.addAll(ctrls.map((_) => null));
      for (var i = 0; i < ctrls.length; i++) {
        if (ctrls[i]._lazy) {
          ctrls[i]._bootstrap();
          ctrls[i]._bootstrapAsync();
        }
        _updateModel(i, ctrls[i]?.model, ctrls[i], false);
        ctrls[i]?._addListenerInternal(
          _MomentumListener(
            state: this,
            invoke: (data, isTimeTravel) {
              if (mounted) {
                var dontRebuild = false;
                if (widget.dontRebuildIf != null) {
                  dontRebuild = widget.dontRebuildIf(
                    _getController,
                    isTimeTravel,
                  );
                }
                _updateModel(i, data, ctrls[i], !dontRebuild);
              }
            },
          ),
        );
      }
    }
    return;
  }

  T _modelSnapshotOfType<T extends MomentumModel>() {
    if (widget.controllers == null) {
      throw Exception('$_logHeader The '
          'parameter "controllers" for ${widget.runtimeType} widget '
          'must not be null.');
    }
    var controller = ctrls?.firstWhere(
      (x) => x?.model is T,
      orElse: () => null,
    );
    if (controller == null) {
      throw Exception('$_logHeader The controller '
          'for the model of type "$T" is either not injected in this '
          '${widget.runtimeType} or not initialized in the Momentum root '
          'widget or can be both.\nPossible solutions:\n\t1. Check if '
          'you initialized the controller attached to this model on the '
          'Momentum root widget.\n\t2. Check the controller attached '
          'to this model if it is injected into this ${widget.runtimeType}');
    }
    var model = _models.firstWhere((c) => c is T, orElse: () => null);
    if (model == null) {
      throw Exception(controller._formatMomentumLog('$_logHeader '
          'An attempt to grab an instance of "$T" failed inside '
          '${widget.runtimeType}\'s "builder" function.'));
    }

    return model as T;
  }

  T _getController<T extends MomentumController>() {
    if (widget.controllers == null) {
      throw Exception('$_logHeader The '
          'parameter "controllers" for ${widget.runtimeType} widget '
          'must not be null.');
    }
    var controller = ctrls?.firstWhere((x) => x is T, orElse: () => null);
    if (controller == null) {
      throw Exception('$_logHeader A controller of '
          'type "$T" is either not injected in this ${widget.runtimeType} '
          'or not initialized in the Momentum root widget or can be both.'
          '\nPossible solutions:\n\t1. Check if you initialized "$T" on the '
          'Momentum root widget.\n\t2. Check "$T" if it is injected '
          'into this ${widget.runtimeType}');
    }
    return controller as T;
  }

  void _updateModel<T>(
    int index,
    T newModel,
    MomentumController controller, [
    bool updateState = true,
  ]) {
    // Trigger rebuild with the new list of updated models.
    _models[index] = newModel;
    if (updateState) {
      try {
        setState(_);
      } on Exception catch (e) {
        print('[$Momentum] -> $_updateModel: $e\nDon\t worry about '
            'this exception, your app still runs fine. This error '
            'is catched by the library. This likely happens when '
            'you call "model.update(...)" from one of this widget\'s '
            'descendants while the widget tree is still building.');
        if (controller._momentumLogging) {
          print(StackTrace.current);
        }
      }
    }
  }

  _() {}
}

@sealed
class _MomentumRoot extends StatefulWidget {
  final Widget child;
  final Widget appLoader;
  final List<MomentumController> controllers;
  final bool enableLogging;
  final int maxTimeTravelSteps;
  final bool lazy;
  final int minimumBootstrapTime;

  const _MomentumRoot({
    Key key,
    @required this.child,
    this.appLoader,
    @required this.controllers,
    this.enableLogging,
    this.maxTimeTravelSteps,
    this.lazy,
    this.minimumBootstrapTime,
  }) : super(key: key);
  @override
  _MomentumRootState createState() => _MomentumRootState();
}

@sealed
class _MomentumRootState extends State<_MomentumRoot> {
  bool _momentumRootStateInitialized = false;
  bool _momentumControllersBootstrapped = false;
  bool get _canStartApp {
    return _momentumRootStateInitialized && _momentumControllersBootstrapped;
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    if (!_momentumRootStateInitialized) {
      _momentumRootStateInitialized = true;
      for (var controller in widget.controllers) {
        (controller.._setMomentumRootContext = context)
          .._configInternal(
            enableLogging: widget.enableLogging,
            maxTimeTravelSteps: widget.maxTimeTravelSteps,
            lazy: widget.lazy,
          )
          .._initializeMomentumController();
      }
      _bootstrapControllers(widget.controllers);
      _bootstrapControllersAsync(widget.controllers);
    }
    super.didChangeDependencies();
  }

  void _bootstrapControllers(List<MomentumController> controllers) {
    var lazyControllers = widget.controllers.where((e) => !e._lazy);
    for (var lazyController in lazyControllers) {
      lazyController._bootstrap();
    }
  }

  void _bootstrapControllersAsync(List<MomentumController> controllers) async {
    var started = DateTime.now().millisecondsSinceEpoch;
    var nonLazyControllers = widget.controllers.where((e) => !e._lazy);
    var futures = nonLazyControllers.map<Future>((e) => e._bootstrapAsync());
    await Future.wait(futures);
    var finished = DateTime.now().millisecondsSinceEpoch;
    var diff = finished - started;
    var min = (widget.minimumBootstrapTime ?? 0).clamp(0, 9999999);
    var waitTime = (min - diff).clamp(0, min);
    await Future.delayed(Duration(milliseconds: waitTime));
    setState(() {
      _momentumControllersBootstrapped = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var error = Momentum._getMomentumInstance(context)._validateControllers(
      widget.controllers,
    );
    if (error != null) throw Exception(error);
    if (_canStartApp) {
      return widget.child;
    } else {
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
    }
  }
}

/// The root widget for configuring [Momentum].
@sealed
class Momentum extends InheritedWidget {
  const Momentum._internal({
    Key key,
    @required Widget child,
    List<MomentumController> controllers,
    List<MomentumService> services,
    ResetAll onResetAll,
    Future<bool> persistSave,
    Future<String> persistGet,
  })  : _controllers = controllers ?? const [],
        _onResetAll = onResetAll,
        _services = services ?? const [],
        _persistSave = persistSave,
        _persistGet = persistGet,
        super(key: key, child: child);

  /// Configure your app with [Momentum] root widget.
  factory Momentum({
    @required Widget child,
    Widget appLoader,
    @required List<MomentumController> controllers,
    List<MomentumService> services,
    ResetAll onResetAll,
    bool enableLogging,
    int maxTimeTravelSteps,
    bool lazy,
    int minimumBootstrapTime,
    Future<bool> persistSave,
    Future<String> persistGet,
  }) {
    return Momentum._internal(
      child: _MomentumRoot(
        child: child,
        appLoader: appLoader,
        controllers: controllers,
        enableLogging: enableLogging,
        maxTimeTravelSteps: maxTimeTravelSteps,
        lazy: lazy,
        minimumBootstrapTime: minimumBootstrapTime,
      ),
      controllers: controllers,
      services: services,
      onResetAll: onResetAll,
      persistSave: persistSave,
      persistGet: persistGet,
    );
  }

  String _validateControllers(List<MomentumController> controllers) {
    var passedIn = '';
    for (var controller in controllers) {
      if (controller != null) {
        passedIn += '\n   ${controller.runtimeType}(),';
      } else {
        passedIn += '\n   null,';
      }
    }
    passedIn = 'controllers: [$passedIn\n]\n';
    for (var controller in controllers) {
      if (controller == null) {
        return '[$Momentum] -> A null value has been passed '
            'in controllers parameter of Momentum root '
            'widget.\n\nControllers config:\n\n$passedIn';
      }
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

  final List<MomentumController> _controllers;

  final List<MomentumService> _services;

  final ResetAll _onResetAll;

  final Future<bool> _persistSave;
  final Future<String> _persistGet;

  T _getController<T extends MomentumController>([bool isInternal = false]) {
    var controller = _controllers.firstWhere((c) => c is T, orElse: () => null);
    if (controller == null && !isInternal) {
      throw Exception('The controller of type "$T" doesn\'t exists '
          'or was not initialized from the "controllers" parameter '
          'in the Momentum constructor.');
    }
    return controller;
  }

  T _getService<T extends MomentumService>() {
    var service = _services.firstWhere((c) => c is T, orElse: () => null);
    if (service == null) {
      throw Exception('The service class of type "$T" doesn\'t exists or '
          'was not initialized from the "services" parameter '
          'in the Momentum constructor.');
    }
    return service;
  }

  T _getControllerOfType<T extends MomentumController>([
    Type t,
    bool isInternal = false,
  ]) {
    var controller = _controllers.firstWhere(
      (c) => c.runtimeType == t,
      orElse: () => null,
    );
    if (controller == null && !isInternal) {
      throw Exception('The controller of type "$T" doesn\'t exists or '
          'was not initialized from the "controllers" '
          'parameter in the Momentum constructor.');
    }
    return controller as T;
  }

  static Momentum _getMomentumInstance(BuildContext context) {
    // ignore: deprecated_member_use
    return (context.inheritFromWidgetOfExactType(Momentum) as Momentum);
  }

  static void _resetAll(BuildContext context) {
    var m = _getMomentumInstance(context);
    for (var controller in m._controllers) {
      controller?.reset();
    }
  }

  /// Reset all controller models. All models will
  /// be set to their initial values provided in
  /// the [MomentumController.init] implementation.
  static void resetAll(BuildContext context) {
    var m = _getMomentumInstance(context);
    if (m._onResetAll != null) {
      m._onResetAll(context, _resetAll);
    } else {
      _resetAll(context);
    }
  }

  /// Restart your app with the new momentum instance.
  /// It uses [Navigator.pushAndRemoveUntil]
  /// so it removes all previous routes.
  static void restart(BuildContext context, Momentum momentum) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => momentum),
      (r) => false,
    );
  }

  /// The static method for getting controllers inside widget.
  /// It uses deprecated method `inheritFromWidgetOfExactType`
  /// to support older versions of flutter.
  static T of<T extends MomentumController>(BuildContext context) {
    return _getMomentumInstance(context)._getController<T>();
  }

  /// The static method for getting services inside a widget.
  /// The service must be marked with [MomentumService] and
  /// injected into [Momentum] root widget.
  static T getService<T extends MomentumService>(BuildContext context) {
    return _getMomentumInstance(context)._getService<T>();
  }

  static T _ofType<T extends MomentumController>(BuildContext context, Type t) {
    return _getMomentumInstance(context)._getControllerOfType<T>(t, true);
  }

  static T _ofInternal<T extends MomentumController>(BuildContext context) {
    return _getMomentumInstance(context)._getController<T>(true);
  }

  @protected
  @override
  bool updateShouldNotify(Momentum oldWidget) => false;
}
