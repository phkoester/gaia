#
# @file __init.py__
# 
# Module @c gaia.
#

import io
import json

def hexVersion(dir: str) -> None:
  """
  Reads the file @c project.json in the directory @p dir and prints the @c "version" value of the JSON as a
  hexadecimal string.

  @param dir the directory where @c project.json resides
  """
  
  path = dir + "/project.json"
  with io.open(path, mode="r") as file:
    o = json.load(file)
    numbers = o["version"].split(".")
    print("0x", end="")
    for number in numbers:
      print(f"{int(number):02}", end="")

def version(dir: str) -> None:
  """
  Reads the file @c project.json in the directory @p dir and prints the @c "version" value of the JSON

  @param dir the directory where @c project.json resides
  """
  
  path = dir + "/project.json"
  with io.open(path, mode="r") as file:
    o = json.load(file)
    print(o["version"], end="")

def versionCode(dir: str) -> None:
  """
  Reads the file @c project.json in the directory @p dir and prints the @c "versionCode" value of the JSON

  @param dir the directory where @c project.json resides
  """

  path = dir + "/project.json"
  with io.open(path, mode="r") as file:
    o = json.load(file)
    print(o["versionCode"], end="")

# EOF
