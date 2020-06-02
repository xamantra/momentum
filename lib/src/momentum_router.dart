import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'momentum_base.dart';
import 'momentum_types.dart';

// ignore: constant_identifier_names
const _MOMENTUM_ROUTER_HISTORY = 'MOMENTUM_ROUTER_HISTORY';

/// A built-in momentum service for persistent navigation system.
class Router extends MomentumService {
  /// Create an instance of [Router]
  /// that can be injected to momentum
  /// as a service. Takes a list of
  /// widgets as routes.
  Router(List<Widget> pages) : _pages = pages;
  final List<Widget> _pages;

  BuildContext _rootContext;
  PersistSaver _persistSaver;
  PersistGet _persistGet;

  /// You don't have to call this method.
  /// This is automatically called by the
  /// library.
  void setFunctions(
    BuildContext context,
    PersistSaver persistSaver,
    PersistGet persistGet,
  ) {
    _rootContext = context;
    _persistSaver = persistSaver;
    _persistGet = persistGet;
  }

  List<int> _history = [];

  Future<void> _goto(
    BuildContext context,
    Type route, {
    Route Function(BuildContext, Widget) transition,
  }) async {
    var findWidgetOfType = _pages.firstWhere(
      (e) => e.runtimeType == route,
      orElse: () => null,
    );
    if (findWidgetOfType != null) {
      var indexOfWidgetOfType = _pages.indexWhere(
        (e) => e.runtimeType == route,
      );
      _history.add(indexOfWidgetOfType);
      _persistSaver(
        _rootContext,
        _MOMENTUM_ROUTER_HISTORY,
        jsonEncode(_history),
      );
      if (_history.isEmpty) {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      } else {
        Route r;
        if (transition != null) {
          r = transition(context, findWidgetOfType);
        } else {
          r = MaterialPageRoute(builder: (_) => findWidgetOfType);
        }
        await Navigator.pushAndRemoveUntil(context, r, (r) => false);
      }
    } else {
      print('[$MomentumService -> $Router]: Unable to '
          'find page widget of type "$route".');
    }
  }

  void _pop(
    BuildContext context, {
    Route Function(BuildContext, Widget) transition,
  }) async {
    trycatch(() => _history.removeLast());
    _persistSaver(
      _rootContext,
      _MOMENTUM_ROUTER_HISTORY,
      jsonEncode(_history),
    );
    if (_history.isEmpty) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    } else {
      var activePage = _getActivePage();
      Route r;
      if (transition != null) {
        r = transition(context, activePage);
      } else {
        r = MaterialPageRoute(builder: (_) => activePage);
      }
      await Navigator.pushAndRemoveUntil(context, r, (r) => false);
    }
  }

  /// You don't have to call this method.
  /// This is automatically called by the
  /// library.
  Future<void> init() async {
    var historyJson = await tryasync(
      () => _persistGet(_rootContext, _MOMENTUM_ROUTER_HISTORY),
      '[]',
    );
    var result = jsonDecode(historyJson);
    _history = (result as List).map<int>((e) => e as int).toList();
    if (_history.isEmpty) {
      _history.add(0);
    }
    return;
  }

  Widget _getActivePage() {
    var isHistoryEmpty = _history.isEmpty;
    var findWidgetByIndex = isHistoryEmpty ? _pages[0] : _pages[_history.last];
    return findWidgetByIndex;
  }

  /// Clear navigation history.
  Future<void> clearHistory() async {
    _history.clear();
    _history = [];
    await _persistSaver(
      _rootContext,
      _MOMENTUM_ROUTER_HISTORY,
      jsonEncode(_history),
    );
  }

  /// Clear navigation history and set an initial page.
  void reset<T extends Widget>() async {
    var i = _pages.indexWhere((e) => e is T);
    _history = [i == -1 ? 0 : i];
    await _persistSaver(
      _rootContext,
      _MOMENTUM_ROUTER_HISTORY,
      jsonEncode(_history),
    );
  }

  /// The function to navigate to a specific
  /// route. You specify the route using a type
  /// NOT a string route name or a [MaterialPageRoute].
  static Future<void> goto(
    BuildContext context,
    Type route, {
    Route Function(BuildContext, Widget) transition,
  }) async {
    var service = Momentum.getService<Router>(context);
    await service._goto(
      context,
      route,
      transition: transition,
    );
  }

  /// Works like [Navigation.pop].
  static void pop<T extends Object>(
    BuildContext context, {
    Route Function(BuildContext, Widget) transition,
  }) {
    var service = Momentum.getService<Router>(context);
    var routeResult = service._pop(context, transition: transition);
    return routeResult;
  }

  /// Get the active widget from the router.
  /// You may want this to be your initial
  /// widget when your app starts.
  static Widget getActivePage(BuildContext context) {
    var service = Momentum.getService<Router>(context);
    var page = service._getActivePage();
    return page;
  }

  /// Clear navigation history using context.
  static Future<void> clearHistoryWithContext(BuildContext context) async {
    var service = Momentum.getService<Router>(context);
    await service.clearHistory();
  }

  /// Clear navigation history using context and set an initial page.
  static Future<void> resetWithContext<T extends Widget>(
    BuildContext context,
  ) async {
    var service = Momentum.getService<Router>(context);
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
  /// also override the popping behaviour
  /// for system back button.
  final Future<bool> Function() onWillPop;

  /// Wrap your screen widget with this
  /// to properly implement popping
  /// with system back button.
  const RouterPage({
    Key key,
    @required this.child,
    this.onWillPop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop ??
          () async {
            Router.pop(context);
            return false;
          },
      child: child,
    );
  }
}
