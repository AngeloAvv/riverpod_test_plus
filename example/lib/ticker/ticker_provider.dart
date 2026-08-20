import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A finite [StreamProvider], so tests observe a deterministic sequence.
final tickerProvider = StreamProvider<int>(
  (ref) => Stream<int>.periodic(
    const Duration(milliseconds: 20),
    (tick) => tick,
  ).take(3),
  name: 'tickerProvider',
);
