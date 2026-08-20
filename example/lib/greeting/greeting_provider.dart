import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The simplest thing `riverpodTest` can test: a synchronous [Provider].
final greetingProvider = Provider<String>(
  (ref) => 'Hello, Riverpod!',
  name: 'greetingProvider',
);
