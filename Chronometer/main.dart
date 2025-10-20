import 'dart:async';

class Timer {
  Stream<int> secondGenerator(Stream<String> tick) async* {
    int seconds = 0;
    await for (final s in tick) {
      yield seconds++;
    }
  }

  Stream<String> tickGenerator(Duration inverval) async* {
    while (true) {
      await Future.delayed(inverval);
      yield "tick";
    }
  }
}

main() async {
  int test;
  Timer timer = Timer();
  timer.secondGenerator(timer.tickGenerator(const Duration(seconds: 1))).listen(
    (data) {
      print(data);
    },
  );
}
