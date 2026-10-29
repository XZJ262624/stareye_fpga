# 本轮实际差异（技术父 open；不是回放 HEAD）

|位置|改动|保持/证据|
|---|---|---|
|part_keys_controls|沿用两级同步/释放复位/20ms防抖；释放事件立即发出，移除父SOF单槽出队；事件1/2/3/4分别减/加/view/诊断|单长释放一次；交错双键抑制single；29真实释放事件定向验证|
|part_keys_config（新增）|pending H/view，source SOF原子提交；64bit递增generation与same-edge旁路|H48/L24默认，8..128步8饱和；view/无变化不增代；source-SOF同拍新release下一帧应用|
|part_keys_adapter|原256位tag顶端新增8位H+1位view；原身份/资格/队列逻辑不改|在原source_first入队/原final_first旁路取出，视频链无新延迟|
|part_keys_core|generation从固定1改为配置输入；cfg上下文变化撤旧；移除旧single-view逻辑；诊断rearm映射双长4|原CCL、frameguard和capture直接实例化；诊断记录布局保持，schema为454b5901|
|part_keys_confirm|只有config变化不再清have_value（保LAST）；module重命名|epoch变化仍清LAST；valid/confirmations/matching清理及原三次确认算法保持|
|part_keys_osd|Hxxx/Lxxx动态3位数；MSK名；aligned H/view随帧锁定|原closing白色边缘，不改为实心填充；原图/ROI框/计数/诊断布局保持|
|part_keys_system / new example_top / XML|接真实阈值、配置代、对齐H/view，新模块引用|720p、GAU2、AR0135左右方向、DDR/FIFO/接口/时钟/引脚原样；SDC/periphery/IP逐字同|
|父CCL/morph/frameguard/capture/bankRAM|不复制不修改，直接复用同路径同字节|PRODUCTION_MANIFEST和PARENT_PRODUCTION_MANIFEST逐项SHA；E4/E5/E9保持关闭，无替代图像门|

失败纠正均保留原日志：初次宿主DLL启动限制改为已授权原生执行；新源码十六进制三目空格/提前view声明编译错误纠正；OSD标签49字节被截首字符由软件oracle发现，生产字符串改48字节（断言未改）。OSD极值205557原生已过但收据未包含.mem输入，205625仅修测试runner输入SHA记录后重跑同短测；没有所谓TB路径错误或被放宽的预期。
