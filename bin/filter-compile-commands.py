#!/usr/bin/env python3
#
# filter-compile-commands.py
#

"""
Filter compile_commands.json by regex pattern.

This script reads a compile_commands.json file, splits it into blocks (one per compilation command), and
filters blocks matching a regular expression pattern.

Usage:
  filter-compile-commands.py [OPTIONS] -i INPUT_FILE -o OUTPUT_FILE PATTERN

Arguments:
  PATTERN  Regular expression pattern to match against

Options:
  -i, --in IN        Input file path (required)
  -o, --out OUT      Output file path (required)
      --field FIELD  Field to match against: 'file' (default), 'command', 'directory', or 'all'
      --invert       Invert the filter (keep non-matching blocks)
      --help         Show this help message
"""

import argparse
import json
import re
import sys

from pathlib import Path

def filter_compile_commands(input_file, output_file, pattern, field='file', invert=False):
  # Read input file

  input_path = Path(input_file)
  if not input_path.exists():
    print(f"Error: Input file '{input_file}' does not exist", file=sys.stderr)
    return 1

  try:
    with open(input_path, 'r', encoding='utf-8') as f:
      data = json.load(f)
  except json.JSONDecodeError as e:
    print(f"Error: Invalid JSON in '{input_file}': {e}", file=sys.stderr)
    return 1
  except Exception as e:
    print(f"Error: Failed to read '{input_file}': {e}", file=sys.stderr)
    return 1

  if not isinstance(data, list):
    print(f"Error: Expected JSON array, got {type(data).__name__}", file=sys.stderr)
    return 1

  # Compile regex pattern

  try:
    regex = re.compile(pattern)
  except re.error as e:
    print(f"Error: Invalid regular expression '{pattern}': {e}", file=sys.stderr)
    return 1

  # Filter entries

  # original_count = len(data)
  filtered_data = []

  for entry in data:
    if not isinstance(entry, dict):
      print(f"Warning: Skipping non-dict entry: {entry}", file=sys.stderr)
      continue

    match_found = False

    if field == 'all':
      # Match against all string fields
      for key, value in entry.items():
        if isinstance(value, str) and regex.search(value):
          match_found = True
          break
    elif field in entry:
      # Match against specific field
      value = entry[field]
      if isinstance(value, str):
        match_found = regex.search(value) is not None
      else:
        # Convert non-string to string for matching
        match_found = regex.search(str(value)) is not None
    else:
      # Field doesn't exist in entry
      match_found = False

    # Apply filter (with optional inversion)
    if (match_found and not invert) or (not match_found and invert):
      filtered_data.append(entry)

  # Write output

  output_path = Path(output_file)
  try:
    with open(output_path, 'w', encoding='utf-8') as f:
      json.dump(filtered_data, f, indent=2)
  except Exception as e:
    print(f"Error: Failed to write '{output_path}': {e}", file=sys.stderr)
    return 1

  # kept_count = len(filtered_data)
  # removed_count = original_count - kept_count

  # print(f"Filtered {original_count} entries:")
  # print(f"  Kept:    {kept_count}")
  # print(f"  Removed: {removed_count}")
  # print(f"Output written to: {output_path}")

  return 0

def main():
  parser = argparse.ArgumentParser(
    description='Filter compile_commands.json by regex pattern',
    formatter_class=argparse.RawDescriptionHelpFormatter,
    epilog=__doc__
  )
  parser.add_argument(
    "-i", "--in",
    dest='input_file',
    required=True,
    help='Input file path (required)'
  )
  parser.add_argument(
    "-o", "--out",
    dest='output_file',
    required=True,
    help='Output file path (required)'
  )
  parser.add_argument(
    '--field',
    choices=['file', 'command', 'directory', 'all'],
    default='file',
    help="Field to match against (default: 'file')"
  )
  parser.add_argument(
    '--invert',
    action='store_true',
    help='Invert the filter (keep non-matching blocks)'
  )
  parser.add_argument(
    'pattern',
    help='Regular expression pattern to match against'
  )

  args = parser.parse_args()

  return filter_compile_commands(
    args.input_file,
    args.output_file,
    args.pattern,
    field=args.field,
    invert=args.invert
  )

if __name__ == '__main__':
  sys.exit(main())

# EOF
