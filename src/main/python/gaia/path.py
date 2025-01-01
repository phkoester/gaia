#
# @file path.py
#
# Path utilities.
#

import gaia
import os

def absolute(path: str) -> bool:
  """
  Tells if the path @p path is an absolute path.

  @param path a path
  @return @c true if @p path is an absolute path, @c false otherwise
  """
  return path[0:1] == "/"

def find(paths: str, file: str, pathSeparator: str = ":") -> str:
  """
  Looks for the file @p file either as an existing absolute file or as an existing file relative to one of
  the paths in @p paths, which is a list of paths, separated by @p pathSeparator.

  @param paths a list of paths, separated by @p pathSeparator
  @param file the file to look for, either absolute or relative
  @param pathSeparator the path separator used in @p paths
  @return a path to the found file, if any, @c None otherwise
  """

  if absolute(file):
    if os.path.isfile(file):
      return file
    return None
  
  for path in paths.split(pathSeparator):
    path = gaia.string.removeTrailing(path, "/")
    if os.path.isfile(path + "/" + file):
      return path + "/" + file
  return None

# EOF
