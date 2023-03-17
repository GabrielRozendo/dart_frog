part of '_internal.dart';

/// {@template context}
/// An object representing a request-specific context.
/// {@endtemplate}
class RequestContext {
  RequestContext._(shelf.Request request) : request = Request._(request);

  /// The associated [Request].
  final Request request;

  /// Provide the value returned by [create] to the respective
  /// request context.
  RequestContext provide<T extends Object?>(T Function() create) {
    return RequestContext._(
      request._request.change(
        context: {...request._request.context, '$T': create},
      ),
    );
  }

  /// Lookup an instance of [T] from the [request] context.
  ///
  /// A [StateError] is thrown if [T] is not available within the
  /// provided [request] context.
  T read<T>() {
    if (!request._request.context.containsKey('$T')) {
      throw StateError(
        '''
context.read<$T>() called with a request context that does not contain a $T.

This can happen if $T was not provided to the request context:
  ```dart
  // _middleware.dart
  Handler middleware(Handler handler) {
    return handler.use(provider<T>((context) => $T());
  }
  ```
''',
      );
    }
    final value = request._request.context['$T']!;
    final create = value as T Function();
    return create();
  }
}
