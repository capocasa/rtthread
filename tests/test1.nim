# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest, os
import rtthread

var foo = 0

proc doThread(x: int) {.thread.} =
  foo = 1

var t:Thread[int]
createRealtimeThread(t, doThread, 96, 12345)
joinThreads(t)
assert foo == 1, "basic test"

proc doThread2() {.thread.} =
  foo = 2

var t2:Thread[void]
createRealtimeThread(t2, doThread2, 96)
joinThreads(t2)
assert foo == 2, "void"

