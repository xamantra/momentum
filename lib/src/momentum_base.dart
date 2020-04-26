import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'momentum_types.dart';

/// This class is used internally for notifying the [MomentumBuilder] for model updates and performing rebuilds.
///
/// The parameter [_state] is used internally by [MomentumController] to remove all listeners whose [State] is no longer mounted in the tree.
///
/// The parameter [_invoke] is a function that is used internally by [MomentumBuilder] to notify rebuilds.
@sealed
class _MomentumListener<M> {
  /// This property is normally an instance of [_MomentumBuilderState] which is used to check if this listener is valid or not using [State.mounted] property. If the state is no longer mounted in the tree then this listener will be deleted from the list in the [MomentumController].
  final MomentumState state;

  /// This function will be called to notify that a model has been updated.
  final void Function(M, bool) invoke;

  _MomentumListener({@required this.state, @required this.invoke});
}

/// The base class for `model` that is attached to a controller. [MomentumModel] and [MomentumController] depends on each other.
///
/// This base class is also immutable which means the implementation must also be immutable. All fields must be `final`.
@immutable
abstract class MomentumModel<Controller extends MomentumController> {
  /// The controller that this model is attached to. Which is used for notifying [MomentumBuilder] for rebuilds.
  @protected
  final Controller controller;
  const MomentumModel(this.controller);

  String get controllerName => '$Controller';

  /// If implemented correctly, calling this method will notify the [controller] for updates.
  @required
  void update();

  /// The actual method that notifies the [controller] for updates.
  ///
  /// NOTE: You are NOT supposed to call this method anywhere except inside the implementation of your [update] method only.
  @protected
  void updateMomentum() {
    controller._setMomentum(this);
  }
}

/// The base class for `controller` that is attached to a model. [MomentumModel] and [MomentumController] depends on each other.
///
/// You can also optionally call [enableLogging] to enable informative logging on the console or [disableLogging] to disabled it. The logging is enabled by default. Uncaught `exceptions` doesn't get affected by these methods though.
abstract class MomentumController<M> {
  /// The [BuildContext] for [_MomentumRoot] stateful widget that is used internally by [Momentum] root widget.
  ///
  /// The context will be used in the method "dependOn<T>()" when grabbing an instance of another controller inside this controller.
  BuildContext _momentumRootContext;

  /// The method that is internally called by [_MomentumRoot] to set this controller's root context. The [_momentumRootContext] will be used to grab other controllers instantiated in the [Momentum] inside this controller.
  void _setMomentumRootContext(BuildContext context) {
    _momentumRootContext = context;
  }

  /// Get an instance of a controller of type [T]. Useful if you want to access other controllers and manipulate their models.
  ///
  /// This uses the method [Momentum.of] behind the scenes which the `context` is provided internally by [_MomentumRoot].
  @nonVirtual
  @protected
  T dependOn<T extends MomentumController>() {
    if (this is T) {
      throw Exception(_formatMomentumLog('[$this]: called "dependOn<$T>()" on itself, you\'re not allowed to do that.'));
    }
    var result = Momentum._ofInternal<T>(_momentumRootContext);
    if (result == null) {
      throw Exception(_formatMomentumLog('[$this]: called "dependOn<$T>()", but no controller of type [$T] had been found.\nTry checking your "Momentum" root widget implementation if the controller "$T" was instantiated there.'));
    }
    return result;
  }

  bool _booted = false;

  /// Called only once. If `lazy` is *true* this will be called when this controller gets loaded by a [MomentumBuilder]. If `lazy` is *false* this will be called when the application starts.
  void bootstrap() {}
  void _bootstrap() {
    if (!_booted) {
      _booted = true;
      bootstrap();
    }
  }

  /// List of [_MomentumListener]s that are currently listening to this controller. All listeners that [State] are no longer mounted on the tree will be removed with [_cleanupListeners] automatically.
  List<_MomentumListener> _momentumListeners = [];
  List<_MomentumListener<M>> _externalMomentumListeners = [];

  /// The variable for the latest value of your [MomentumModel] set by [MomentumModel.update]. This gets updated when you call [MomentumModel.update]. You can use the getter [model] to grab the value of this aside from [MomentumBuilder]'s builder function.
  M _currentActiveModel;

