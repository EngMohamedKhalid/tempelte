import 'package:flutter/material.dart';

class AppShadow {
  static List<BoxShadow> primary = [
    BoxShadow(
      blurRadius: 2,
      spreadRadius: 0.0,
      offset: const Offset(0.0, 1.0),
      color: const Color(0xff101828).withValues(alpha: .5),
    ),
  ];

  /// Cards, inputs, primary button — `0 1 2 rgba(5,15,36,.06)`.
  static const List<BoxShadow> sm = <BoxShadow>[
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      color: Color.fromRGBO(5, 15, 36, 0.06),
    ),
  ];

  /// Raised cards, dropdowns, toasts — `0 20 40 -20 rgba(5,15,36,.20)`.
  static const List<BoxShadow> lg = <BoxShadow>[
    BoxShadow(
      offset: Offset(0, 20),
      blurRadius: 40,
      spreadRadius: -20,
      color: Color.fromRGBO(5, 15, 36, 0.20),
    ),
  ];
}
