# jser - serialize json data from/to types easily

## 10-second example

```nim
import jser

var t: tuple[a: string, b: int, c: float, d: seq[int]]

try:
  t.fromJson(%*{"a": "test", "b": 2, "c": 1.3, "d": [5]})
  echo t
  echo t.toJson

  t.fromJson(%*{"a": "test", "b": "NOPE", "c": 1.3, "d": [5]})

except DeserializeError:
  echo "uwotm8: " & getCurrentExceptionMsg()
```

## Flags

By default, jser is strict when parsing and lenient when generating:

* nil values on tuples, strings, seqs and so on are skipped on generation
* missing values in received json (for tuples) raise a DeserializeError

You can allow missing fields by passing in {} to flags (a empty set).

More options might be supported later.

## Adding support for more types

To add (currently broken, thanks to https://github.com/nim-lang/Nim/issues/3200)
support for iso8601 time parsing, simply import `jster/iso8601`

You can support arbitary types by implementing:

```nim
proc toJson*[T: YourType](t: T, flags = DefaultSerializerFlags): JsonNode
proc fromJson*[T: YourType](t: var T, j: JsonNode, flags = DefaultDeserializerFlags): void
```

Best see the core code for examples.
It's up to you to adhere to the flags passed in.