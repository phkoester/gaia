#
# @file log.py
#
# Logging utilities.
#

import gaia
import gaia.enum
import inspect
import sys

from os import environ as env

# `LogLevel` ------------------------------------------------------------------------------------------------

class LogLevel(gaia.enum.OrderedEnum):
  """
  A log-level enum, sorted from lowest to highest level.
  """

  none = 0
  error = 1
  warn = 2
  info = 3
  debug = 4
  trace = 5

# Local variables -------------------------------------------------------------------------------------------

_logLevel = LogLevel.info
_out = sys.stdout

# Functions -------------------------------------------------------------------------------------------------

def error(*args) -> None:
  """"
  If the log level is LogLevel.error or higher, logs the arguments @p args.

  @param args the arguments
  """
  if _logLevel >= LogLevel.error:
    func = inspect.stack()[1][3]
    _out.write(f"[error] [{func}] ");
    print(*args)

def warn(*args) -> None:
  """"
  If the log level is LogLevel.warn or higher, logs the arguments @p args.

  @param args the arguments
  """

  if _logLevel >= LogLevel.warn:
    func = inspect.stack()[1][3]
    _out.write(f"[warn ] [{func}] ");
    print(*args)

def info(*args) -> None:
  """"
  If the log level is LogLevel.info or higher, logs the arguments @p args.

  @param args the arguments
  """

  if _logLevel >= LogLevel.info:
    func = inspect.stack()[1][3]
    _out.write(f"[info ] [{func}] ");
    print(*args)

def debug(*args) -> None:
  """"
  If the log level is LogLevel.debug or higher, logs the arguments @p args.

  @param args the arguments
  """

  if _logLevel >= LogLevel.debug:
    func = inspect.stack()[1][3]
    _out.write(f"[debug] [{func}] ");
    print(*args)

def trace(*args) -> None:
  """"
  If the log level is LogLevel.trace or higher, logs the arguments @p args.

  @param args the arguments
  """

  if _logLevel >= LogLevel.trace:
    func = inspect.stack()[1][3]
    _out.write(f"[trace] [{func}] ");
    print(*args)

# Main ------------------------------------------------------------------------------------------------------

# Read the log level from the environment
if v := env.get("GAIA_LOG_LEVEL"):
  _logLevel = LogLevel[v]

# EOF
