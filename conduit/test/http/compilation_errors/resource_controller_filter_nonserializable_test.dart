import 'dart:async';

import 'package:conduit/conduit.dart';
import 'package:conduit_runtime/runtime.dart';
import "package:test/test.dart";

void main() {
  test("Cannot bind invalid type to default implementation", () {
    try {
      // ignore: unnecessary_statements
      RuntimeContext.current;
      fail('unreachable');
    } on StateError catch (e) {
      expect(
        e.toString(),
        "Bad state: Invalid binding 'a' on 'FilterNonSerializable.get1':"
        "Filters can only be used on Serializable or List<Serializable>.",
      );
    }
  });
}

class FilterNonSerializable extends ResourceController {
  @Operation.post()
  Future<Response> get1(
      @Bind.body(ignore: ["id"]) Map<String, dynamic> a) async {
    return Response.ok(null);
  }
}
