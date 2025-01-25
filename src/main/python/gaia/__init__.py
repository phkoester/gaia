#
# __init.py__
# 
# Module `gaia`.
#

import io
import json5
import os
import semver
import toml

def get_version(dir: str) -> str | None:
  """
  Tries to retrieve a version from the file `project.json` in the directory `dir`.
  
  If needed, other files such as `Cargo.toml` are read.

  Returns `None` if no version is found.
  """

  # Read `project.json`
  path = dir + "/project.json"
  with io.open(path, mode="r") as file:
    o = json5.load(file)
    version = o["version"]
    if version:
      # Link to another file?
      if version.startswith("@"):
        path = dir + "/" + version[1:]
        if path.endswith("/Cargo.toml"):
          # Read `Cargo.toml`
          with io.open(path, mode="r") as file:
            o = toml.load(file)
            return o["package"]["version"]
        else:
            return None
      else:
        return version
    else:
      return None

def print_version(dir: str) -> None:
  """
  Prints the result of `get_version`.
  """
  
  print(get_version(dir), end="")

def write_version_header(path: str, version_name: str, version: str) -> None:
  """
  Writes a C/C++ version header to a file located at `path`.
  """
  
  file_name = os.path.basename(path)
  v = semver.parse_version_info(version)

  with io.open(path, mode="w") as file:
    file.write(
f"""/*
 * {file_name}
 *
 * GENERATED FILE. DO NOT EDIT.
 */

#pragma once

// SemVer string
#define {version_name}_INFO "{version}"
// Major, minor (4 decimal digits), patch (4 decimal digits)
#define {version_name} {v.major}{v.minor:04d}{v.patch:04d}UL
 
// EOF
""");

# EOF
