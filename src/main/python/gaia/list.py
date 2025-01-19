#
# @file list.py
#
# List utilities.
#

def dedupIn(list: list[any]) -> None:
  """
  Modifies the list @p list such that it contains no duplicates.
  
  The order of the elements in @p list is retained.

  @param list the list to modify
  """
  
  seen = set()
  i, length = 0, len(list)
  while True:
    if i == length:
      return
    elem = list[i]
    if elem in seen:
      del list[i]
      length -= 1
    else:
      seen.add(elem)
      i += 1

def filter(list: list[any], filter: list[any]) -> list[any]:
  """
  Makes a new list that contains all elements from @p list that are in @p filter

  @param list a list
  @param filter a list containing the elements that are to be filtered
  @return a new list
  """
  
  result=[]
  for elem in list:
    if elem in filter:
      result.append(elem)
  return result

def filterOut(list: list[any], filterOut: list[any]) -> list[any]:
  """
  Makes a new list that contains all elements from @p list that are not in @p filterOut

  @param list a list
  @param filterOut a list containing the elements that are to be filtered out
  @return a new list
  """

  result=[]
  for elem in list:
    if not elem in filterOut:
      result.append(elem)
  return result

# EOF
