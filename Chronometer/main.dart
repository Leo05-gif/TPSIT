import 'dart:async';

main() async {
  var t = tickGenerator(const Duration(seconds: 1));

  timer(t).listen((data) {
    print(data);
  });
}

Stream<int> timer(Stream<String> tick) async* {
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
