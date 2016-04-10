import json

export json

type
  # Raised when something prevents json from being deserialized into a tuple.
  # Your tuple might be in a undefined state at that point.
  DeserializeError* = object of Exception

  DeserializerFlags* {.pure.} = enum
    # Require all fields of the tuple.
    ErrorWhenMissing,
    # Autocast types where possible, allows for gentler
    # deserialisation. Default is to error when types
    # cannot be converted directly.
    # TODO: LooseCasting

  SerializerFlags* {.pure.} = enum
    # Fail when encoutering nil
    # TODO: ForbidNil,

    # Applies to structs and seqs only:
    # Don't emit nil fields. Otherwise, nil values are
    # emitted as json null values.
    SkipNil,

    # Transform nil fields into their json defaults
    # when nil. This means that strings will be ""
    # instead of null. Mutually exclusive with SkipNil
    # TODO: DefaultNil

const
  # The default settings are strict parsing and generating,
  # meaning all fields need to be filled.
  DefaultDeserializerFlags* = {
    DeserializerFlags.ErrorWhenMissing
  }

  DefaultSerializerFlags*: set[SerializerFlags] = {
    SerializerFlags.SkipNil
  }

import sequtils

type
  IntType =
    uint | int | int8 | int16 | int32 | int64 |
    uint8 | uint16 | uint32 | uint64 | BiggestInt

  FloatType = float | float32 | float64

  Nilable = seq|ref|string|ptr|pointer|cstring


# support for all native json types included by default

# bool

proc toJson*[T: bool](t: T, flags = DefaultSerializerFlags): JsonNode =
  result = %t

proc fromJson*[T: bool](t: var T, j: JsonNode, flags = DefaultDeserializerFlags): void =
  if j.kind != JBool: raise newException(DeserializeError, $j & " not bool")
  t = j.getBVal

# string

proc toJson*[T: string](t: T, flags = DefaultSerializerFlags): JsonNode =
  result = %t

proc fromJson*[T: string](t: var T, j: JsonNode, flags = DefaultDeserializerFlags): void =
  if j.kind != JString: raise newException(DeserializeError, $j & " not string")
  t = j.getStr

# integer

proc toJson*[T: IntType](t: T, flags = DefaultSerializerFlags): JsonNode =
  result = %t

proc fromJson*[T: IntType](t: var T, j: JsonNode, flags = DefaultDeserializerFlags): void =
  if j.kind != JInt: raise newException(DeserializeError, $j & " not integer")
  t = cast[T](j.getNum)

# float

proc toJson*[T: FloatType](t: T, flags = DefaultSerializerFlags): JsonNode =
  result = %t

proc fromJson*[T: FloatType](t: var T, j: JsonNode, flags = DefaultDeserializerFlags): void =
  if j.kind != JFloat: raise newException(DeserializeError, $j & " not floating point")
  t = j.getFNum

# tuple

proc toJson*[T: tuple](t: T, flags = DefaultSerializerFlags): JsonNode =
  result = newJObject()
  for k, v in fieldPairs(t):
    when v is Nilable:
      if not (SerializerFlags.SkipNil in flags and isNil(v)):
        result[k] = toJson(v, flags)

    else:
      result[k] = toJson(v, flags)

proc fromJson*[T: tuple](v: var T, j: JsonNode, flags = DefaultDeserializerFlags): void =
  try:
    if j.kind != JObject: raise newException(DeserializeError, $j & " not tuple")
    for k, v in fieldPairs(v):
      # hackhack: assign back to tuple
      if j.hasKey(k): fromJson(v, j[k], flags)
      elif DeserializerFlags.ErrorWhenMissing in flags:
        raise newException(DeserializeError, "json missing key: " & $k)

  except DeserializeError:
    raise newException(DeserializeError, getCurrentExceptionMsg() & ", while deserializing " & $j)
  return


# seq

proc toJson*[T: seq](t: T, flags = DefaultSerializerFlags): JsonNode =
  result = newJArray()
  for e in t:
    when e is Nilable:
      if not (SerializerFlags.SkipNil in flags and isNil(e)):
        result.add(toJson(e, flags))
    else:
      result.add(toJson(e, flags))

proc fromJson*[T](v: var seq[T], j: JsonNode, flags = DefaultDeserializerFlags): void =
  v = j.getElems.map(proc (e: JsonNode): T =
    fromJson(result, e, flags))