  /// The getter for the current active snapshot of your [MomentumModel] which returns [_currentActiveModel]. You can also call this directly inside your controller class.
  M get model => _currentActiveModel;

  /// Use to store all the model states for time travel methods.
  List<M> _momentumModelHistory;

  /// Use for time travel. If the time travel methods reaches this model it means that it's the very first model and can't go back anymore.
  M _initialMomentumModel;

  /// Use for time travel. If the time travel methods reaches this model it means that it's the very last model and can't go forward anymore.
  M _latestMomentumModel;

  /// Used to check if this controller is already initialized or not to guarantee that the [_initializeMomentumController] method body will only be executed once.
  bool _momentumControllerInitialized = false;

  /// The method that initializes the controller which is called automatically by the library.
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
        print(_formatMomentumLog('[$this] has been initialized. {maxTimeTravelSteps: $_maxTimeTravelSteps}'));
      }
    }
    return model;
  }

  /// Must return an instance of [MomentumModel] containing your desired initial values. This will also be called by the [reset] method when you want to rollback your model to its initial state.
  @protected
  @required
  M init();

  /// Check if the implementation of the method [init] is valid. Throws an exception if it is not.
  void _checkInitImplementation() {
    var initValue = init();
    if (initValue == null) {
      throw Exception(_formatMomentumLog('[$this]: your "init()" method implementation returns NULL, please return a valid instance of "$M"'));
    }
    if (!(initValue is M)) {
      throw Exception(_formatMomentumLog('[$this]: your "init()" method implementation does not return an instance of type "$M", please return a valid instance of "$M".'));
    }
    if ((initValue as MomentumModel).controller == null) {
      var name = '$this'.replaceAll('Instance of', '');
      throw Exception(_formatMomentumLog('[$this]: your "init()" method implementation returns an instance of "$M" but the "controller" property is null, please pass in a non-null value to it. But since "$M" is attached to $name and vice versa. You can just pass in this controller\'s instance like this:\n\nreturn $M(\n    this,\n    ...\n);'));
    }
    initValue = null;
    return;
  }

  /// This method calls all the active [_MomentumListener]s that is currently listening to this controller. This is automatically called by the library.
  void _setMomentum(M model, {bool backward = false, bool forward = false, bool timeTraveled = false}) {
    var isTimeTravel = backward || forward;
    if (isTimeTravel) {
      _currentActiveModel = _momentumModelHistory.last;
    } else {
      if (_momentumModelHistory.length == _maxTimeTravelSteps) {
        _momentumModelHistory.removeAt(0);
        _initialMomentumModel = _momentumModelHistory.length > 0 ? _momentumModelHistory[0] : model;
      }
      _currentActiveModel = model;
      _latestMomentumModel = _currentActiveModel;
      _momentumModelHistory.add(_currentActiveModel);
    }
    _cleanupListeners();
    for (var listener in _momentumListeners) {
      if (listener.state.mounted && !listener.state.deactivated) {
        listener.invoke(_currentActiveModel, isTimeTravel);
      }
    }
    for (var externalListener in _externalMomentumListeners) {
      if (externalListener.state.mounted && !externalListener.state.deactivated) {
        externalListener.invoke(_currentActiveModel, isTimeTravel);
      }
    }
    if (_momentumLogging) {
      var inActiveListeners = _momentumListeners.where((l) => l.state.deactivated);
      var activeListeners = _momentumListeners.length - inActiveListeners.length;
      print(_formatMomentumLog('[$this] the model "$M" has been updated, listeners => ACTIVE: $activeListeners (notified), INACTIVE: ${inActiveListeners.length} (ignored)'));
    }
  }

  /// Time travel method. Undo changes to the model (1 step backward).
  void backward() {
    if (_currentActiveModel != _initialMomentumModel) {
      var latestModel = _momentumModelHistory.last;
      _momentumModelHistory.removeWhere((x) => x == latestModel);
      _momentumModelHistory.insert(0, latestModel);
      _setMomentum(null, backward: true);
    }
  }

  /// Time travel method. Redo changes to the model (1 step forward).
  void forward() {
    if (_latestMomentumModel != null && _currentActiveModel != _latestMomentumModel) {
      var firstModel = _momentumModelHistory.first;
      _momentumModelHistory.removeWhere((x) => x == firstModel);
      _momentumModelHistory.add(firstModel);
      _setMomentum(null, forward: true);
    }
  }

  /// Add a new instance of [_MomentumListener] to this controller. Whenever the model is updated, [_MomentumListener._invoke] will be called. This is what [MomentumBuilder] uses internally to trigger rebuild.
  void _addListenerInternal(_MomentumListener _momentumListener) {
    _momentumListeners.add(_momentumListener);
  }

  /// Add a new listener to this controller. Whenever the model is updated, [invoke] will be called. This is what [MomentumBuilder] uses internally to trigger rebuild.
  void addListener({@required MomentumState state, void Function(M, bool) invoke}) {
    _externalMomentumListeners.add(_MomentumListener<M>(
      state: state,
      invoke: invoke,
    ));
  }

  /// Remove all listeners where [State] is no longer mounted in the tree.
  ///
  /// This is a private and protected method, the library will call this for you behind the scenes.
  ///
  /// `Note from flutter`: The [State] object remains mounted until the framework calls [State.dispose].
  void _cleanupListeners() {
    _momentumListeners.removeWhere((x) => !x.state.mounted);
    _externalMomentumListeners.removeWhere((x) => !x.state.mounted);
  }

  /// Reset the model to its initial state.
  ///
  /// The initial state is defined in your [init] implementation.
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
  bool get isLazy => _lazy;
  bool _configMethodCalled = false;

  /// Configuration method for controllers.
  ///
  /// `enableLogging` - Enable/Disable the logging for this controller. Uncaught `exceptions` are not affected by this setting. Defaults to *true*.
  ///
  /// `maxTimeTravelSteps` - The maximum number of steps the time travel methods [MomentumController.backward] and [MomentumController.forward] can take. Defaults to `1` (means disabled). Clamped between `1` - `250`.
  ///
  /// `lazy` - This specifies if the [bootstrap] method will be lazily called or not. If `true`, the bootstrap method will be called only the first time this controller gets loaded by a [MomentumBuilder]. If `false` the bootstrap method will be called right when the application starts. Defaults to *true*.
  void config({bool enableLogging, int maxTimeTravelSteps, bool lazy}) {
    if (!_configMethodCalled) {
      _configMethodCalled = true;
      _momentumLogging = enableLogging;
      _maxTimeTravelSteps = maxTimeTravelSteps?.clamp(1, 250);
      _lazy = lazy;
    }
  }

  void _configInternal({bool enableLogging, int maxTimeTravelSteps, bool lazy}) {
    _momentumLogging ??= enableLogging ?? true;
    _maxTimeTravelSteps ??= (maxTimeTravelSteps ?? 1).clamp(1, 250);
    _lazy ??= lazy ?? true;
  }

  /// Format the log to print "Momentum -> " instead of "Instance of ".
  String _formatMomentumLog(String log) {
    return log.replaceAll('Instance of ', 'Momentum -> ');
  }
}

