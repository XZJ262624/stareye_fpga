from pathlib import Path
import sys,json
from m3_sobel_core_sim import ROOT,REPORT,TB,MODELSIM,run
project=ROOT/'efinity/m3_sobel_core_i3'
run([MODELSIM/'vlog.exe','-sv','-work','work','+incdir+'+(project/'src').as_posix(),project/'ip/R0_FIFO_8/R0_FIFO_8.v',project/'src/lcd_driver.v',TB/'tb_video.sv'],REPORT/'video_vlog.log')
run([MODELSIM/'vsim.exe','-c','-novopt','work.tb_video','-do','onerror {quit -f -code 1}; onbreak {quit -f -code 1}; run -all; quit -f -code 0'],REPORT/'video.log')
log=(REPORT/'video.log').read_text(errors='replace')
assert 'HDL_VIDEO_PASS frames=2 inputs=1843200 outputs=1843200 windows=1835208' in log,log[-3000:]
(REPORT/'video_summary.json').write_text(json.dumps({'pass':True,'frames':2,'input_pixels':1843200,'output_de_pixels':1843200,'valid_windows':1835208,'resolution':[1280,720],'actual_vendor_fifo':True,'actual_vendor_lcd_driver':True,'mode':'binary','threshold':64,'sync_latency_sampling_stages':5},indent=2))
print('M3_VIDEO_SIM_PASS')
