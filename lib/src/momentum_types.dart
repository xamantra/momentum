import 'package:flutter/material.dart';

import 'momentum_base.dart';

/// [MomentumBuilder] takes up multiple [controllers] which also means multiple models. In order to access one of those models, this method is provided in the [builder] parameter so you can easily grab any model.
///
/// It is also required that you specify the type of the model that you want to grab using generic type parameter.
///
/// If you do this:
/// ```
/// builder: (context, snapshot) { return ProfileWidget(...); }
/// ```
/// notice the parameter named `snapshot`, that is actually just this method being passed in, which you can call to grab a model like this:
/// ```
/// builder: (context, snapshot) {
///   var employee = snapshot<EmployeeProfileModel>();
///   return ProfileWidget(username: employee.fullName);
/// }
/// ```
typedef MomentumSnapshot<T> = T Function<T extends MomentumModel>();

/// The build strategy used by this momentum builder. This is where you actually define your widget.
typedef MomentumBuilderFunction = Widget Function(BuildContext, MomentumSnapshot);

typedef ResetAll = void Function(BuildContext, void Function(BuildContext) resetAll);
