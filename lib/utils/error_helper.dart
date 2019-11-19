import 'package:nocd/utils/utils_misc.dart';
import 'package:sentry/sentry.dart';

/**
 * A helper for error handling.
 *
 * A wrapper to manage error reporting attributes.
 * Helps setup and configure [SentryClient].
 * Provides error conversion methods to propagate app errors in the correct format to error reporting.
 */
class ErrorHelper {
  /// Sentry.io error reporting.
  SentryClient _sentry = SentryClient(
    dsn:
        "https://376973ce3f5b499caf0f1b51e7304f20:c25e6a80e0c0447ca356961c0f93c0a0@sentry.io/1472415",
    environmentAttributes: const Event(release: '1.1.5'),
  );

  /// Update Sentry DSN by creating a new [SentryClient] with the updated DSN.
  void setSentryDSN(String dsn) {
    _sentry = SentryClient(dsn: dsn);
  }

  /// Enrich Sentry error reporting with user attributes. Called in [AppBloc.setConfig].
  void setSentryUserAttributes(Map<String, dynamic> config) {
    // Do not send access token to error reporting.
    if (config.containsKey("accessToken")) {
      config.remove("accessToken");
    }
    _sentry.userContext = User(
        id: config.containsKey("guid") ? config["guid"] : "", extras: config);
    print("Sentry: " + config.toString());
  }

  /// Reports [error] along with its [stackTrace] to Sentry.io.
  Future<Null> reportError(dynamic error, dynamic stackTrace) async {
    print('Caught error: $error');

    // Errors thrown in development mode are unlikely to be interesting. You can
    // check if you are running in dev mode using an assertion and omit sending
    // the report.
    if (DeviceUtils.isDebug()) {
      print(stackTrace);
      print('In dev mode. Not sending report to Sentry.io.');
      return;
    }

    print('Reporting to Sentry.io...');

    final SentryResponse response = await _sentry.captureException(
      exception: error,
      stackTrace: stackTrace,
    );

    if (response.isSuccessful) {
      print('Success! Event ID: ${response.eventId}');
    } else {
      print('Failed to report to Sentry.io: ${response.error}');
    }
  }

  /// Convenience helper to report [exception] with stacktrace.
  void reportException(dynamic exception) {
    reportError(exception, exception.toString());
  }

  /// Packages an [error] string into an [ErrorMessage] and reports it.
  void reportErrorMessage(String error) {
    ErrorMessage errorMessage = ErrorMessage(error);
    reportError(errorMessage, errorMessage.stackTrace);
  }
}

/**
 * A wrapper for a basic message error.
 *
 * Converts a [message] string into an [Error] object.
 */
class ErrorMessage extends Error implements Exception {
  /// Error message.
  String message;

  ErrorMessage(
    this.message,
  );

  String toString() => (message ?? "").toString();
}
