import 'dart:typed_data';
import 'dart:collection';

void main() {
  BigInt a = BigInt.from(123);
  Uint8List b = Uint8List.fromList([1, 2, 3]);
  final list = <bool>[]..add(true);

  print(a);
  print(b);
  print(list);
}