/// An abstract class that extends [State] that adds the [deactivated] property that indicates the visibility state of your widget.
///
/// [_MomentumBuilderState] also extends this base class to be used internally by [_MomentumListener] which helps to filter listeners whose [State] is currently deactivated.
abstract class MomentumState<T extends StatefulWidget> extends State<T> {
  /// A variable that stores the visibility state of this [State]. This will be set to `true` when [deactivate] is called by the framework.
  bool _stateDeactivated = false;

  /// Returns `true` if this [State]'s [deactivate] method has been called. Will be `false` if [reassemble] is called.
  ///
  /// Commonly, the method [deactivate] is called when your widget is not the active view in the navigation stack. If you call [Navigator.push] for example, [deactivate] will be called. Calling [Navigator.pop] will call [dispose] instead of [deactivate].
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
  didUpdateWidget(Widget oldWidget) {
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

  /// Initialize your momentum state. This is called after [initState] before [build].
  ///
  /// You can call any *context* related methods and variables here.
  @protected
  void initMomentumState() {}
}

@sealed
class MomentumBuilder extends StatefulWidget {
  /// Optional parameter. Only used for more accurate logging on the console. If you ever encountered an error by using [MomentumBuilder] try to specify this parameter so you can easily track where is the error originating from.
  ///
  /// You can specify this by:
  /// ```
  /// ...
  /// owner: widget // if you are in a [State] with [StatefulWidget].
  /// // or
  /// owner: this // if you are in a [Stateless] widget.
  /// ...
  /// ```
  final Widget owner;

