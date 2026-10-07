"""Recompute bytes/cycles; efficiency factors and engine throughput are hypotheses."""
import argparse
import json
import math
from pathlib import Path
from models import burst_plan


def calculate(camera_fps=60.0):
    if not math.isfinite(camera_fps) or camera_fps < 0:
        raise ValueError('camera fps must be finite and nonnegative')
    n=1280*720; ui=96000000; pixel=74400000
    display_fps=pixel/(1650*750)
    c=n//4; m=n//8
    physical=16//8*384000000*2
    axi=128//8*ui
    nominal_video=2*n*60
    clock_video=n*(camera_fps+display_fps)
    assert physical==axi==1536000000 and c==230400 and m==115200
    scenarios=[]
    for burst,arb,row,refresh in ((.7,.6,.85,.98),(.85,.8,.9,.98),(.95,.9,.95,.99)):
        service=min(physical,axi)*burst*arb*row*refresh
        scenarios.append(dict(burst_efficiency=burst,arbitration_factor=arb,row_bank_factor=row,refresh_factor=refresh,aggregate_Bps=service,twenty_percent_guard_Bps=service*.2,residual_after_guard_and_video_Bps=max(0,service*.8-clock_video),measured=False,guaranteed=False))
    return dict(units='decimal B/s and seconds; allocations elsewhere use binary MiB',width=1280,height=720,pixels=n,ui_clock_hz=ui,engine_clock_hz_assumed=ui,engine_pixels_per_cycle_assumed=1,ddr_clock_hz=384000000,ddr_data_rate_MTps=768,axi_bits=128,ddr_bits=16,physical_shared_peak_Bps=physical,axi_each_direction_peak_Bps=axi,read_write_peaks_must_not_be_added=True,pixel_clock_hz=pixel,display_fps_design=display_fps,camera_fps_assumed=camera_fps,camera_fps_measured=None,nominal60_camera_Bps=n*60,nominal60_hdmi_Bps=n*60,nominal60_video_Bps=nominal_video,clock_based_video_Bps=clock_video,nominal_video_peak_fraction=nominal_video/physical,class_bytes=c,mask_bytes=m,capture_bytes=c,capture_active_Bps=pixel/4,capture_one_frame_average_Bps=c*display_fps,initialization_read_bytes=c,initialization_write_bytes=m,per_scan_read_bytes=c+m,per_scan_write_bytes=m,per_scan_total_bytes=c+2*m,per_pair_total_bytes=2*(c+2*m),final_copy_read_bytes=m,final_copy_write_bytes=m,metadata_mirror_B_per_job_assumed=1024,job_fixed_bytes=2*c+3*m+1024,future_mask_display_Bps=m*display_fps,four_video_buffers_multiplier=1,four_video_metadata_DDR_bytes=0,class_variable_bursts=len(burst_plan(1<<24,c)),mask_variable_bursts=len(burst_plan(1<<24,m)),class_fixed128_padded_bytes=((c+2047)//2048)*2048,mask_fixed128_padded_bytes=((m+2047)//2048)*2048,class_row_bursts=sum(len(burst_plan((1<<24)+y*320,320)) for y in range(720)),mask_row_bursts=sum(len(burst_plan((1<<24)+y*160,160)) for y in range(720)),safe_global_budget_measured_Bps=None,efficiency_scenarios=scenarios,source_of_idle_ratio='UNMEASURED; existing command RR is not occupancy/QoS measurement')


def execute(out,model_path,camera_fps):
    b=calculate(camera_fps)
    for invalid in (-1.0,float('nan'),float('inf')):
        try: calculate(invalid)
        except ValueError: pass
        else: raise AssertionError('invalid camera fps accepted')
    cases=[]
    tests=json.loads(model_path.read_text(encoding='utf-8'))['cases']
    for r in tests:
        if r['pixels']!=921600: continue
        scans=r['raster_scans']; jacobi=r['jacobi_scans']
        total=b['job_fixed_bytes']+scans*b['per_scan_total_bytes']
        assert total==r['total_job_bytes']+b['metadata_mirror_B_per_job_assumed']
        target=[]
        for fps in (1,2,5):
            target.append(dict(fps=fps,global_Bps=total*fps,global_over_nominal_video_fraction=total*fps/b['nominal60_video_Bps'],global_over_physical_peak_fraction=total*fps/b['physical_shared_peak_Bps']))
        # Initialization + scans + final copy at one pixel/cycle. No invented P&R result.
        compute=(scans+2)*921600/96000000
        budgets=[]
        for budget in (25000000,50000000,100000000):
            ddr=total/budget
            budgets.append(dict(assumed_global_budget_Bps=budget,transfer_seconds=ddr,compute_seconds=compute,capture_seconds=1/b['display_fps_design'],optimistic_overlap_seconds=max(ddr,compute)+1/b['display_fps_design'],serialized_estimate_seconds=ddr+compute+1/b['display_fps_design'],guaranteed_wall_clock_bound=False))
        cases.append(dict(name=r['name'],scans=scans,pairs=scans//2,job_bytes=total,jacobi_job_bytes=b['job_fixed_bytes']+jacobi*b['per_scan_total_bytes'],jacobi_compute_seconds=(jacobi+2)*921600/96000000,targets=target,time_scenarios=budgets))
    b['cases']=cases
    b['invalid_camera_rate_rejections']=3
    b['algorithm_bound']=dict(weak_pixels_max=921599,jacobi_scans_bound=921600,raster_pairs_bound=921600,raster_scans_bound=1843200,kind='loose finite monotonic bound, not achievable-FPS claim')
    out.mkdir(parents=True,exist_ok=True)
    (out/'BANDWIDTH_MODEL.json').write_text(json.dumps(b,indent=2),encoding='utf-8')
    lines=['# 带宽与时延复算','','**安全可用业务预算未知；不能据峰值证明720p60不阻塞，也不能保证1～2fps。** 所有字节与扫描计数可复算；效率和1像素/96MHz周期为未综合假设。','',f"实际UI=96MHz，128bit每方向理论{b['axi_each_direction_peak_Bps']/1e9:.3f}GB/s。DDR x16、384MHz、768MT/s，共享读写峰同为1.536GB/s，不能相加。core=192MHz不是用户AXI频率。",'',f"名义720p60：相机55.296MB/s，HDMI55.296MB/s，总110.592MB/s，占共享峰7.2%。设计像素74.4MHz/(1650×750)={b['display_fps_design']:.9f}fps；相机默认60fps是假设而非实测，组合{b['clock_based_video_Bps']/1e6:.6f}MB/s。相机100MHz STA约束不是相机帧率测量。四缓冲只轮换地址，不把读写乘4。",'',f"捕获2b图230400B；初始化R230400+W115200B；每方向扫描R345600+W115200=460800B；每双向轮921600B；收敛后复制结果R115200+W115200B；元数据按1024B/job假设（可用片上寄存器替代）。job=807424+460800×扫描数 B。未来60.1212fps读取1b掩码另加{b['future_mask_display_Bps']/1e6:.6f}MB/s，本轮未接显示。",'',f"分类图瞬时活动数据产生速率18.6MB/s，捕获帧平均{b['capture_one_frame_average_Bps']/1e6:.6f}MB/s。低频平均开销不能代替采集期间峰值及FIFO停服时间预算。",'', '|图案|扫描/轮|单job MB|1fps MB/s|2fps MB/s|5fps MB/s|仅计算下限s|','|---|---:|---:|---:|---:|---:|---:|']
    for r in cases:
        lines.append(f"|{r['name']}|{r['scans']}/{r['pairs']}|{r['job_bytes']/1e6:.6f}|{r['job_bytes']/1e6:.6f}|{r['job_bytes']*2/1e6:.6f}|{r['job_bytes']*5/1e6:.6f}|{r['time_scenarios'][0]['compute_seconds']:.6f}|")
    lines+=['','横蛇362扫描/181双向轮；竖蛇642扫描/321双向轮。对应Jacobi 460441/460161扫描的流量与计算时间见JSON。双向扫描即使无DDR等待，含初始化/最终复制的计算下限仍为3.4944/6.1824秒，不能对所有图像达到1fps。64双向轮或1秒wall watchdog（谁先到）会安全失败，不发布截断图。全局理论有限性不等于可接受最坏时延。','', '每全帧连续扫描可用分类113个burst（末64拍）/mask57个burst（末32拍）；强制旧128拍填充将分别增为231424/116736B。按4KiB分配为233472/118784B。反向扫描仍发递增AXI INCR burst，把每行缓存后倒序消费；每行20拍/10拍，跨4KiB再拆。不能发非法反向INCR地址或将行短burst效率等同连续全帧。',f"逐行请求数（含4KiB拆分）：class={b['class_row_bursts']}，mask={b['mask_row_bursts']}，每扫读class+读mask+写mask；平均有效拍数显著小于128。全帧连续模型给字节下限，效率情景另计仲裁/行切换/刷新。",'', '效率情景不是测量：Bservice=min(DDR峰,AXI峰)×ηburst×ηarb×ηrow×ηrefresh；再留20%守备并扣视频。JSON分别列三组参数，不将任何组命名为safe预算。25/50/100MB/s低频预算下，Tcompute=(扫描+初始化+最终复制)×921600/96MHz；与Tbytes分别给完全重叠下限和串行估计，仍缺最大服务延迟保证。serialized_estimate_seconds不含未建模额外stall，不是最坏wall上界。','', '实时QoS阻断：新增客户端需计量FIFO最低/最高水位、相机写等待、显示读等待、R/B响应、校准刷新和跨bank冲突的最大停服周期。读优先/写优先阈值须从实际FIFO端口提取并计算guard，不仅看平均MB/s。当前可证明闲置比例仅有0～理论剩余上界，不能认证任意正的无阻塞余量。','', '复算：python -B calculate_bandwidth.py --output <新结果目录> --camera-fps 60。不读取旧报告流量常数代替本轮源证据。']
    (out/'BANDWIDTH_AND_LATENCY.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    print('BANDWIDTH PASS arithmetic; safe measured budget null')

if __name__=='__main__':
    p=argparse.ArgumentParser(); p.add_argument('--output',type=Path,default=Path(__file__).parent);p.add_argument('--models',type=Path,default=Path(__file__).parent/'MODEL_RESULTS.json');p.add_argument('--camera-fps',type=float,default=60);a=p.parse_args();execute(a.output,a.models,a.camera_fps)
