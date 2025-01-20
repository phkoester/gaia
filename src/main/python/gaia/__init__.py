#
# @file __init.py__
# 
# Module `gaia`.
#

import io
import json

def hexVersion(dir: str) -> None:
  """
  Reads the file `project.json` in the directory @p dir and prints the `version` value of the JSON as a
  hexadecimal string.

  @param dir the directory where `project.json` resides
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
  Reads the file `project.json` in the directory @p dir and prints the `version` value of the JSON.

  @param dir the directory where `project.json` resides
  """
  
  path = dir + "/project.json"
  with io.open(path, mode="r") as file:
    o = json.load(file)
    print(o["version"], end="")

def versionCode(dir: str) -> None:
  """
  Reads the file `project.json` in the directory @p dir and prints the `versionCode` value of the JSON.

  @param dir the directory where `project.json` resides
  """

  path = dir + "/project.json"
  with io.open(path, mode="r") as file:
    o = json.load(file)
    print(o["versionCode"], end="")

# EOF
