#
# @file __init.py__
# 
# Module `gaia`.
#

import io
import json5
import os
import semver
import toml

def getVersion(dir: str) -> str | None:
  """
  Tries to retrieve a version from the file `project.json` in the directory @p dir. If needed, other files
  such as `Cargo.toml` are read.

  @param dir the directory where `project.json` resides
  @return a version string or `None`
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

def printVersion(dir: str) -> None:
  """
  Prints the result of #getVersion.

  @param dir the directory where `project.json` resides
  """
  
  print(getVersion(dir), end="")

def writeVersionHeader(path: str, versionName: str, version: str) -> None:
  """
  Writes a C/C++ version header at @path.

  @param path path of the file to write
  @param versionName the name of the version
  @param version the version
  """
  
  fileName = os.path.basename(path)
  v = semver.parse_version_info(version)

  with io.open(path, mode="w") as file:
    file.write(
f"""/*
 * {fileName}
 *
 * THIS IS A GENERATED FILE. DO NOT EDIT.
 */

#pragma once

// SemVer string
#define {versionName}_INFO "{version}"
// Major, minor (4 decimal digits), patch (4 decimal digits)
#define {versionName} {v.major}{v.minor:04d}{v.patch:04d}UL
 
// EOF
""");

# EOF
