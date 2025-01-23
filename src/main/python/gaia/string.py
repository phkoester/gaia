#
# string.py
#
# String utilities.
#

def capitalize(s: str) -> str | None:
  """
  Capitalizes the first character of `s`.
  
  Returns a new string.
  """

  return s and s[0:1].upper() + s[1:] or s

def remove_leading(s: str, sub: str) -> str:
  """
  Strips the leading substring `sub`, if any, from `s`.
  """

  l = len(sub)
  if l == 0 or l > len(s):
    return s
  if s[0:l] == sub:
    return s[l:]
  return s

def remove_trailing(s: str, sub: str) -> str:
  """
  Strips the trailing substring `sub`, if any, from `s`.
  """

  l = len(sub)
  if l == 0 or l > len(s):
    return s
  if s[-l] == sub:
    return s[0:-l]
  return s

def uncapitalize(s: str) -> str | None:
  """
  Uncapitalizes the first character of `s`.
  
  Returns a new string.
  """

  return s and s[0:1].lower() + s[1:] or s

# EOF
