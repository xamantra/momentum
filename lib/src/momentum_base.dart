import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'momentum_error.dart';
import 'momentum_event.dart';
import 'momentum_router.dart';

import 'momentum_types.dart';

Type _getType<T>() => T;

///
T trycatch<T>(T Function() body, [T defaultValue]) {
  try {
    var result = body();
    return result ?? defaultValue;
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    return defaultValue;
  }
}

///
Future<T> tryasync<T>(Future<T> Function() body, [T defaultValue]) async {
  try {
    var result = await body();
    return result ?? defaultValue;
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
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

  /// This is different from the usual factory `fromJson` method.
  /// It's an instance member because you wouldn't be able to access
  /// the `controller` property otherwise.
  MomentumModel fromJson(Map<String, dynamic> json) => null;

  /// Method to generate map from this model.
  Map<String, dynamic> toJson() => null;
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
  T dependOn<T extends MomentumController>() {
    var type = _getType<T>();
    if (runtimeType == type) {
      throw MomentumError(_formatMomentumLog('[$this]: called '
          '"dependOn<$T>()" on itself, you\'re not '
          'allowed to do that.'));
    }
    var result = Momentum._ofInternal<T>(_momentumRootContext);
    if (result == null) {
      throw MomentumError(_formatMomentumLog('[$this]: called '
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
  T getService<T extends MomentumService>() {
    try {
      var result = Momentum.getService<T>(_momentumRootContext);
      return result;
    } on dynamic catch (e) {
      if (_momentumLogging) {
        print(e);
      }
      throw MomentumError(_formatMomentumLog('[$this]: called '
          '"dependOn<$T>()", but no service of type [$T] '
          'had been found.\nTry checking your "Momentum" '
          'root widget implementation if the service "$T" '
          'was instantiated there.'));
    }
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
  final List<MomentumEvent> _eventHandlers = List.from([], growable: true);

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

  Future<void> _initializeMomentumController() async {
    _checkInitImplementation();
    if (!_momentumControllerInitialized) {
      _persistenceConfigured(true);
      _momentumControllerInitialized = true;
      _momentumListeners ??= [];
      _externalMomentumListeners ??= [];
      _momentumModelHistory ??= [];
      _currentActiveModel = init();
      var persistedModel = await _getPersistedModel();
      if (persistedModel != null) {
        _currentActiveModel = persistedModel;
      }
      _momentumModelHistory.add(_currentActiveModel);
      _initialMomentumModel ??= _momentumModelHistory[0];
      if (_momentumLogging) {
        print(_formatMomentumLog('[$this] has been '
            'initialized. {maxTimeTravelSteps: $_maxTimeTravelSteps}'));
      }
    }
    return model;
  }

  /// Initialize the model of this controller.
  /// Required to be implemented.
  @protected
  @required
  M init();

  /// Method for testing only.
  void testInit() {
    _checkInitImplementation();
  }

  void _checkInitImplementation() {
    var initValue = init();
    if (initValue == null) {
      throw MomentumError(_formatMomentumLog('[$this]: your "init()" '
          'method implementation returns NULL, please return a '
          'valid instance of "$M"'));
    }
    if ((initValue as MomentumModel).controller == null) {
      var name = '$this'.replaceAll('Instance of', '');
      throw MomentumError(_formatMomentumLog('[$this]: your "init()" '
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
  }) {
    var isTimeTravel = backward || forward;
    if (isTimeTravel) {
      _currentActiveModel = _momentumModelHistory.last;
    } else {
      // equatable check, do not update model if values are the same.
      if (_currentActiveModel == model) {
        return;
      }

      if (_momentumModelHistory.length == _maxTimeTravelSteps) {
        _momentumModelHistory.removeAt(0);
        var historyCount = _momentumModelHistory.length;
        var firstItem = trycatch(() => _momentumModelHistory[0]);
        _initialMomentumModel = historyCount > 0 ? firstItem : model;
      }

      _currentActiveModel = model;
      _latestMomentumModel = _currentActiveModel;
      _momentumModelHistory.add(_currentActiveModel);

      _nextModel = null;
      _prevModel = trycatch(
        () => _momentumModelHistory[_momentumModelHistory.length - 2],
      );
    }

    _persistModel(_currentActiveModel);

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

  /// You can use this method to
  /// enable/disable persistence
  /// for this controller.
  /// Returns `false` by default.
  /// Because this is asynchronous,
  /// you can do any asynchronous code.
  Future<bool> skipPersist() async {
    return false;
  }

  bool _persistenceConfigured([bool printLog = false]) {
    var momentum = Momentum._getMomentumInstance(_momentumRootContext);
    var hasSaver = momentum._persistSave != null;
    var hasGet = momentum._persistGet != null;
    if (hasSaver && !hasGet) {
      if (_momentumLogging && printLog) {
        print(_formatMomentumLog('[$this] "persistSave" is '
            'specified but "persistGet" is not. These two functions must '
            'be present to enable persistence state.'));
      }
    }
    if (!hasSaver && hasGet) {
      if (_momentumLogging && printLog) {
        print(_formatMomentumLog('[$this] "persistGet" is '
            'specified but "persistSave" is not. These two functions must '
            'be present to enable persistence state.'));
      }
    }
    var configured = hasSaver && hasGet;
    if (configured && _momentumLogging && printLog) {
      print(
        '[$Momentum] Persistence state ready with key "$persistenceKey"',
      );
    }
    return configured;
  }

  String _persistenceKey;

  /// The key used internally by momentum
  /// for persistence with this controller.
  /// You can also use this to clear the data
  /// or even override the persisted json value
  /// (**use with caution**).
  String get persistenceKey {
    if (_persistenceKey == null) {
      _persistenceKey = '$Momentum[$this<$M>]'.replaceAll('\'', '');
    }
    return _persistenceKey;
  }

  Future<void> _persistModel(M model) async {
    var skip = await skipPersist();
    if (skip || !_persistenceConfigured()) return;
    var momentum = Momentum._getMomentumInstance(_momentumRootContext);
    if (momentum._persistSave != null) {
      Map<String, dynamic> json;
      String modelRawJson;
      try {
        json = (model as MomentumModel).toJson();
        modelRawJson = jsonEncode(json);
      } on dynamic catch (e, stackTrace) {
        print(e);
        print(stackTrace);
      }
      if (modelRawJson == null || modelRawJson.isEmpty) {
        if (_momentumLogging) {
          print(_formatMomentumLog('[$this] "persistSave" is specified '
              'but the $M\'s "toJson" implementation returns '
              'a null or empty string when "jsonEncode(...)" '
              'was called. Try to check the implementation.'));
        }
      } else {
        var isSaved = await momentum._persistSave(
          _momentumRootContext,
          persistenceKey,
          modelRawJson,
        );
        if (!isSaved && _momentumLogging) {
          print(_formatMomentumLog('[$this] wasn\'t able '
              'to save your model state using "persistSave". '
              'Try to check your code.'));
        }
      }
    }
  }

  Future<M> _getPersistedModel() async {
    var skip = await skipPersist();
    if (skip || !_persistenceConfigured()) return null;
    M result;
    var momentum = Momentum._getMomentumInstance(_momentumRootContext);
    if (momentum._persistGet != null) {
      var modelRawJson = await tryasync(
        () => momentum._persistGet(_momentumRootContext, persistenceKey),
      );
      if (modelRawJson == null || modelRawJson.isEmpty) {
        if (_momentumLogging) {
          print(_formatMomentumLog('[$this] unable to get persisted'
              'value using "persistGet". There might not be a data yet '
              'or there\'s something wrong with your implementation.'));
        }
      } else {
        var json = trycatch(() => jsonDecode(modelRawJson));
        if (json == null && _momentumLogging) {
          print(_formatMomentumLog('[$this] unable to parse persisted'
              'value using "jsonDecode" into a map. '
              'The raw json value is ```$modelRawJson```.'));
        } else {
          try {
            result = (model as MomentumModel).fromJson(json) as M;
          } on dynamic catch (e, stackTrace) {
            print(e);
            print(stackTrace);
          }
          if (result == null && _momentumLogging) {
            print(_formatMomentumLog('[$this] "$M.fromJson" returns a null. '
                'Try to check your "$M.fromJson()" implementation.'));
          }
        }
      }
    }
    return result;
  }

  /// Time travel method.
  /// An `undo` function for states.
  /// This method will set the model state one step behind.
  void backward() {
    if (!identical(_currentActiveModel, _initialMomentumModel)) {
      var latestModel = _momentumModelHistory.last;
      _nextModel = latestModel;
      _momentumModelHistory.removeWhere((x) => identical(x, latestModel));
      _momentumModelHistory.insert(0, latestModel);
      _prevModel = trycatch(
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
    var currentNotLatest = !identical(
      _currentActiveModel,
      _latestMomentumModel,
    );
    if (latestNotNull && currentNotLatest) {
      var firstModel = _momentumModelHistory.first;
      _momentumModelHistory.removeWhere((x) => identical(x, firstModel));
      _momentumModelHistory.add(firstModel);
      _prevModel = trycatch(
        () => _momentumModelHistory[_momentumModelHistory.length - 2],
      );
      _nextModel = trycatch(() => _momentumModelHistory[0]);
      if (identical(_nextModel, _initialMomentumModel)) {
        _nextModel = null;
      }
      _setMomentum(null, forward: true);
    }
  }

  void _addListenerInternal(_MomentumListener _momentumListener) {
    _momentumListeners.add(_momentumListener);
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
    @required MomentumState state,
    @required void Function(M, bool) invoke,
  }) {
    _externalMomentumListeners.add(_MomentumListener<M>(
      state: state,
      invoke: invoke,
    ));
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
    @required MomentumState state,
    @required void Function(T data) invoke,
  }) {
    _eventHandlers.add(state._eventHandler..add<T>().listen(invoke));
  }

  /// Send event data to all listeners of data type `T`.
  /// Listeners are created using [MomentumController.listen].
  /// This should be used for notifying the widgets to show
  /// dialogs/snackbars/toast/alerts/etc.
  void sendEvent<T>(T data) {
    _eventHandlers.removeWhere((x) => x.streamController.isClosed);
    for (var event in _eventHandlers) {
      event.trigger(data);
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
  void reset({bool clearHistory}) {
    _checkInitImplementation();
    if (clearHistory ?? false) {
      _momentumModelHistory.clear();
      _currentActiveModel = init();
      _momentumModelHistory.add(_currentActiveModel);
      _initialMomentumModel = _momentumModelHistory[0];
      _latestMomentumModel = _momentumModelHistory[0];
      _nextModel = null;
      _prevModel = null;
      _setMomentum(null, backward: true);
    } else {
      _currentActiveModel = init();
      _setMomentum(init());
    }
    if (_momentumLogging) {
      print(_formatMomentumLog('[$this] has been reset.'));
    }
  }

  bool _momentumLogging;

  /// Indicates whether debug logging for this controller is enable or not.
  bool get loggingEnabled => _momentumLogging;
  int _maxTimeTravelSteps;

  /// Maximum number of steps this controller can undo and redo states.
  int get maxTimeTravelSteps => _maxTimeTravelSteps;
  bool _lazy;

  /// A getter that indicates if this controller is lazy loaded or not.
  bool get isLazy => _lazy;
  bool _configMethodCalled = false;

  /// Configure this controller to set some custom behaviors.
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
    _momentumLogging ??= enableLogging ?? false;
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
  final MomentumEvent _eventHandler = MomentumEvent();
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

  @override
  void dispose() {
    _eventHandler.destroy();
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

  // final _models = <dynamic>[];

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
      throw MomentumError('$_logHeader The '
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
      }
    }
    if (ctrls.isNotEmpty) {
      // _models.addAll(ctrls.map((_) => null));
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

  T _modelSnapshotOfType<T extends MomentumModel>([Type c]) {
    if (widget.controllers == null) {
      throw MomentumError('$_logHeader The '
          'parameter "controllers" for ${widget.runtimeType} widget '
          'must not be null.');
    }
    var type = _getType<T>();
    var controllers = ctrls
        ?.where(
          (x) => x?.model?.runtimeType == type,
        )
        ?.toList();
    if (controllers == null || controllers.isEmpty) {
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
      var model = controllers
          .firstWhere(
            (x) => x.runtimeType == c,
          )
          .model;
      return model as T;
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
    var controller = ctrls?.firstWhere(
      (x) => x.runtimeType == type,
      orElse: () => null,
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

  void _updateModel<T>(
    int index,
    T newModel,
    MomentumController controller, [
    bool updateState = true,
  ]) {
    // Trigger rebuild with the new list of updated models.
    // _models[index] = newModel;
    if (updateState) {
      try {
        setState(_);
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        // ignore the setState error because
        // it is allowed to call "model.update(...)"
        // inside initState or when the widget tree is
        // not finish building yet.
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
  final List<MomentumService> services;
  final bool enableLogging;
  final int maxTimeTravelSteps;
  final bool lazy;
  final int minimumBootstrapTime;

  const _MomentumRoot({
    Key key,
    @required this.child,
    this.appLoader,
    @required this.controllers,
    @required this.services,
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
  bool _modelsInitialized = false;
  bool _rootStateInitialized = false;
  bool _controllersBootstrapped = false;
  bool _servicesInitialized = false;

  bool errorFound = false;

  bool get _canStartApp {
    // ignore: lines_longer_than_80_chars
    return _rootStateInitialized && _controllersBootstrapped && _modelsInitialized && _servicesInitialized;
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    if (!_rootStateInitialized) {
      _rootStateInitialized = true;
      _init();
    }
    super.didChangeDependencies();
  }

  Future<void> _init() async {
    await _initControllerModel(widget.controllers);
    _bootstrapControllers(widget.controllers);
    _bootstrapControllersAsync(widget.controllers);
    _initServices(widget.services);
  }

  Future<void> _initControllerModel(
    List<MomentumController> controllers,
  ) async {
    for (var controller in controllers) {
      if (controller != null) {
        controller._setMomentumRootContext = context;
        controller._configInternal(
          enableLogging: widget.enableLogging,
          maxTimeTravelSteps: widget.maxTimeTravelSteps,
          lazy: widget.lazy,
        );
        await controller._initializeMomentumController();
      }
    }
    setState(() {
      _modelsInitialized = true;
    });
  }

  void _initServices(List<MomentumService> services) async {
    var momentum = Momentum._getMomentumInstance(context);
    for (var service in services) {
      if (service != null) {
        if (service is Router) {
          service.setFunctions(
            context,
            momentum._persistSave,
            momentum._persistGet,
          );
          await service.init();
        }
      }
    }
    setState(() {
      _servicesInitialized = true;
    });
  }

  void _bootstrapControllers(List<MomentumController> controllers) {
    var lazyControllers = widget.controllers.where((e) {
      return e != null && !e._lazy;
    });
    for (var lazyController in lazyControllers) {
      if (lazyController != null) {
        lazyController._bootstrap();
      }
    }
  }

  void _bootstrapControllersAsync(List<MomentumController> controllers) async {
    var started = DateTime.now().millisecondsSinceEpoch;
    var nonLazyControllers = widget.controllers.where((e) {
      return e != null && !e._lazy;
    });
    var futures = nonLazyControllers.map<Future>((e) => e._bootstrapAsync());
    await Future.wait(futures);
    var finished = DateTime.now().millisecondsSinceEpoch;
    var diff = finished - started;
    var min = (widget.minimumBootstrapTime ?? 0).clamp(0, 9999999);
    var waitTime = (min - diff).clamp(0, min);
    await Future.delayed(Duration(milliseconds: waitTime));
    setState(() {
      _controllersBootstrapped = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var error = Momentum._getMomentumInstance(context)._validateControllers(
      widget.controllers,
    );
    if (!errorFound && error != null) {
      errorFound = true;
      throw MomentumError(error);
    }
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
    PersistSaver persistSave,
    PersistGet persistGet,
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
    PersistSaver persistSave,
    PersistGet persistGet,
  }) {
    return Momentum._internal(
      child: _MomentumRoot(
        child: child,
        appLoader: appLoader,
        controllers: controllers ?? [],
        services: services ?? [],
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

  final PersistSaver _persistSave;
  final PersistGet _persistGet;

  /// Method for testing only.
  T controllerForTest<T extends MomentumController>() {
    return _getController<T>(true);
  }

  /// Method for testing only.
  /// Get a controller using runtime type checker.
  /// The generic type param <T> is for type conversion.
  /// You don't need to do "controllerOfType(Foo) as Foo"
  T controllerOfType<T extends MomentumController>(Type type) {
    return _getControllerOfType<T>(type);
  }

  T _getController<T extends MomentumController>([bool isInternal = false]) {
    var type = _getType<T>();
    var controller = _controllers.firstWhere(
      (c) => c.runtimeType == type,
      orElse: () => null,
    );
    if (controller == null && !isInternal) {
      throw MomentumError('The controller of type "$T" doesn\'t exists '
          'or was not initialized from the "controllers" parameter '
          'in the Momentum constructor.');
    }
    return controller;
  }

  /// Method for testing only.
  T serviceForTest<T extends MomentumService>() {
    return _getService<T>();
  }

  T _getService<T extends MomentumService>() {
    var type = _getType<T>();
    var service = _services.firstWhere(
      (c) => c.runtimeType == type,
      orElse: () => null,
    );
    if (service == null) {
      throw MomentumError('The service class of type "$T" doesn\'t exists or '
          'was not initialized from the "services" parameter '
          'in the Momentum constructor.');
    }
    return service;
  }

  T _getControllerOfType<T extends MomentumController>([Type t]) {
    var controller = _controllers.firstWhere(
      (c) => c.runtimeType == t,
      orElse: () => null,
    );
    if (controller == null) {
      return null;
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
  ///
  /// **NOTE:** Please use `Momentum.controller<T>` for consistency.
  /// `Momentum.of<T>` will be deprecated in the future.
  static T of<T extends MomentumController>(BuildContext context) {
    return _getMomentumInstance(context)._getController<T>();
  }

  /// The static method for getting controllers inside widget.
  /// It uses deprecated method `inheritFromWidgetOfExactType`
  /// to support older versions of flutter.
  static T controller<T extends MomentumController>(BuildContext context) {
    return _getMomentumInstance(context)._getController<T>();
  }

  /// The static method for getting services inside a widget.
  /// The service must be marked with [MomentumService] and
  /// injected into [Momentum] root widget.
  ///
  /// **NOTE:** Please use `Momentum.service<T>` for consistency.
  /// `Momentum.getService<T>` will be deprecated in the future.
  static T getService<T extends MomentumService>(BuildContext context) {
    return _getMomentumInstance(context)._getService<T>();
  }

  /// The static method for getting services inside a widget.
  /// The service must be marked with [MomentumService] and
  /// injected into [Momentum] root widget.
  static T service<T extends MomentumService>(BuildContext context) {
    return _getMomentumInstance(context)._getService<T>();
  }

  static T _ofType<T extends MomentumController>(BuildContext context, Type t) {
    return _getMomentumInstance(context)._getControllerOfType<T>(t);
  }

  static T _ofInternal<T extends MomentumController>(BuildContext context) {
    return _getMomentumInstance(context)._getController<T>(true);
  }

  @protected
  @override
  bool updateShouldNotify(Momentum oldWidget) => false;
}
