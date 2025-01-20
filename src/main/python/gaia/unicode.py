#
# @file unicode.py
#
# Unicode utilities.
#

import gaia.shell
import gaia.string

from typing import TextIO, List

# Local functions -------------------------------------------------------------------------------------------

def _printHeader(file: TextIO, name: str):
  file.write(f"/*\n * {name}\n *\n * This is a generated file. Do not edit.\n */\n\n")
  
def _printIncludes(file: TextIO, includes: List[str]):
  for include in includes:
    file.write(f"#include {include}\n")
  file.write("\n")

# Functions -------------------------------------------------------------------------------------------------

def parseEastAsianWidth(input: str, output: str) -> None:
  """
  Parses @p input and prints to @p output.

  @param input input file
  @param output output file
  """

  with open(output, "w") as outFile:
    _printHeader(outFile, output)
    _printIncludes(outFile, [
      '<iostream>',
      '"rocket/internal/unicode-internal.h"'
    ])

    outFile.write(
        "using namespace std;\n\n"
        "namespace rocket::unicode::internal {\n\n"
        "const vector<EastAsianWidthBlock> eastAsianWidthBlocks = {\n")
    
    with open(input, "r") as inFile:
      for line in inFile:
        line = line.strip()
        if len(line) == 0 or line[0:1] == "#":
          continue
        tokens = line.split(" ")
        tokens = list(filter(None, tokens))

        lower, upper = None, None
        codes = tokens[0].split("..")
        if len(codes) >= 1:
          lower = int("0x" + codes[0], 16)
        if len(codes) >= 2:
          upper = int("0x" + codes[1], 16) + 1 # Right-open interval, hence `+ 1`
        else:
          upper = lower + 1
        
        eaw = None
        match tokens[2]:
          case "F": eaw = "fullWidth"
          case "H": eaw = "halfWidth"
          case "W": eaw = "wide"
          case "Na": eaw = "narrow"
          case "A": eaw = "ambiguous"
          case "N": eaw = "neutral"
          case _: gaia.shell.error(f"Invalid width: ${tokens[2]}")

        outFile.write(f"  {{ {{ {lower:#08x}U, {upper:#08x}U }}, EastAsianWidth::{eaw} }},\n")

    outFile.write(
        "};\n\n"
        "} // namespace rocket::unicode::internal\n\n"
        "// EOF\n")

def parseEmoji(input: str, output: str) -> None:
  """
  Parses @p input and prints to @p output.

  @param input input file
  @param output output file
  """

  with open(output, "w") as outFile:
    _printHeader(outFile, output)
    _printIncludes(outFile, [
      '<iostream>',
      '"rocket/internal/unicode-internal.h"'
    ])

    outFile.write(
        "using namespace std;\n\n"
        "namespace rocket::unicode::internal {\n\n")
    
    emoji = None
    
    with open(input, "r") as inFile:
      for line in inFile:
        line = line.strip()
        if len(line) == 0 or line[0:1] == "#":
          continue
        tokens = line.split(" ")
        tokens = list(filter(None, tokens))

        lower, upper = None, None
        codes = tokens[0].split("..")
        if len(codes) >= 1:
          lower = int("0x" + codes[0], 16)
        if len(codes) >= 2:
          upper = int("0x" + codes[1], 16) + 1 # Right-open interval, hence `+ 1`
        else:
          upper = lower + 1
        
        # Change vector?
        newEmoji = gaia.string.removeTrailing(tokens[2], "#")
        if newEmoji != emoji:
          if emoji != None:
            # End old vector
            outFile.write("};\n\n")
          # Begin new vector
          outFile.write(f"const vector<EmojiBlock> emojiBlocks{newEmoji} = {{\n")
          emoji = newEmoji

        outFile.write(f"  {{ {{ {lower:#08x}U, {upper:#08x}U }} }},\n")

    outFile.write(
        "};\n\n"
        "} // namespace rocket::unicode::internal\n\n"
        "// EOF\n")

# EOF
