import 'package:flutter/material.dart';

/// A selectable avatar color the player picks on the account screen. Persisted
/// by [id]; the tick shown over a chosen swatch uses [foreground].
enum ProfileColor {
  amber('amber', Color(0xFFFEAD2E), Color(0xFF2B2205)),
  sage('sage', Color(0xFF789283), Colors.white),
  clay('clay', Color(0xFFC0704A), Colors.white),
  plum('plum', Color(0xFF7C5B77), Colors.white),
  slate('slate', Color(0xFF5A6470), Colors.white);

  const ProfileColor(this.id, this.background, this.foreground);

  final String id;
  final Color background;
  final Color foreground;

  static ProfileColor fromId(String? id) =>
      values.firstWhere((c) => c.id == id, orElse: () => amber);
}
