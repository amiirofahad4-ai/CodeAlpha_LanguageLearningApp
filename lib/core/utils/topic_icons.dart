import 'package:flutter/material.dart';

/// Maps icon names stored in data (e.g. Firestore) to Material icons.
///
/// Storing a string instead of [IconData] keeps the models serialisable.
abstract final class TopicIcons {
  static const _icons = <String, IconData>{
    'family': Icons.family_restroom_rounded,
    'food': Icons.restaurant_rounded,
    'travel': Icons.flight_takeoff_rounded,
    'numbers': Icons.pin_rounded,
    'colors': Icons.palette_rounded,
    'greetings': Icons.waving_hand_rounded,
  };

  static IconData of(String name) => _icons[name] ?? Icons.menu_book_rounded;
}
