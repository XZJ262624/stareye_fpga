from pathlib import Path
import hashlib,json,datetime,subprocess,time
R=Path.cwd();B=R/'reports/m5c_pair_capture_20261016';W=B/('pack5_negatives_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir();M=Path('E:/Modelsim_10.1c/win64')
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def native(name,args,cwd):
 with (cwd/(name+'.log')).open('w') as f:
  t=time.time();p=subprocess.Popen(args,cwd=cwd,stdout=f,stderr=subprocess.STDOUT);(cwd/(name+'_OWNER.json')).write_text(json.dumps(dict(pid=p.pid,started=t,command=args)));code=p.wait()
 return code,(cwd/(name+'.log')).read_text(errors='replace')
cases=[('capture_last','capture',"pack[sample_lane*5+:5]<=sample[4:0];","if(position!=WIDTH*HEIGHT-1)pack[sample_lane*5+:5]<=sample[4:0];",'SERVICE_CAPTURE_PAYLOAD_CORRUPT'),('capture_lane','capture','pack[sample_lane*5+:5]<=sample[4:0];','pack[(sample_lane==24?0:sample_lane)*5+:5]<=sample[4:0];','SERVICE_CAPTURE_PAYLOAD_CORRUPT'),('capture_padding','capture','pack[127:125]<=0;','pack[127:125]<=1;','SERVICE_CAPTURE_PAYLOAD_CORRUPT'),('unpack_lane','controller','buffer_read_data[sample_lane*5+:5]','buffer_read_data[(sample_lane==24?0:sample_lane)*5+:5]','PACK5_UNPACK_PIXEL_MISMATCH'),('unpack_word','controller',"read_word<=read_word+1'b1;","read_word<=read_word+2'd2;",'PACK5_UNPACK_PIXEL_MISMATCH')]
results=[]
for name,kind,old,new,fatal in cases[3:]:
 C=W/name;C.mkdir();src=R/('rtl/m5c_pair_diag/m5c_pair_'+kind+'.sv');original=src.read_bytes();text=original.decode();assert text.count(old)==1
 mutant=C/src.name;mutant.write_bytes(text.replace(old,new).encode());assert mutant.read_bytes().replace(new.encode(),old.encode())==original
 if kind=='capture':
  paths=['rtl/m5c_fusion/'+x+'.sv' for x in ['m5b1_mailbox','m5b1_async_fifo','m5b1_transfer','m5c_mask_reader','m5c_bg_mux']]+['rtl/m5c_pair_diag/m5c_pair_controller.sv','rtl/m5c_pair_diag/m5c_pair_arbiter.sv','tb/m5c_fusion/m5c1b_ddr_service_model.sv','tb/m5c_pair_diag/tb_pair_fifo_service_pack5.sv'];top='tb_pair_fifo_service_pack5'
 else:paths=['rtl/m5c_fusion/m5b1_transfer.sv','rtl/m5c_fusion/m5b1_uart.sv','tb/m5c_pair_diag/tb_pair_controller_pack5_oracle_v2.sv'];top='tb_pair_controller_pack5_oracle_v2'
 sources=[R/p for p in paths]+[mutant];(C/'INPUTS.json').write_text(json.dumps([rec(p) for p in sources],indent=2));(C/'DERIVATION.json').write_text(json.dumps(dict(original=rec(src),mutant=rec(mutant),old=old,new=new,inverse_exact=True,expected_fatal=fatal),indent=2))
 code,log=native('vlib',[str(M/'vlib.exe'),'work'],C);assert code==0
 code,log=native('compile',[str(M/'vlog.exe'),'-sv']+[str(p) for p in sources],C);compile_ok=code==0 and '** Error' not in log
 assert compile_ok,log
 code,log=native('sim',[str(M/'vsim.exe'),'-c','-novopt','-wlf','NUL','work.'+top,'-gCASE=0','+OUT='+str(C/'wire.hex'),'-do','run -all; quit -f'],C)
 actual=[x for x in log.splitlines() if '** Fatal:' in x];ok=len(actual)==1 and fatal in actual[0] and '** Error' not in log
 results.append(dict(case=name,compile_exit=0,raw_sim_exit=code,actual_fatal=actual,expected_rejection=ok));(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_NAMED_NEGATIVE' if len(results)==len(cases[3:]) and all(x['expected_rejection'] for x in results) else 'PARTIAL_OR_FAIL',results=results),indent=2));print(name,ok,actual,flush=True)
 if not ok:break
print(W,flush=True)
