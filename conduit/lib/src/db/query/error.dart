import 'package:conduit/src/http/http.dart';

import '../persistent_store/persistent_store.dart';
import 'query.dart';

/// An exception describing an issue with a query.
///
/// A suggested HTTP status code based on the type of exception will always be available.
class QueryException<T> implements HandlerException {
  QueryException(this.event,
      {this.message, this.underlyingException, this.offendingItems});

  QueryException.input(this.message, this.offendingItems,
      {this.underlyingException})
      : event = QueryExceptionEvent.input;
  QueryException.transport(this.message, {this.underlyingException})
      : event = QueryExceptionEvent.transport,
        offendingItems = null;
  QueryException.conflict(this.message, this.offendingItems,
      {this.underlyingException})
      : event = QueryExceptionEvent.conflict;

  final String? message;

  /// The exception generated by the [PersistentStore] or other mechanism that caused [Query] to fail.
  final T? underlyingException;

  /// The type of event that caused this exception.
  final QueryExceptionEvent event;

  final List<String>? offendingItems;

  @override
  Response get response {
    return Response(_getStatus(event), null, _getBody(message, offendingItems));
  }

  static Map<String, String> _getBody(
      String? message, List<String>? offendingItems) {
    var body = {
      "error": message ?? "query failed",
    };

    if (offendingItems != null && offendingItems.isNotEmpty) {
      body["detail"] = "Offending Items: ${offendingItems.join(", ")}";
    }

    return body;
  }

  static int _getStatus(QueryExceptionEvent event) {
    switch (event) {
      case QueryExceptionEvent.input:
        return 400;
      case QueryExceptionEvent.transport:
        return 503;
      case QueryExceptionEvent.conflict:
        return 409;
    }
  }

  @override
  String toString() => "Query failed: $message. Reason: $underlyingException";
}

/// Categorizations of query failures for [QueryException].
enum QueryExceptionEvent {
  /// This event is used when the underlying [PersistentStore] reports that a unique constraint was violated.
  ///
  /// [Controller]s interpret this exception to return a status code 409 by default.
  conflict,

  /// This event is used when the underlying [PersistentStore] cannot reach its database.
  ///
  /// [Controller]s interpret this exception to return a status code 503 by default.
  transport,

  /// This event is used when the underlying [PersistentStore] reports an issue with the data used in a [Query].
  ///
  /// [Controller]s interpret this exception to return a status code 400 by default.
  input,
}
