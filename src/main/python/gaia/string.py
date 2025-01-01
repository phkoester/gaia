#
# @file string.py
#
# String utilities.
#

def capitalize(s: str) -> str:
  """
  Capitalizes the first character of @p s.

  @param s a string
  @return a new string where the first character is an upper-case character
  """

  return s and s[0:1].upper() + s[1:] or s

def removeLeading(s: str, sub: str) -> str:
  """
  If the string @p s begins with the substring @p sub, removes the substring.

  @param s a string
  @param sub a substring
  @return a string
  """

  l = len(sub)
  if l == 0 or l > len(s):
    return s
  if s[0:l] == sub:
    return s[l:]
  return s

def removeTrailing(s: str, sub: str) -> str:
  """
  If the string @p s ends with the substring @p sub, removes the substring.

  @param s a string
  @param sub a substring
  @return a string
  """

  l = len(sub)
  if l == 0 or l > len(s):
    return s
  if s[-l] == sub:
    return s[0:-l]
  return s

def uncapitalize(s: str) -> str:
  """
  Uncapitalizes the first character of @p s.

  @param s a string
  @return a new string where the first character is a lower-case character
  """

  return s and s[0:1].lower() + s[1:] or s

# EOF
