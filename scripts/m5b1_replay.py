"""Replay offline tests; all outputs remain inside approved M5B1 directories."""
from pathlib import Path
import argparse,subprocess,sys
R=Path(__file__).resolve().parents[1];T=R/'tb/m5b1_global_canny';M=Path('E:/Modelsim_10.1c/win64')
def main():
 choices={'directed':['m5b1_directed_sim.py'],'global':['m5b1_global_sim.py'],'system':['m5b1_system_sim.py','m5b1_system_faults.py'],'mutations':['m5b1_mutations.py'],'tap':['m5b1_tap_sim.py'],'qos_negative':['m5b1_qos_negative.py']}
 ap=argparse.ArgumentParser();ap.add_argument('group',choices=['all',*choices],default='all',nargs='?');a=ap.parse_args()
 if not (T/'work').exists():subprocess.run([str(M/'vlib.exe'),str(T/'work')],check=True,capture_output=True)
 jobs=[x for v in choices.values() for x in v] if a.group=='all' else choices[a.group]
 for script in jobs:subprocess.run([sys.executable,'-B',str(R/'scripts'/script)],cwd=R,check=True)
if __name__=='__main__':main()
