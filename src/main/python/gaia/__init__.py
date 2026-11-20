#
# __init__.py
#

import io
import json5
import os
import re
import toml

def get_configurations(dir: str, preset: str) -> list[str]:
  """
  Retrieves the configurations of the configure preset `preset` in `CMakePresets.json` in the directory
  `dir`, i.e., the value of `CMAKE_CONFIGURATION_TYPES`, following inherited presets.

  Returns an empty list if the file, the preset, or the variable is not found.
  """

  path = dir + "/CMakePresets.json"
  if not os.path.isfile(path):
    return []
  with io.open(path, mode="r") as file:
    o = json5.load(file)
  presets = { it["name"]: it for it in o.get("configurePresets", []) if "name" in it }

  # Search the preset first, then the presets it inherits from, depth first and in order
  todo = [preset]
  seen = set()
  while todo:
    name = todo.pop(0)
    if name in seen or name not in presets:
      continue
    seen.add(name)
    value = presets[name].get("cacheVariables", {}).get("CMAKE_CONFIGURATION_TYPES")
    if isinstance(value, dict):
      value = value.get("value")
    if isinstance(value, str):
      return [it for it in value.split(";") if it]
    inherits = presets[name].get("inherits", [])
    todo[0:0] = [inherits] if isinstance(inherits, str) else inherits

  return []

def get_version(dir: str) -> str | None:
  """
  Tries to retrieve a project version in the directory `dir`.

  The function probes `CMakeLists.txt`, `Cargo.toml`, and `gaia-project.json` in the directory `dir`, in this
  order.

  Returns `None` if no version is found.
  """

  # Probe `CMakeLists.txt`
  path = dir + "/CMakeLists.txt"
  if os.path.isfile(path):
    with io.open(path, mode="r") as file:
      content = file.read()
      match = re.search(r"^\s*project\(.*\s+VERSION\s+([0-9.]+)", content, re.MULTILINE)
      if match:
        version = match.group(1)
        return version

  # Probe `Cargo.toml`
  path = dir + "/Cargo.toml"
  if os.path.isfile(path):
    with io.open(path, mode="r") as file:
      o = toml.load(file)
      if "package" in o and "version" in o["package"]:
        return o["package"]["version"]

  # Probe `gaia-project.json`
  path = dir + "/gaia-project.json"
  if os.path.isfile(path):
    with io.open(path, mode="r") as file:
      o = json5.load(file)
      if "version" in o:
        return o["version"]

  return None

def print_configurations(dir: str, preset: str) -> None:
  """
  Prints the result of `get_configurations`, separated by spaces.
  """

  print(" ".join(get_configurations(dir, preset)), end="")

def print_version(dir: str) -> None:
  """
  Prints the result of `get_version`.
  """

  print(get_version(dir), end="")

# EOF
