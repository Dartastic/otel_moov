// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_moov_suppression.dart';

class MoovResult {
  const MoovResult({
    this.accountId,
    this.counterpartyId,
    this.transferId,
    this.paymentMethod,
    this.rail,
    this.amount,
    this.currency,
    this.status,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? accountId;
  final String? counterpartyId;
  final String? transferId;
  final String? paymentMethod;
  final String? rail;
  final double? amount;
  final String? currency;
  final String? status;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class MoovCallResult<T> {
  const MoovCallResult({required this.value, this.result});
  final T value;
  final MoovResult? result;
}

Future<T> tracedMoov<T>({
  required String operation,
  required Future<MoovCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (moovInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_moov');
  final span = t.startSpan('moov $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'moov');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.accountId != null) {
        span.setStringAttribute('moov.account.id', res.accountId!);
      }
      if (res.counterpartyId != null) {
        span.setStringAttribute('moov.counterparty.id', res.counterpartyId!);
      }
      if (res.transferId != null) {
        span.setStringAttribute('moov.transfer.id', res.transferId!);
      }
      if (res.paymentMethod != null) {
        span.setStringAttribute('moov.payment_method', res.paymentMethod!);
      }
      if (res.rail != null) {
        span.setStringAttribute('moov.rail', res.rail!);
      }
      if (res.amount != null) {
        span.setDoubleAttribute('moov.amount', res.amount!);
      }
      if (res.currency != null) {
        span.setStringAttribute('moov.currency', res.currency!);
      }
      if (res.status != null) {
        span.setStringAttribute('moov.status', res.status!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('moov.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'moov.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
