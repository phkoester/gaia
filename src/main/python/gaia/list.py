#
# list.py
#
# List utilities.
#

def dedup(list: list[any]) -> None:
  """
  Modifies the list `list` such that it contains no duplicates.
  
  The order of the elements in the list is retained.
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
  Returns a new list that contains all elements from `list` that are in `filter`.
  """
  
  result=[]
  for elem in list:
    if elem in filter:
      result.append(elem)
  return result

def filter_out(list: list[any], filter: list[any]) -> list[any]:
  """
  Returns a new list that contains all elements from `list` that are *not* in `filter`.
  """

  result=[]
  for elem in list:
    if not elem in filter:
      result.append(elem)
  return result

# EOF
