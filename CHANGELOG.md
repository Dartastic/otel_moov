# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedMoov<T>(...)` — wraps a otel_moov call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutMoovInstrumentation()` / `Async()`.
