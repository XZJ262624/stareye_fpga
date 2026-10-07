# M5C接口预留（无融合实现）

只输出全局mask及可判断来源/新旧程度的descriptor，M5B不计算static_mask，不执行局部全局OR，不做目标识别。

|字段|宽度/定义|
|---|---|
|schema_version/algorithm_version|16/16bit，标识打包与NMS/hysteresis定义|
|epoch/frame_id|64/64bit，同一次回放帧及配置；可选camera_capture_id另带valid|
|buffer_id/base/byte_count/row_stride|1/32/32/32bit；1b mask，115200B，160B/行，16B拍对齐|
|width/height/support_radius|16/16/8bit；1280/720、默认median3/旁路2，表示分类有效边界|
|ready/converged/valid|1bit各；valid=>ready&&converged&&epoch一致&&error=0；ready握手非裸脉冲|
|age_frames/age_valid|32bit饱和+1bit，消费域同epoch回放frame_id差；无证据不得假设0|
|threshold_high/threshold_low|8/8bit，来自snapshot已生效config，L=floor(H/2)|
|median_enable/display_mode|1/3bit，来自同帧packet|
|timeout/error_code/failed_job_id|1/16/64bit，失败job独立状态，不篡改上一成功descriptor|
|pair_count/scan_count/capture_tick/complete_tick|32/32/64/64bit，诊断与时延；时间基准注明UI clock|
|lease_request/lease_ack/release_ack|整descriptor握手，保证消费期DDR内容冻结|

可选mask顺序流：`valid/ready, sof,eol,eof,x[11:0],y[11:0],edge,epoch,frame_id`；metadata仅在SOF锁存并保持整帧。DDR突发reader可以流控自身，但将来HDMI消费的DE不能暂停，所以M5C若实时使用必须提前缓存并给缺失/age错误定义回退。另一选项是DMA 128-bit打包mask流+descriptor，保持相同坐标/位序。

未来公式可表达为 `local_strong OR (local_weak AND global_support AND static_mask)`，但static_mask与global_support有效性须由M5C单独设计验证。源frame_id与当前不同不是“坐标一致就可直接OR”；必须依据age、运动/静态判定和置信有效性决定，失效时回退明确的局部策略。全局结果过旧的阈值属于M5C策略，本轮不编造固定安全帧数，也不把旧mask无条件投到实时移动目标。

复位或epoch变化时消费者立即废弃缓存/lease，重握手；同frame_id不同epoch不相等。frame_id只代表DDR回放帧时，应明确告诉M5C source_kind=`DISPLAY_REPLAY`，避免把它当camera timestamp做运动融合。
