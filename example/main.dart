// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_moov/otel_moov.dart';

/// Traces Moov calls with OpenTelemetry.
///
/// `otel_moov` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Moov call in
/// [tracedMoov]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'moov-example');

  // Traces a Moov call.
  final moovId = await tracedMoov<String>(
    operation: 'create',
    invoke: () async {
      // Make the Moov call here, then report what it returned.
      const id = 'moov_8f3a2c';
      return const MoovCallResult(
          value: id,
          result: MoovResult(
              accountId: 'account_8f3a2c',
              counterpartyId: 'counterparty_8f3a2c',
              transferId: 'transfer_8f3a2c',
              paymentMethod: 'card',
              rail: 'example',
              amount: 0.5,
              currency: 'usd',
              status: 'succeeded',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedMoov create returned $moovId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutMoovInstrumentationAsync.
  await runWithoutMoovInstrumentationAsync(
    () => tracedMoov<String>(
      operation: 'create',
      invoke: () async {
        const id = 'moov_8f3a2c';
        return const MoovCallResult(
            value: id,
            result: MoovResult(
                accountId: 'account_8f3a2c',
                counterpartyId: 'counterparty_8f3a2c',
                transferId: 'transfer_8f3a2c',
                paymentMethod: 'card',
                rail: 'example',
                amount: 0.5,
                currency: 'usd',
                status: 'succeeded',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
