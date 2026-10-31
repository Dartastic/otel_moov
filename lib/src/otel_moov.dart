// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_moov_suppression.dart';

class MoovResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class MoovCallResult<T> {
  /// Creates a call result.
  const MoovCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final MoovResult? result;
}

Future<T> tracedMoov<T>({
  required String operation,
  required Future<MoovCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (moovInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_moov');
  final span = t.startSpan('moov $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'moov')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.accountId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('moov.account.id', res.accountId!)]));
      }
      if (res.counterpartyId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('moov.counterparty.id', res.counterpartyId!)
        ]));
      }
      if (res.transferId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('moov.transfer.id', res.transferId!)]));
      }
      if (res.paymentMethod != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('moov.payment_method', res.paymentMethod!)
        ]));
      }
      if (res.rail != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('moov.rail', res.rail!)]));
      }
      if (res.amount != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeDouble('moov.amount', res.amount!)]));
      }
      if (res.currency != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('moov.currency', res.currency!)]));
      }
      if (res.status != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('moov.status', res.status!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('moov.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'moov.error',
          )
        ]));
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
