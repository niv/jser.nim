import ../jser

import unittest, times, options

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

suite "optional":
  type Testable = tuple
    required: string
    optional: Option[string]

  test "when deserializing, error about missing required values":
    var instance: Testable
    expect DeserializeError:
      instance.fromJson(%*{"optional": "hi"})

  test "when deserializing, skips missing optional values":
    var instance: Testable
    instance.fromJson(%*{"required": "hi"})
    check instance.required == "hi"
    check instance.optional.isNone

  test "when deserializing, fill in provided optional values":
    var instance: Testable
    instance.fromJson(%*{"required": "hi", "optional": "there"})
    check instance.required == "hi"
    check instance.optional.get() == "there"

  test "when deserializing, replace filled fields with empty":
    var instance: Testable
    instance.optional = some("hi")
    instance.fromJson(%*{"required": "hi"})
    check instance.required == "hi"
    check instance.optional.isNone

  test "when serializing empty optionals, emit blank":
    var instance: Testable
    instance.required = ""
    instance.optional = none(string)
    check $instance.toJson() == """{"required":""}"""
