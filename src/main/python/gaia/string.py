#
# string.py
#
# String utilities.
#

def capitalize(str: str) -> str | None:
  """
  Capitalizes the first character of `str`.

  Returns a new string.
  """

  return str and str[0:1].upper() + str[1:] or str

def remove_leading(str: str, sub: str) -> str:
  """
  Strips the leading substring `sub`, if any, from `str`.
  """

  l = len(sub)
  if l == 0 or l > len(str):
    return str
  if str[0:l] == sub:
    return str[l:]
  return str

def remove_trailing(str: str, sub: str) -> str:
  """
  Strips the trailing substring `sub`, if any, from `str`.
  """

  l = len(sub)
  if l == 0 or l > len(str):
    return str
  if str[-l] == sub:
    return str[0:-l]
  return str

def uncapitalize(str: str) -> str | None:
  """
  Uncapitalizes the first character of `str`.

  Returns a new string.
  """

  return str and str[0:1].lower() + str[1:] or str

# EOF
