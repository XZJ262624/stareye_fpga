# V4 import failure and V4.1 boundary

The received V4 compatibility export's actual `logs/00_COMPILE.log` reports `ModuleNotFoundError: No module named 'current_inputs'` at work/portable/stage.py line4, before compilation. The real filenames are stage.py/current_inputs.py. Neither an RTL simulation result nor a deadline-gate failure was produced by that run.

V4.1 adds only an explicit helper search path derived from stage.py's resolved parent. Its manifest/version changes accordingly. All other104-file-manifest entries except stage.py remain byte-identical (103 unchanged); all63 execution source files, workload, checks, timeouts and UART format are unchanged. V4 originals and failed export are preserved.

Local Python isolated mode `-I` reproduces the old import failure. New stage.py under `-I` enters actual compilation and100us startup. Local10.1c compatibility uses a separately recorded adapter replacing the2020.4 optimization argument with novopt; native arguments and receipts retain this fact. This is analogous isolation coverage, not execution in the reported remote official embeddablePython3.13.16 environment. Remote2020.4 and that Python environment must run the new fixed package themselves.

Compatibility and full_video use separate new run/work directories. The full case includes its own compile and compatibility steps. Reusing a work directory with existing CURRENT_INPUTS records deliberately fails rather than overwriting prior measurements. No source/runtime environment or machine security policy is changed.
