import 'package:flutter/material.dart';

import 'tokens.dart';

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
        borderRadius: BorderRadius.all(Radius.circular(standardBorderRadius)),
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
        borderRadius: BorderRadius.all(Radius.circular(standardBorderRadius)),
      ),
    ),
    padding: WidgetStatePropertyAll<EdgeInsets>(
      EdgeInsets.symmetric(vertical: 16),
    ),
  );
}
