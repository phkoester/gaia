#
# __init.py__
#

import io
import json5
import os
import re
import semver
import toml

def get_version(dir: str) -> str | None:
  """
  Tries to retrieve a project version in the directory `dir`.

  The function probes `CMakeLists.txt`, `Cargo.toml`, and `gaia-project.json` in the directory `dir`, in this
  order.

  Returns `None` if no version is found.
  """

  # Probe `CMakeLists.tst`
  path = dir + "/CMakeLists.txt"
  if os.path.isfile(path):
    with io.open(path, mode="r") as file:
      content = file.read()
      match = re.search(r"\s*project\(.*\s+VERSION\s+([0-9.]+)", content)
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

def print_version(dir: str) -> None:
  """
  Prints the result of `get_version`.
  """

  print(get_version(dir), end="")

# EOF
