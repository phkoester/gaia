#!/usr/bin/env python3
#
# test-string.py
#

import gaia.string
import unittest

# Tests -----------------------------------------------------------------------------------------------------

class TestString(unittest.TestCase):
  def test_capitalize(self):
    self.assertEqual(gaia.string.capitalize("hello"), "Hello")

  def test_capitalize_unicode(self):
    self.assertEqual(gaia.string.capitalize("ärger"), "Ärger")

  def test_remove_leading(self):
    self.assertEqual(gaia.string.remove_leading("", "hello"), "")
    self.assertEqual(gaia.string.remove_leading("hello", ""), "hello")
    self.assertEqual(gaia.string.remove_leading("hhello", "x"), "hhello")
    self.assertEqual(gaia.string.remove_leading("hhello", "h"), "hello")

  def test_remove_trailing(self):
    self.assertEqual(gaia.string.remove_trailing("", "hello"), "")
    self.assertEqual(gaia.string.remove_trailing("hello", ""), "hello")
    self.assertEqual(gaia.string.remove_trailing("helloo", "x"), "helloo")
    self.assertEqual(gaia.string.remove_trailing("helloo", "o"), "hello")

  def test_remove_trailing_unicode(self):
    self.assertEqual(gaia.string.remove_trailing("hellö", "ö"), "hell")

  def test_uncapitalize(self):
    self.assertEqual(gaia.string.uncapitalize("Hello"), "hello")

  def test_uncapitalize_unicode(self):
    self.assertEqual(gaia.string.uncapitalize("Ärger"), "ärger")

# Main ------------------------------------------------------------------------------------------------------

if __name__ == "__main__":
  unittest.main()

# EOF
