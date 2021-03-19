import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'momentum_base.dart';
import 'momentum_event.dart';
import 'momentum_types.dart';

Type _getType<T>() => T;

/// A built-in momentum service for persistent navigation system.
class MomentumRouter extends MomentumService {
  /// Create an instance of [MomentumRouter]
  /// that can be injected to momentum
  /// as a service. Takes a list of
  /// widgets as routes.
  MomentumRouter(
    List<Widget> pages, {
    bool? enablePersistence,
  })  : _pages = pages,
        _enablePersistence = enablePersistence ?? true;
  final List<Widget> _pages;
  final bool _enablePersistence;
  RouterParam? _currentRouteParam;

  BuildContext? _rootContext;
  PersistSaver? _persistSaver;
  PersistGet? _persistGet;
  bool _exited = false;

  bool get _canPersist => _persistSaver != null && _persistGet != null;

  /// Returns `true` if the `.pop()` method is called while the router history is empty.
  ///
  /// Internally, this will be set to `true` when `SystemChannels.platform.invokeMethod('SystemNavigator.pop')` is called by `MomentumRouter`. It closes the app when there's no more previous route to show.
  bool get exited => _exited;

  MomentumEvent? _momentumEvent;

  // ignore: use_setters_to_change_properties
  /// For testing only.
  void mockParam(RouterParam param) {
    _currentRouteParam = param;
  }

  /// You don't have to call this method.
  /// This is automatically called by the
  /// library.
  void setFunctions(
    BuildContext context,
    PersistSaver? persistSaver,
    PersistGet? persistGet,
    MomentumEvent? momentumEvent,
  ) {
    _rootContext = context;
    _persistSaver = persistSaver;
    _persistGet = persistGet;
    _momentumEvent = momentumEvent;
  }

  List<int> _history = [];

  /// Indicates whether there are no more pages in the
  /// navigation history.
  bool get isRoutesEmpty => _history.isEmpty;

  Future<void> _goto(
    BuildContext context,
    Type? route, {
    Route Function(BuildContext, Widget)? transition,
    RouterParam? params,
  }) async {
    var findWidgetOfType = _pages.firstWhereOrNull(
      (e) => e.runtimeType == route,
    );
    if (findWidgetOfType != null) {
      var indexOfWidgetOfType = _pages.indexWhere(
        (e) => e.runtimeType == route,
      );
      _history.add(indexOfWidgetOfType);
      if (_canPersist && _enablePersistence) {
        _persistSaver!(
          _rootContext,
          'MOMENTUM_ROUTER_HISTORY',
          jsonEncode(_history),
        );
      }
      Route r;
      if (transition != null) {
        r = transition(context, findWidgetOfType);
      } else {
        r = MaterialPageRoute(builder: (_) => findWidgetOfType);
      }
      _currentRouteParam = params;
      _momentumEvent!.trigger(RouterSignal(_currentRouteParam));
      Navigator.pushAndRemoveUntil(context, r, (r) => false);
    } else {
      print('[$MomentumService -> $MomentumRouter]: Unable to '
          'find page widget of type "$route".');
    }
  }

