from common import *
p=Path(__file__).parent/'build_physical_v1.py';s=p.read_text();needle="passed=p.returncode==0 and marker and not re.search(r'^\\s*(?:ERROR|Error):',text,re.M)";assert s.count(needle)==1
extra='''
 sdc_text=(P/'Ti60_Demo_I3.sdc').read_text();start_line=next(i+1 for i,l in enumerate(sdc_text.splitlines())if l.startswith('# Standalone foreground-only'))
 constraint_warnings=[l for l in text.splitlines()if 'WARNING' in l and (m:=re.search(r'\\[SDC .*?:(\\d+)\\]',l))and int(m[1])>=start_line]
 save(W/'NEW_CDC_CONSTRAINT_APPLICATION_AUDIT.json',dict(passed=not constraint_warnings,first_new_CDC_line=start_line,warnings=constraint_warnings,log=rec(W/'native.log'),scope='Every new retained foreground CDC command must apply without warning; inherited template unused port warnings remain subject to full check_timing/external audit.'))
 passed=passed and not constraint_warnings
'''
s=s.replace(needle,needle+extra);exec(compile(s,str(p),'exec'))
