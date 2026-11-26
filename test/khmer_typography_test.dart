import 'package:driving_rule/app/themes/khmer_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  group('ReadableTextScaler', () {
    const scaler = ReadableTextScaler();

    test('leaves body text and headings unchanged', () {
      for (final size in [14.0, 16.0, 23.0, 36.0]) {
        expect(scaler.scale(size), size);
      }
    });

    test('lifts small sizes to at least the floor', () {
      expect(scaler.scale(9), closeTo(12, 1e-9));
      expect(scaler.scale(10), closeTo(12.4, 1e-9));
      expect(scaler.scale(12), closeTo(13.2, 1e-9));
    });

    test('is monotonic, so label hierarchy is preserved', () {
      var previous = 0.0;
      for (var s = 8.0; s <= 20; s += 0.5) {
        final scaled = scaler.scale(s);
        expect(scaled, greaterThan(previous));
        previous = scaled;
      }
    });

    test('applies the platform text scale on top', () {
      const big = ReadableTextScaler(base: TextScaler.linear(1.25));
      expect(big.scale(10), closeTo(12.4 * 1.25, 1e-9));
      expect(big.scale(20), closeTo(25, 1e-9));
    });

    test('has value equality', () {
      expect(const ReadableTextScaler(), const ReadableTextScaler());
      expect(
        const ReadableTextScaler(),
        isNot(const ReadableTextScaler(floor: 11)),
      );
    });
  });

  group('KhmerTypography.wrap', () {
    Future<(TextScaler, double?)> pumpWith(
      WidgetTester tester,
      Locale locale,
    ) async {
      late TextScaler scaler;
      double? spacing;
      await tester.pumpWidget(
        GetMaterialApp(
          locale: locale,
          theme: ThemeData(
            textTheme: const TextTheme(
              headlineLarge: TextStyle(letterSpacing: -0.8),
            ),
          ),
          builder: KhmerTypography.builder,
          home: Builder(
            builder: (context) {
              scaler = MediaQuery.textScalerOf(context);
              spacing = Theme.of(
                context,
              ).textTheme.headlineLarge?.letterSpacing;
              return const SizedBox();
            },
          ),
        ),
      );
      Get.locale = null;
      return (scaler, spacing);
    }

    testWidgets('Khmer gets readable scaling and zero tracking', (t) async {
      final (scaler, spacing) = await pumpWith(t, const Locale('km'));
      expect(scaler, isA<ReadableTextScaler>());
      expect(spacing, 0);
    });

    testWidgets('English is left exactly as designed', (t) async {
      final (scaler, spacing) = await pumpWith(t, const Locale('en'));
      expect(scaler, isNot(isA<ReadableTextScaler>()));
      expect(spacing, -0.8);
    });
  });
}