  void _pop(
    BuildContext context, {
    Route Function(BuildContext, Widget)? transition,
    RouterParam? result,
  }) async {
    trycatch(() => _history.removeLast());
    if (_canPersist && _enablePersistence) {
      _persistSaver!(
        _rootContext,
        'MOMENTUM_ROUTER_HISTORY',
        jsonEncode(_history),
      );
    }
    if (_history.isEmpty) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      _exited = true;
    } else {
      var activePage = getActive();
      Route r;
      if (transition != null) {
        r = transition(context, activePage);
      } else {
        r = MaterialPageRoute(builder: (_) => activePage);
      }
      _currentRouteParam = result;
      _momentumEvent!.trigger(RouterSignal(_currentRouteParam));
      await Navigator.pushAndRemoveUntil(context, r, (r) => false);
    }
  }

  /// You don't have to call this method.
  /// This is automatically called by the
  /// library.
  Future<void> init() async {
    String? historyJson;
    historyJson = await tryasync(
      // ignore: unnecessary_cast
      (() => _persistGet!(_rootContext, 'MOMENTUM_ROUTER_HISTORY')
          as Future<String>) as Future<String> Function(),
      '[]',
    );
    var result = historyJson == null
        ? '[]'
        : trycatch(
            () => jsonDecode(historyJson!),
            '[]',
          );
    _history = (result as List).map<int>((e) => e as int).toList();
    if (_history.isEmpty) {
      _history.add(0);
    }
    return;
  }

  /// Get the active widget from the router.
  /// You may want this to be your initial
  /// widget when your app starts.
  Widget getActive() {
    var isHistoryEmpty = _history.isEmpty;
    var findWidgetByIndex = isHistoryEmpty ? _pages[0] : _pages[_history.last];
    return findWidgetByIndex;
  }

  /// Clear navigation history.
  Future<void> clearHistory() async {
    _history.clear();
    _history = [];
    if (_canPersist && _enablePersistence) {
      await _persistSaver!(
        _rootContext,
        'MOMENTUM_ROUTER_HISTORY',
        jsonEncode(_history),
      );
    }
  }

  /// Clear navigation history and set an initial page.
  Future<void> reset<T extends Widget>() async {
    var i = _pages.indexWhere((e) => e is T);
    _history = [i == -1 ? 0 : i];
    if (_canPersist && _enablePersistence) {
      await _persistSaver!(
        _rootContext,
        'MOMENTUM_ROUTER_HISTORY',
        jsonEncode(_history),
      );
    }
  }

  /// The function to navigate to a specific
  /// route. You specify the route using a type
  /// NOT a string route name or a [MaterialPageRoute].
  static void goto(
    BuildContext context,
    Type? route, {
    Route Function(BuildContext, Widget)? transition,
    RouterParam? params,
  }) {
    var service = Momentum.service<MomentumRouter>(context);
    service._goto(
      context,
      route,
      transition: transition,
      params: params,
    );
  }

  /// Works like [Navigation.pop].
  static void pop(
    BuildContext context, {
    Route Function(BuildContext, Widget)? transition,
    RouterParam? result,
  }) {
    var service = Momentum.service<MomentumRouter>(context);
    var routeResult = service._pop(
      context,
      transition: transition,
      result: result,
    );
    return routeResult;
  }

  /// Get the current route param without using context.
  T? getCurrentParam<T extends RouterParam?>() {
    if (_currentRouteParam.runtimeType == _getType<T>()) {
      return _currentRouteParam as T?;
    }
    print(
        'getParam<$T>() ---> Invalid type: The active/current route param is of type "${_currentRouteParam.runtimeType}" while the parameter you want to access is of type "$T". Momentum will return a null instead.');
    return null;
  }

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
  static T? getParam<T extends RouterParam>(BuildContext context) {
    var service = Momentum.service<MomentumRouter>(context);
    var result = service.getCurrentParam<T>();
    return result;
  }

  /// Get the active widget from the router.
  /// You may want this to be your initial
  /// widget when your app starts.
  static Widget getActivePage(BuildContext context) {
    var service = Momentum.service<MomentumRouter>(context);
    var page = service.getActive();
    return page;
  }

  /// Clear navigation history using context.
  static Future<void> clearHistoryWithContext(BuildContext context) async {
    var service = Momentum.service<MomentumRouter>(context);
    await service.clearHistory();
  }

  /// Clear navigation history using context and set an initial page.
  static Future<void> resetWithContext<T extends Widget>(
    BuildContext context,
  ) async {
    var service = Momentum.service<MomentumRouter>(context);
    await service.reset<T>();
  }
}

/// Wrap your screen widget with this
/// to properly implement popping
/// with system back button.
class RouterPage extends StatelessWidget {
  /// This is mostly the screen widget or
  /// a page type widget like Scaffold.
  final Widget child;

  /// Just like [WillPopScope], you can
  /// also override the popping behavior
  /// for system back button.
  final Future<bool> Function()? onWillPop;

  /// Wrap your screen widget with this
  /// to properly implement popping
  /// with system back button.
  const RouterPage({
    Key? key,
    required this.child,
    this.onWillPop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop ??
          () async {
            MomentumRouter.pop(context);
            return false;
          },
      child: child,
    );
  }
}

/// An abstract class required for marking a certain
/// data class as a router param model.
@immutable
abstract class RouterParam {}

/// An class used by momentum for notifying RouterMixin
/// of any router parameter changes.
class RouterSignal {
  /// The parameter that is provided while navigating to pages.
  final RouterParam? param;

  /// An class used by momentum for notifying RouterMixin
  /// of any router parameter changes.
  const RouterSignal(this.param);
}
