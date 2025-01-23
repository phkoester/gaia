#
# unicode.py
#
# Unicode utilities.
#

import gaia.shell
import gaia.string

from typing import TextIO

# Local functions -------------------------------------------------------------------------------------------

def _print_header(file: TextIO, name: str):
  file.write(f"/*\n * {name}\n *\n * THIS IS A GENERATED FILE. DO NOT EDIT.\n */\n\n")
  
def _print_includes(file: TextIO, includes: list[str]):
  for include in includes:
    file.write(f"#include {include}\n")
  file.write("\n")

# Functions -------------------------------------------------------------------------------------------------

def parse_east_asian_width(input: str, output: str) -> None:
  """
  Parses `input` and prints to `output`.
  """

  with open(output, "w") as out_file:
    _print_header(out_file, output)
    _print_includes(out_file, [
      '<iostream>',
      '"rocket/internal/unicode-internal.h"'
    ])

    out_file.write(
        "using namespace std;\n\n"
        "namespace rocket::unicode::internal {\n\n"
        "const vector<EastAsianWidthBlock> eastAsianWidthBlocks = {\n")
    
    with open(input, "r") as in_file:
      for line in in_file:
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

        out_file.write(f"  {{ {{ {lower:#08x}U, {upper:#08x}U }}, EastAsianWidth::{eaw} }},\n")

    out_file.write(
        "};\n\n"
        "} // namespace rocket::unicode::internal\n\n"
        "// EOF\n")

def parse_emoji(input: str, output: str) -> None:
  """
  Parses `input` and prints to `output`.
  """

  with open(output, "w") as out_file:
    _print_header(out_file, output)
    _print_includes(out_file, [
      '<iostream>',
      '"rocket/internal/unicode-internal.h"'
    ])

    out_file.write(
        "using namespace std;\n\n"
        "namespace rocket::unicode::internal {\n\n")
    
    emoji = None
    
    with open(input, "r") as in_file:
      for line in in_file:
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
        new_emoji = gaia.string.remove_trailing(tokens[2], "#")
        if new_emoji != emoji:
          if emoji != None:
            # End old vector
            out_file.write("};\n\n")
          # Begin new vector
          out_file.write(f"const vector<EmojiBlock> emojiBlocks{new_emoji} = {{\n")
          emoji = new_emoji

        out_file.write(f"  {{ {{ {lower:#08x}U, {upper:#08x}U }} }},\n")

    out_file.write(
        "};\n\n"
        "} // namespace rocket::unicode::internal\n\n"
        "// EOF\n")

# EOF
