#
# @file shell.py
#
# Shell utilities.
#

import gaia
import inspect
import locale
import os
import re
import signal
import sys
import subprocess
import traceback

from gaia import log
from os import environ as env
from typing import NoReturn

# Local variables -------------------------------------------------------------------------------------------

_name = os.path.basename(sys.argv[0])

# Local functions -------------------------------------------------------------------------------------------

def _getShebang(file: str) -> list[str]:
  """
  Looks for the file @p file in @c PATH and tries to read its shebang line.

  Upon success, returns a command line as a string list of the form <tt>['awk', '-f', 'file']</tt>.
  Otherwise, it returns @c None

  @return upon success, a command line as a string list, otherwise @c None
  """
  file = gaia.path.find(env.get("PATH"), file)
  if not file:
    return None

  with open(file, encoding="utf-8", mode="r") as f:
    line = f.readline().strip()
    if match := re.match(r"^#!(.+)", line):
      cl = match.group(1).split()
      cl.append(file)
      return cl
  
  return None

def _onSigint(signal, frame) -> NoReturn:
  """
  @c SIGINT handler.

  Calls @c os._exit() rather than @c sys.exit(), enforcing a cold exit.

  @param signal provided by the caller
  @param frame provided by the caller
  """
  
  # sys.exit(130)
  os._exit(130) # Cold exit

# Functions -------------------------------------------------------------------------------------------------

def error(msg: str, exitStatus: int = 1, stackTrace=True) -> None:
  """
  Prints the error message @p msg to @c sys.stderr and exits if @p exitStatus is not 0.

  @param msg the error message
  @param exitStatus if not 0, then calls @c sys.exit() with this value
  @param stackTrace if @true, prints the current stack trace to @c sys.stderr
  """

  sys.stderr.write(f"{_name}: error: {msg}\n")
  if stackTrace:
    printStackTrace()
  if exitStatus != 0:
    sys.exit(exitStatus)

def printStackTrace() -> None:
  """
  Prints the current stack trace to @c sys.stderr.
  """

  sys.stderr.write("Traceback (most recent call last):\n")
  traceback.print_stack(file=sys.stderr)

def run(*cl, input=None, timeout=None, check=False, **kwargs) -> subprocess.CompletedProcess:
  """
  A wrapper for @c subprocess.run().
  
  @param cl see @c subprocess.run()
  @param input see @c subprocess.run()
  @param timeout see @c subprocess.run()
  @param check see @c subprocess.run()
  @param kwargs see @c subprocess.run()
  """

  log.debug(f"{cl=}")
  file = cl[0][0]
  cl[0][0] = file
  
# try:
  return subprocess.run(*cl, input=input, timeout=timeout, check=check, **kwargs)
# except OSError:
#   # Excecution failed. We look for a shebang
#   if newCl := _getShebang(file):
#     newCl.extend(cl[0][1:]) # Add all but the first argument to the new command line
#     # We got a new command line: recursive call
#     return run(newCl, input=input, timeout=timeout, check=check, **kwargs) 
#   raise

def warn(msg: str) -> None:
  """
  Prints the warning message @p msg to @c sys.stderr

  @param msg the warning message
  """

  sys.stderr.write(f"{_name}: warning: {msg}\n")

# Main ------------------------------------------------------------------------------------------------------

signal.signal(signal.SIGINT, _onSigint)

_encoding = locale.getpreferredencoding()
if _encoding not in ["UTF-8", "utf-8"]:
  error(f"Preferred encoding must be 'UTF-8' or 'utf-8', but the actual value is '{_encoding}'", 2)

# EOF