  /// Inject all the controllers that you want to depend on for your [builder].
  @protected
  final List<Type> controllers;

  /// The build strategy used by this momentum builder. This is where you actually define your widget.
  @protected
  final MomentumBuilderFunction builder;

  // Optionally configure this builder if time travel should trigger rebuild or not.
  final bool ignoreTimeTravel;

  /// Creates a new [MomentumBuilder] that builds itself based on the latest snapshot of interaction with the injected [controllers] and whose build strategy is given by [builder].
  ///
  /// The parameter [controllers] and [builder] must not be null.
  const MomentumBuilder({
    Key key,
    this.owner,
    @required this.controllers,
    @required this.builder,
    this.ignoreTimeTravel,
  }) : super(key: key);

  @protected
  @override
  _MomentumBuilderState createState() => _MomentumBuilderState();
}

@sealed
class _MomentumBuilderState extends MomentumState<MomentumBuilder> {
  List<MomentumController> ctrls;

  /// The list of models that are attached to the [controllers]. If at least one of them gets updated, a rebuild will be triggered with the new models updated.
  var _models = <dynamic>[];

  /// If the parameter [owner] isn't null, all logs printed by this class will look like this: "[Momentum > WidgetName > MomentumBuilder]: {message}".
  String get _logHeader => widget.owner == null ? '[$Momentum > $MomentumBuilder]:' : '[$Momentum > ${widget.owner.runtimeType} > $MomentumBuilder]:';

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
    if (widget.builder == null) throw Exception('$_logHeader The parameter "builder" for ${widget.runtimeType} widget must not be null.');
    return widget.builder(context, _useMomentumModelOfType);
  }

  /// This method is used internally to process all the [controllers] to support multiple models in the [builder] function.
  ///
  /// It loops through all the [controllers] -> add a [_MomentumListener] to it -> then group the updated models into a private [List] variable -> then finally trigger a rebuild with the updated models .
  ///
  /// This method is called in [initState].
  void _init() {
    ctrls = <MomentumController>[];
    var ignoreTimeTravel = widget.ignoreTimeTravel ?? false;
    for (var t in (widget.controllers ?? <Type>[])) {
      var c = Momentum._ofType(context, t);
      if (c != null) {
        ctrls.add(c);
      } else {
        if (!(t is MomentumController)) {
          throw Exception('$_logHeader Attempted to inject "$t" as a controller failed because it\'s not a valid MomentumController. You can only inject a type that extend MomentumController');
        }
        throw Exception('$_logHeader The controller of type "$t" is not initialized in the Momentum root widget.\nPossible solutions:\n\tCheck if you initialized the controller attached to this model on the Momentum root widget.');
      }
    }
    if (ctrls.isNotEmpty) {
      _models.addAll(ctrls.map((_) => null));
      for (int i = 0; i < ctrls.length; i++) {
        if (ctrls[i]._lazy) ctrls[i]._bootstrap();
        _updateModel(i, ctrls[i]?.model, ctrls[i], false);
        ctrls[i]?._addListenerInternal(
          _MomentumListener(
            state: this,
            invoke: (data, isTimeTravel) {
              if (ignoreTimeTravel && isTimeTravel) return;
              if (mounted) {
                _updateModel(i, data, ctrls[i]);
              }
            },
          ),
        );
      }
    }
    return;
  }

