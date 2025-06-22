import 'package:flutter/material.dart';

const double standardBorderRadius = 12.0;

class ButtonStyles {
  static final ButtonStyle primary = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey;
      }
      return CustomColors.secondaryColor;
    }),
    foregroundColor: WidgetStatePropertyAll<Color>(Colors.white),
    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 16)),
  );

  static final ButtonStyle secondary = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
    foregroundColor: WidgetStatePropertyAll<Color>(Colors.black),
    side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
      if (states.contains(WidgetState.disabled)) {
        return BorderSide(color: Colors.grey.shade400);
      }
      return BorderSide(color: CustomColors.secondaryColor, width: 2);
    }),
    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    padding: WidgetStatePropertyAll<EdgeInsets>(
      EdgeInsets.symmetric(vertical: 16),
    ),
  );
}

class CustomColors {
  static const Color primaryColor = Color(0xFFfead2e);
  static const Color secondaryColor = Color(0xFF789283);
}

class TextStyles {
  static const TextStyle regularFont = TextStyle(
    fontSize: 18,
    color: Colors.black87,
  );

  static const TextStyle heading = TextStyle(fontSize: 26);

  static const TextStyle subheading = TextStyle(fontSize: 22);
  static const TextStyle large = TextStyle(fontSize: 17);
  static const TextStyle regular = TextStyle(fontSize: 14);
  static const TextStyle small = TextStyle(fontSize: 12);
}
