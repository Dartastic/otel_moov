# otel_moov

Dartastic OpenTelemetry bridge for Moov (embedded payments + money movement).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_moov/otel_moov.dart';

await tracedMoov<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return MoovCallResult(value: r, result: MoovResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutMoovInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
