from pathlib import Path
import ctypes,os,sys
D=Path(__file__).resolve().parent.parent/'resource_area_experiment/alias_diagnostic';os.chdir(D);os.add_dll_directory('E:/Efinity/2025.1/bin');a=ctypes.CDLL('E:/Efinity/2025.1/bin/libabc.dll');a.Abc_Start.argtypes=[];a.Abc_FrameGetGlobalFrame.restype=ctypes.c_void_p;a.Cmd_CommandExecute.argtypes=[ctypes.c_void_p,ctypes.c_char_p];a.Cmd_CommandExecute.restype=ctypes.c_int;a.Abc_Stop.argtypes=[]
a.Abc_Start.restype=None;a.Abc_Stop.restype=None;a.Abc_FrameGetGlobalFrame.argtypes=[]
a.Abc_Start();f=a.Abc_FrameGetGlobalFrame()
for name in [sys.argv[1]]:
 print('BEGIN_PROOF',name,flush=True)
 for cmd in ['read_blif '+name,'strash','print_stats','sat -C 100000 -I 10000000']:
  print('ABC_COMMAND',cmd,flush=True);rc=a.Cmd_CommandExecute(f,cmd.encode());print('ABC_COMMAND_EXIT',rc,flush=True);assert rc==0
 print('END_PROOF',name,flush=True)
a.Abc_Stop()
