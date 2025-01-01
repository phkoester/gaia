#!/usr/bin/env python3
#
# test-list.py
#

import unittest

from gaia.list import *

# Tests -----------------------------------------------------------------------------------------------------

class TestList(unittest.TestCase):
  def testPurgeIn(self):
    l = [ 1, 2, 1, 2, 4, 3, 3, 4, 4, 1, 1 ]
    purgeIn(l)
    self.assertEqual(l, [1, 2, 4, 3])

# Main ------------------------------------------------------------------------------------------------------

if __name__ == "__main__":
  unittest.main()

# EOF
