import 'package:flutter/material.dart';

class BrandRadius {
  /// Default button/input/card corners
  static const BorderRadius medium = BorderRadius.all(Radius.circular(8));

  /// Slightly softer corner (used in elevated cards or panels)
  static const BorderRadius large = BorderRadius.all(Radius.circular(12));

  /// Full rounded pill (used in badges, chips)
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));

  /// Circle radius (used for profile pictures etc.)
  static const BorderRadius circle = BorderRadius.all(Radius.circular(1000));
}
