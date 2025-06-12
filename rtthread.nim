# sorry, got to block import of this module on nonsupporting systems, or code would get a bit complex
when not ((defined(linux) or defined(nintendoswitch))) and defined(amd64):
  {.error "realtime threads require linux or switch on amd64"}

import std/private/[threadtypes]
import std/typedthreads {.all.}

# these are constants so they can just be imported
from posix import SCHED_FIFO, SCHED_PARAM, PTHREAD_EXPLICIT_SCHED

# these are copied from posix so they work identical but use Pthread_attr from threadtypes
proc pthread_attr_setschedparam*(a1: ptr Pthread_attr,
          a2: ptr Sched_param): cint {.importc, header: "<pthread.h>".}
proc pthread_attr_setschedpolicy*(a1: ptr Pthread_attr, a2: cint): cint {.
  importc, header: "<pthread.h>".}
proc pthread_attr_setinheritsched*(a1: ptr Pthread_attr, a2: cint): cint {.
  importc, header: "<pthread.h>".}

# Adapted from system/threadimpl. Any changes must be manually applied here.

proc createRealtimeThread*[TArg](t: var Thread[TArg],
                           tp: proc (arg: TArg) {.thread, nimcall.},
                           priority: cint = 80,
                           param: TArg
                           ) =
  t.core = cast[PGcThread](allocThreadStorage(sizeof(GcThread)))

  when TArg isnot void: t.data = param
  t.dataFn = tp
  when hasSharedHeap: t.core.stackSize = ThreadStackSize
  var a {.noinit.}: threadtypes.Pthread_attr
  doAssert pthread_attr_init(a) == 0
  when hasAllocStack:
    var
      rawstk = allocThreadStorage(ThreadStackSize + StackGuardSize)
      stk = cast[pointer](cast[uint](rawstk) + StackGuardSize)
    let setstacksizeResult = pthread_attr_setstack(addr a, stk, ThreadStackSize)
    t.rawStack = rawstk
  else:
    let setstacksizeResult = pthread_attr_setstacksize(a, ThreadStackSize)

  if pthread_attr_setschedpolicy(a.addr, SCHED_FIFO) != 0:
    raise newException(CatchableError, "cannot assign SCHED_FIFO policy to thread")

  var p: Sched_param
  p.sched_priority = priority
  if pthread_attr_setschedparam(a.addr, p.addr) != 0:
    raise newException(CatchableError, "cannot set thread scheduling priority")
  
  if pthread_attr_setinheritsched(a.addr, PTHREAD_EXPLICIT_SCHED) != 0:
    raise newException(CatchableError, "cannot set PTHREAD_EXPLICIT_SCHED scheduling inheritance")

  if pthread_create(t.sys, a, threadProcWrapper[TArg], addr(t)) != 0:
    raise newException(ResourceExhaustedError, "cannot create thread")

  doAssert pthread_attr_destroy(a) == 0

proc createRealtimeThread*(t: var Thread[void],
                           tp: proc () {.thread, nimcall.},
                           priority: cint = 80
                           ) =
  createRealtimeThread[void](t, tp, priority)
