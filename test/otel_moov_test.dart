// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_moov/otel_moov.dart';
import 'package:test/test.dart';

void main() {
  group('otel_moov', () {
    test('suppression toggles in zone', () async {
      expect(moovInstrumentationSuppressed(), isFalse);
      await runWithoutMoovInstrumentationAsync(() async {
        expect(moovInstrumentationSuppressed(), isTrue);
      });
      expect(moovInstrumentationSuppressed(), isFalse);
    });

    test('MoovResult fields default null', () {
      const r = MoovResult();
      expect(r.statusCode, isNull);
    });
  });
}
