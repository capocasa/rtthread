rtthread
========

Rtthread is a small Nim library that allows creating a realtime Nim thread.

Why?
----

Realtime threads are routinely used for realtime digital signal processing such as audio or scientific data, as well as control of analog devices like industrial control or dimming a light or controlling a motor with computer-generated pulse with modulation.

How?
----

Realtime threads behave just like regular threads, they just receive a special parameter on creation. This library has a thread creation function that sets them up, and after that they can be used like any other Nim thread using the normal stdlib tooling.

Usage
-----

```nim
import rtthread, os, posix, posix_utils
var t:Thread[int]

memoryLockAll(MclCurrent)  # prevent swapping

const priority = 94

proc doSomething(x: int) {.thread.} =
  echo x
  sleep 200
  echo x + 1
  sleep 200
  echo x + 2
  sleep 200

createRealtimeThread(t, doSomething, priority, 12345)

echo "started"
joinThread(t)
echo "done"

```

Setup
-----

Realtime privileges require special access. To just give it a try, run the program as root. To use it regularly, the best way on Linux is to add a group "rt" to your system and add this line to `/etc/security/limits.conf`:

```
# /etc/security/limits.conf

@rt -  rtprio     95
@rt -  memlock    unlimited

```

OS Support
----------

Linux works best, other unixes are also supported. Windows is not supported, but could be, using the similar Windows mechanism. The Industrial Windows version would be interesting to support.

Changelog
---------

```
0.2.0  Fix void types. Breaking change, needed to change position of priority parameter for this.
0.1.0  Initial
```