  /// This method is where the magic happens.
  ///
  /// The [MomentumBuilder] takes a function parameter called `builder`. This function also takes a function parameter which passes this method.
  ///
  /// [MomentumBuilder] takes up multiple [controllers] which also means multiple models. In order to access one of those models, this method is provided in the [builder] parameter so you can easily grab any model.
  ///
  /// It is also required that you specify the type of the model that you want to grab using generic type parameter.
  ///
  /// If you do this:
  /// ```
  /// builder: (use) { return ProfileWidget(...); }
  /// ```
  /// notice the parameter named `use`, that is actually just this method being passed in, which you can call to grab a model like this:
  /// ```
  /// builder: (use) {
  ///   var employee = use<EmployeeProfileModel>();
  ///   return ProfileWidget(username: employee.fullName);
  /// }
  /// ```
  T _useMomentumModelOfType<T extends MomentumModel>() {
    if (widget.controllers == null) throw Exception('$_logHeader The parameter "controllers" for ${widget.runtimeType} widget must not be null.');
    var controller = ctrls?.firstWhere((x) => x?.model is T, orElse: () => null);
    if (controller == null) throw Exception('$_logHeader The controller for the model of type "$T" is either not injected in this ${widget.runtimeType} or not initialized in the Momentum root widget or can be both.\nPossible solutions:\n\t1. Check if you initialized the controller attached to this model on the Momentum root widget.\n\t2. Check the controller attached to this model if it is injected into this ${widget.runtimeType}');
    var model = _models.firstWhere((c) => c is T, orElse: () => null);
    if (model == null) throw Exception(controller._formatMomentumLog('$_logHeader An attempt to grab an instance of "$T" failed inside ${widget.runtimeType}\'s "builder" function.'));

    return model as T;
  }

  /// When any of the [controllers]'s associated model is updated, [MomentumBuilder] will trigger a rebuild with the updated models.
  void _updateModel<T>(int index, T newModel, MomentumController controller, [bool updateState = true]) {
    // Trigger rebuild with the new list of updated models.
    _models[index] = newModel;
    if (updateState) {
      try {
        setState(_);

        /// The reason why I wrapped this with try-catch is:
        /// First, MomentumModel.update notify MomentumBuilder/s.
        /// Second, When MomentumBuilder is notified of changes, this method will be called which is calling setState.
        /// Third, In short calling MomentumModel.update basically calls setState too.
        /// Lastly, There are some of places where setState cannot be called.
      } catch (e) {
        print('[$Momentum] -> $_updateModel: $e');
        if (controller._momentumLogging) {
          print(StackTrace.current);
        }
      }
    }
  }

  _() {}
}

/// A stateful widget internally used by [Momentum] for dependency injection with controllers.
@sealed
class _MomentumRoot extends StatefulWidget {
  final Widget child;
  final List<MomentumController> controllers;
  final bool enableLogging;
  final int maxTimeTravelSteps;
  final bool lazy;

  const _MomentumRoot({
    Key key,
    @required this.child,
    @required this.controllers,
    this.enableLogging,
    this.maxTimeTravelSteps,
    this.lazy,
  }) : super(key: key);
  @override
  _MomentumRootState createState() => _MomentumRootState();
}

/// The [State] class attached to [_MomentumRoot] that actually set each [controllers]'s root context to this widget's [BuildContext]. Later the [MomentumController] can now call [Momentum.of] inside [MomentumController.dependOn]'s method without the developer worrying about passing the context around. Everything is provided.
@sealed
class _MomentumRootState extends State<_MomentumRoot> {
  bool _momentumRootStateInitialized = false;

  @override
  @mustCallSuper
  void didChangeDependencies() {
    if (!_momentumRootStateInitialized) {
      _momentumRootStateInitialized = true;
      for (var controller in widget.controllers) {
        controller
          .._setMomentumRootContext(context)
          .._configInternal(
            enableLogging: widget.enableLogging,
            maxTimeTravelSteps: widget.maxTimeTravelSteps,
            lazy: widget.lazy,
          )
          .._initializeMomentumController();
        if (!controller._lazy) controller._bootstrap();
      }
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var error = Momentum._getMomentumInstance(context)._validateControllers(widget.controllers);
    if (error != null) throw Exception(error);
    return widget.child;
  }
}

@sealed
class Momentum extends InheritedWidget {
  const Momentum._internal({Key key, @required Widget child, List<MomentumController> controllers, void Function(BuildContext) onResetAll})
      : this._controllers = controllers ?? const [],
        this._onResetAll = onResetAll,
        super(key: key, child: child);

