#!/usr/bin/python

import sys
from brightadjust import BrightAdjust

br = BrightAdjust()

if '+' in sys.argv:
    new = br.getBrightness() + 1
else:
    new = br.getBrightness() - 1

br.adjustBrightness(new)
