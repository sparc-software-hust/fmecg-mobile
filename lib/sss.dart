import 'dart:math';

class StraightIgnoreSolve {
  List<Straight> solve(Straight initialStraight, List<Straight> listIgnore) {
    print('initialStraight:$initialStraight ---- $listIgnore');
    return [];
  }
}

void main() {
  Straight initialStraight = Straight(0, 1000);
  int count = 3;
  List<Straight> listIgnoreStraight = generateListIgnore(initialStraight, count);

  DateTime start = DateTime.now();
  List<Straight> result = StraightIgnoreSolve().solve(initialStraight, listIgnoreStraight);
  DateTime end = DateTime.now();

  print("Length: ${result.length}");
  printResult(result);
  print("Time taking: ${end.difference(start).inMicroseconds} milisecond");
}

void printResult(List<Straight> result) {
  print("Result: ");
  for (var e in result) {
    print(e);
  }
}

List<Straight> generateListIgnore(Straight initialStraight, int count) {
  Random random = Random();
  List<Straight> result = [];

  for (var i = 0; i < count; i++) {
    int x = initialStraight.x + random.nextInt(initialStraight.y - initialStraight.x);
    int y = x + random.nextInt(initialStraight.y - x);
    result.add(Straight(x, y));
  }
  return result;
}

class Straight {
  int x;
  int y;

  Straight(this.x, this.y);

  @override
  String toString() {
    return "$x,$y";
  }
}