  /// Momentum's root widget that efficiently propagate list of [MomentumController]s down the tree.
  ///
  /// To obtain specific [MomentumController] of a particular type from any build context, use [Momentum.of]. For example:
  /// ```
  /// var employeeController = Momentum.of<EmployeeController>(context);
  /// // you can then pass this in your MomentumBuilder like this:
  /// MomentumBuilder(
  ///   controllers: [employeeController], // it is good practice to declare your controllers on top instead of calling "Momentum.of" everywhere.
  ///   builder: ...
  ///   ...
  /// );
  /// ```
  ///
  /// It is important to set this widget as your app's root widget or main entry point.
  ///
  /// **Parameters**
  ///
  /// `maxTimeTravelSteps` - The maximum number of steps the time travel methods [backward] and [forward] can take.
  ///  Defaults to `50`. Clamped between `1` - `250`.
  factory Momentum({
    @required Widget child,
    @required List<MomentumController> controllers,
    void Function(BuildContext) onResetAll,
    bool enableLogging,
    int maxTimeTravelSteps,
    bool lazy,
  }) {
    return Momentum._internal(
      child: _MomentumRoot(
        child: child,
        controllers: controllers,
        enableLogging: enableLogging,
        maxTimeTravelSteps: maxTimeTravelSteps,
        lazy: lazy,
      ),
      controllers: controllers,
      onResetAll: onResetAll,
    );
  }

  /// Validate all controllers, check for null or duplicate values then throw an error if any is found.
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
        return '[$Momentum] -> A null value has been passed in controllers parameter of Momentum root widget.\n\nControllers config:\n\n$passedIn';
      }
      var count = controllers.where((x) => x.runtimeType == controller.runtimeType).length; // filter controllers (remove duplicates).
      if (count > 1) {
        return '[$Momentum] -> Duplicate controller of type "${controller.runtimeType}" is found. You passed in "$count" instance of "${controller.runtimeType}".\n\nControllers config:\n\n$passedIn';
      }
    }
    return null;
  }

  /// The list of controllers that was initialized in this [Momentum] instance.
  final List<MomentumController> _controllers;

  /// The custom callback function for [Momentum.resetAll] method.
  final void Function(BuildContext) _onResetAll;

  /// Used internally in the [Momentum.of] method to grab a controller that is initialized in the `controllers` parameter.
  T _getController<T extends MomentumController>([bool isInternal = false]) {
    var controller = _controllers.firstWhere((c) => c is T, orElse: () => null);
    if (controller == null && !isInternal) {
      throw Exception('The controller of type "$T" doesn\'t exists or was not initialized from the "controllers" parameter in the Momentum constructor.');
    }
    return controller;
  }

  /// Used internally in the [Momentum.of] method to grab a controller that is initialized in the `controllers` parameter.
  T _getControllerOfType<T extends MomentumController>([Type t, bool isInternal = false]) {
    var controller = _controllers.firstWhere((c) => c.runtimeType == t, orElse: () => null);
    if (controller == null && !isInternal) {
      throw Exception('The controller of type "$T" doesn\'t exists or was not initialized from the "controllers" parameter in the Momentum constructor.');
    }
    return controller as T;
  }

  static Momentum _getMomentumInstance(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(Momentum) as Momentum);
  }

  /// Reset all controllers. Optionally you can override this function using [Momentum]'s `onResetAll` parameter. If the parameter is not specified.
  static void resetAll<T extends MomentumController>(BuildContext context) {
    var m = _getMomentumInstance(context);
    if (m._onResetAll != null) {
      m._onResetAll(context);
    } else {
      for (var controller in m._controllers) {
        controller?.reset();
      }
    }
  }

  /// Grab a specific [MomentumController] of a particular type from any build context.
  static T of<T extends MomentumController>(BuildContext context) => _getMomentumInstance(context)._getController<T>();

  /// (internal) Grab a specific [MomentumController] of a particular type from any build context.
  static T _ofType<T extends MomentumController>(BuildContext context, Type t) => _getMomentumInstance(context)._getControllerOfType<T>(t, true);

  /// (internal) Grab a specific [MomentumController] of a particular type from any build context.
  static T _ofInternal<T extends MomentumController>(BuildContext context) => _getMomentumInstance(context)._getController<T>(true);

  @protected
  @override
  bool updateShouldNotify(Momentum oldWidget) => true;
}
