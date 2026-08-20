import 'package:flutter_riverpod/flutter_riverpod.dart';

class Counter extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;

  void decrement() => state--;
}

final counterProvider = NotifierProvider<Counter, int>(
  Counter.new,
  name: 'counterProvider',
);
