# M5B.1真实UART导出与BFS验收通过（稳定性仍PENDING）

Candidate `8976a276f03b4cd146c451aa081b04f71637fcf2`；原始数据与归档机器结果见`HARDWARE_UART_VERIFICATION_225827.json`。本次仅离线读用户已保存文件，未打开串口或操作硬件。

用户保存原始文件`m5b1_COM13_20261011_225827_205.bin`，380405B，SHA256 `b888c1d0956629813680f309bf939aa0f7b5827502def13b7942aa39c4b8bfe0`。记录器元数据：COM13、460800-8-N-1、无流控、USER_STOPPED无error；北京时间2026-10-11 22:58:27.275至23:00:31.249，录制123.974秒。该区间不是30分钟稳定性，也不是精确JTAG完成时刻。

## 原始流边界

严格从offset0解包失败（header/version/reserved），开头字节为FF，首SM5B位于offset1。正常解包工具显式重同步只跳过[0,1)；未静默处理。随后对原始文件offset1到EOF整个剩余流重新严格解包：**无重同步、无末尾截断容忍、全部CRC通过**。唯一前置FF来源未知，不能宣称已证明它是下载噪声；后续稳定性记录继续观察是否有丢字节/CRC错误。

## 真实导出与算法

- 完整统计107包、分类1包、结果1包（共109）。分类载荷230400B、结果115200B，包头/长度与CRC校验通过。
- 分类/结果完整descriptor一致：epoch1/frame34/job1，source_sof_pixel_ticks75489148，high64/low32、median1、support_radius3、nms_version1、1280×720、capture_success=true。
- 软件对真实分类图做完整八邻域BFS，与实物结果**921600像素逐bit完全一致**，边缘像素33352。
- 分类载荷CRC32 `169fc2dc`，结果载荷CRC32 `dfc30e22`；不混淆载荷CRC与包头+载荷的传输CRC。

## 全部统计

首job1，末job107；requests114、accepted107、busy_rejected7、capture_drop0、published107。busy_rejected是已有单job忙时拒绝计数，不等同DDR错误。

所有107份统计system_status=3（校准done/pass，未stop/quarantine），job_fault_flags=0、epoch1；FIFO sticky、B/RRESP、ID、LAST、range/permission、epoch、watchdog与local cancel的样本最大值均0。相机水位最高2144B，显示最低0、分类最高576B；不能把水位0直接判作underflow。

最大服务C0/C1/C2为209/213/106 UI周期，最大等待206/237/3440 UI周期；当前数据不被扩大为所有场景服务上界或fps保证。单帧真实BFS成立，后续107发布统计不能被当作107帧各自BFS已验。

## Work决定

**真实全局Canny首帧导出/同身份/CRC/BFS闸门PASS**；**M5B.1整体验收仍PENDING_30MIN_STABILITY**。已解决LED物理顺序疑点。当前同一次配置可保持运行，并重开记录器收集后续统计；无需为再次记录而重新下载，首对导出已保存。用户需确认从本次JTAG完成后同一次运行连续至少30分钟、七模式/阈值和静态运动共存无异常，再提交后续.bin/.json和总时长。跨PVT/warm restart/硬停限制不因这次通过解除。
