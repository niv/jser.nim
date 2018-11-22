import ../jser

import unittest, times

template deserialize(label: string, t: untyped,
    valid: JsonNode, expected: untyped): untyped =
  test label:
    var instance: t
    instance.fromJson(valid)
    check(instance == expected)

suite "basics":
  deserialize("bool", bool, %true, true)
  deserialize("int", int, %5, 5)
  deserialize("float", float, %5.0, 5.0)
  deserialize("string", string, %"harold", "harold")
  let ja = newJArray(); ja.add(%1)
  deserialize("seq[int]", seq[int], ja, @[1])
  deserialize("tuple", tuple[b: string], %*{"b": "test"}, (b: "test"))

suite "nesting":
  deserialize("basics",
    tuple[inner: tuple[b: seq[float]]],
    %*{"inner": {"b": [1.2, 2.4, 4.8]}},
    (inner: (b: @[1.2, 2.4, 4.8])))

suite "ignoreStyle deserialisation":
  type Testable = tuple[camelCase: string]
  var instance: Testable

  test "does not ignore style by default":
    expect DeserializeError:
      instance.fromJson(%*{"camel_case": "test"})

  test "ignores style when asked":
    instance.fromJson(%*{"camel_case": "test"}, {DeserializerFlags.CompareIgnoreStyle})
    check instance.camelCase == "test"
