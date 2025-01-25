#
# shell.py
#
# Shell utilities.
#

import gaia.log
import gaia.path
import locale
import os
import re
import signal
import sys
import subprocess
import traceback

from os import environ as env
from typing import NoReturn

# Variables -------------------------------------------------------------------------------------------

_inv_name = os.path.basename(sys.argv[0]) # Invocation name

# Functions -------------------------------------------------------------------------------------------------

def error(msg: str, exit_status: int = 1, stack_trace=True) -> None:
  """
  Prints the error message `msg` to `sys.stderr` and exits if `exit_status` is not 0.
  """

  sys.stderr.write(f"{_inv_name}: error: {msg}\n")
  if stack_trace:
    stack_trace()
  if exit_status != 0:
    sys.exit(exit_status)

def _get_shebang(file: str) -> list[str]:
  """
  Looks for the file `file`` in `PATH` and tries to read its shebang line.

  Upon success, returns a command line as a string list of the form `["awk", "-f", "file"]`. Otherwise,
  returns `None`
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

def note(msg: str) -> None:
  """
  Prints the note message `msg` to `sys.stdout`.
  """

  sys.stdout.write(f"{_inv_name}: note: {msg}\n")

def _on_sigint(signal, frame) -> NoReturn:
  """
  `SIGINT` handler.

  Calls `os._exit` rather than `sys.exit`, enforcing a cold exit.
  """
  
  # sys.exit(130)
  os._exit(130) # Cold exit

def print_stack_trace() -> None:
  """
  Prints the current stack trace to `sys.stderr`.
  """

  sys.stderr.write("Traceback (most recent call last):\n")
  traceback.print_stack(file=sys.stderr)

def run(*cl, input=None, timeout=None, check=False, **kwargs) -> subprocess.CompletedProcess:
  """
  A wrapper for `subprocess.run`.
  """

  gaia.log.debug(f"{cl=}")
  
# try:
  return subprocess.run(*cl, input=input, timeout=timeout, check=check, **kwargs)
# except OSError:
#   # Excecution failed. We look for a shebang
#   if new_cl := _get_shebang(file):
#     new_cl.extend(cl[0][1:]) # Add all but the first argument to the new command line
#     # We got a new command line: recursive call
#     return run(new_cl, input=input, timeout=timeout, check=check, **kwargs) 
#   raise

def warn(msg: str) -> None:
  """
  Prints the warning message `msg` to `sys.stderr`
  """

  sys.stderr.write(f"{_inv_name}: warning: {msg}\n")

# Main ------------------------------------------------------------------------------------------------------

signal.signal(signal.SIGINT, _on_sigint)

_encoding = locale.getpreferredencoding()
if _encoding not in ["UTF-8", "utf-8"]:
  error(f"Preferred encoding must be `UTF-8` or `utf-8`, but the actual value is `{_encoding}`", 2)

# EOF
