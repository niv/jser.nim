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

include private/core
