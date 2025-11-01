// core/theme/theme_extensions.dart
import 'package:flutter/material.dart';

class MyColors extends ThemeExtension<MyColors> {
  final Color brand;
  final Color accent;

  const MyColors({required this.brand, required this.accent});

  @override
  MyColors copyWith({Color? brand, Color? accent}) {
    return MyColors(
      brand: brand ?? this.brand,
      accent: accent ?? this.accent,
    );
  }

  @override
  MyColors lerp(ThemeExtension<MyColors>? other, double t) {
    if (other is! MyColors) {
      return this;
    }
    return MyColors(
      brand: Color.lerp(brand, other.brand, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}
