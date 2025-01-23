#!/usr/bin/env python3
#
# test-list.py
#

import gaia.list
import unittest

# Tests -----------------------------------------------------------------------------------------------------

class TestList(unittest.TestCase):
  def test_dedup(self):
    l = [ 1, 2, 1, 2, 4, 3, 3, 4, 4, 1, 1 ]
    gaia.list.dedup(l)
    self.assertEqual(l, [1, 2, 4, 3])

# Main ------------------------------------------------------------------------------------------------------

if __name__ == "__main__":
  unittest.main()

# EOF
