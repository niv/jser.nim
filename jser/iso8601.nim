# optional iso8601 time formatting for jser
# to use, simply include this in your project and you
# can de/serialize TimeInfo fields from/to iso8601

import json, times, strutils

export times

import ../jser

# Calendar dates
# YYYY-MM-DD  or  YYYYMMDD
# YYYY-MM
#
# Week dates
# YYYY-Www  or  YYYYWww
# YYYY-Www-D  or  YYYYWwwD
#
# Ordinal dates
# YYYY-DDD  or  YYYYDDD
#
# Times
# hh:mm:ss.sss  or  hhmmss.sss
# hh:mm:ss  or  hhmmss
# hh:mm  or  hhmm
# hh
#
# Time zone designators
# <time>Z
# <time>±hh:mm
# <time>±hhmm
# <time>±hh

proc jserTimeToStr*(t: TimeInfo): string =
  t.format("yyyy-MM-dd'T'HH:mm:sszzz")

proc jserStrToTime*(s: string): TimeInfo =
  # Supported formats, for now:
  # - full (like we output, including timezone)
  # - "calendar date" style only
  if s.find('T') > 0:
    if s.endsWith("Z"):
      result = s.parse("yyyy-MM-dd'T'HH:mm:ss'Z'")
    else:
      result = s.parse("yyyy-MM-dd'T'HH:mm:sszzz")
  else:
    result = s.parse("yyyy-MM-dd")

proc toJson*[T: TimeInfo](t: T, flags = DefaultSerializerFlags): JsonNode =
  when t is Time: result = %jserTimeToStr(t.getGMTime())
  else: result = %jserTimeToStr(t)

proc fromJson*[T: TimeInfo](t: var T, j: JsonNode, flags = DefaultDeserializerFlags): void =
  if j.kind != JString: raise newException(DeserializeError, $j & " not time")
  when t is Time: t = jserStrToTime(j.getStr).timeInfoToTime
  else: t = jserStrToTime(j.getStr)
