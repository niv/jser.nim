import ../jser
import ../jser/iso8601

import unittest, times

outputLevel = PRINT_ALL

template deserialize(label: string, t: expr,
    valid: JsonNode, expected: expr): stmt =
  test label:
    var instance: t
    instance.fromJson(valid)
    check(instance == expected)
    # checkpoint(label)

# template serialize(label: string, t: expr)

deserialize("bool", bool, %true, true)

deserialize("int", int, %5, 5)

deserialize("float", float, %5.0, 5.0)

deserialize("string", string, %"harold", "harold")

deserialize("tuple", tuple[b: string], %*{"b": "test"}, (b: "test"))

let ja = newJArray(); ja.add(%1)
deserialize("seq[int]", seq[int], ja, @[1])

deserialize("nested data",
  tuple[inner: tuple[b: seq[float]]],
  %*{"inner": {"b": [1.2, 2.4, 4.8]}},
  (inner: (b: @[1.2, 2.4, 4.8]))
)


test "parses supported iso time formats properly":
  check($jserStrToTime("2016-01-1") == "Thu Jan  1 00:00:00 2016")
  check($jserStrToTime("2016-01-01T01:02:03+00:00") == "Fri Jan  1 01:02:03 2016")
  check($jserStrToTime("2016-01-01T01:02:03Z") == "Fri Jan  1 01:02:03 2016")
  check(jserStrToTime("2016-01-01T01:02:03+01:00").timezone == 1)

test "generates full iso time format":
  # times module is kind of .. broken as of this writing:
  # https://github.com/nim-lang/Nim/issues/3200
  check(jserTimeToStr(jserStrToTime("2016-01-1")) == "2016-01-01T00:00:00+00:00")
  check(jserTimeToStr(jserStrToTime("2016-01-01T01:02:03+01:00")) == "2016-01-01T01:02:03+01:00")
  check(jserTimeToStr(jserStrToTime("2016-01-01T01:02:03Z")) == "2016-01-01T01:02:03+00:00")