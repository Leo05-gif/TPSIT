import 'dart:async';

class Time {
  int seconds = 0;
  int minutes = 0;
  int hours = 0;
}

class Timer {
  Time time = Time();

  Stream<int> secondGenerator(Stream<String> tick) async* {
    await for (final s in tick) {
      if (time.seconds == 60) {
        time.minutes++;
        time.seconds = 0;
      }

      if (time.minutes == 60) {
        time.hours++;
        time.minutes = 0;
      }

      yield time.seconds++;
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
  Timer timer = Timer();
  timer.secondGenerator(timer.tickGenerator(const Duration(seconds: 1))).listen(
    (data) {
      print(data);
    },
  );
}
