#
# path.py
#
# Path utilities.
#

import gaia.string
import os

def absolute(path: str) -> bool:
  """
  Checks if the path `path` is an absolute path.
  """
  return path[0:1] == "/"

def find(paths: str, file: str, path_sep: str = ":") -> str | None:
  """
  Looks for the file `file` either as an existing absolute file or as an existing file relative to one of
  the paths in `paths`, which is a list of paths, separated by `path_sep`.
  """

  if absolute(file):
    if os.path.isfile(file):
      return file
    return None

  for path in paths.split(path_sep):
    path = gaia.string.remove_trailing(path, "/")
    if os.path.isfile(path + "/" + file):
      return path + "/" + file
  return None

# EOF
