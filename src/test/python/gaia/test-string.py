#!/usr/bin/env python3
#
# test-string.py
#

import unittest

from gaia.string import *

# Tests -----------------------------------------------------------------------------------------------------

class TestString(unittest.TestCase):
  def testCapitalize(self):
    self.assertEqual(capitalize("hello"), "Hello")

  def testCapitalizeUnicode(self):
    self.assertEqual(capitalize("ärger"), "Ärger")

  def testRemoveLeading(self):
    self.assertEqual(removeLeading("", "hello"), "")
    self.assertEqual(removeLeading("hello", ""), "hello")
    self.assertEqual(removeLeading("hhello", "x"), "hhello")
    self.assertEqual(removeLeading("hhello", "h"), "hello")

  def testRemoveTrailing(self):
    self.assertEqual(removeTrailing("", "hello"), "")
    self.assertEqual(removeTrailing("hello", ""), "hello")
    self.assertEqual(removeTrailing("helloo", "x"), "helloo")
    self.assertEqual(removeTrailing("helloo", "o"), "hello")

  def testRemoveTrailingUnicode(self):
    self.assertEqual(removeTrailing("hellö", "ö"), "hell")

  def testUncapitalize(self):
    self.assertEqual(uncapitalize("Hello"), "hello")

  def testUncapitalizeUnicode(self):
    self.assertEqual(uncapitalize("Ärger"), "ärger")

# Main ------------------------------------------------------------------------------------------------------

if __name__ == "__main__":
  unittest.main()

# EOF
