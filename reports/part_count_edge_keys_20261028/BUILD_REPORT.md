# 工业计件按键阈值版：离线交付，待 Work 复核和用户独立 A

branch `codex/m5c-fusion-prototype`；基线 HEAD `38d7e42f42ab92f7892072bf18d470445c9d4bd0`，parent `433a83e543cb40a52128d1eea4ae32ce83aecd16`。本轮尚未提交，candidate=None。技术父是 open 已审未提交423项快照（manifest3f566c51...），不是当前回放 HEAD。

默认 RAW/H048/L024。板 K1=N2 单独释放减8，K2=M2 加8；H8..128饱和、L=H/2。单长按只在松开调一次；双短只切 RAW/MSK，双长只重装原诊断。生产防抖1488000个74.4MHz像素拍=20ms。MSK为原closing3x3白色边缘，非实心对象。

真实source SOF同时提交阈值及独立64位配置代；同拍旁路保证前端与身份同值，同SOF恰抵达的释放留到下一SOF。adapter标签带对应帧H/view，OSD锁定此标签，未增视频延迟。每次实际变更撤旧CURRENT/确认/在途结果；ABA回调仍新代，边界无变化和view不动计数代。**唯一确认逻辑改动：config变化保留LAST，epoch变化仍清历史。** CCL、morph、frameguard、capture、DDR/FIFO与帧几何直接复用父源，E4/E5/E9不引回。

定向原生PASS：29次释放事件覆盖连续短、两边饱和、上电按住、抖动、单双长、交错双键、CE及SOF；小ROI真CCL7job验证忙中取消、旧tag、ABA、三确认和LAST。真实生产GAU2+局部Canny+closing+adapter+core+OSD8帧720p，共7372800像素、8真实job、4实际按键；H48→40→32→40及双短view，三次确认恢复5。软件独立oracle闭边5673/6693/7705，弱线32/1052/2064；ROI始终5件。前端阈值逐7372800像素、OSD6471584像素比较通过；额外H008/L004与H128/L064两视图22176像素、帧内锁定/CE通过。fixture不含DDR全链，每帧后加750000 blank拍供CCL完成，不据此声明实际吞吐/低照度效果。

fresh `physical_20261028_205414`：XLR 26087、RAM10 176、DSP 3。基本normal I3各200条setup/hold最小 +0.197/+0.014ns；no_clock/internal_unconstrained/multiple_clock均0，外部未约束输入/输出7/135。19组既有CDC静态逐pin+原生查询及clock correspondence通过，SDC与父逐字同；新配置/adapter/cfg字段均clk_pixel、64位generation实际映射。保留原PLL异步SR、PVT、暖复位和窄hold边界，无全FF/全clockpair扩审。

BIT `reports/part_count_edge_keys_20261028/artifacts/StarEye_CountEdgeKeys.bit`，2549817字节，SHA256 `a1b3ad05a379a096c9bbcec1bf00c08c6a183002bf5c1bf4dc1d1fcb28c366fb`。原生BIT与交付BIT逐字绑定；11类实际数据库（数量以BIT_INPUTS为准）、源与基本STA绑定。

原始失败及日志保留：本机DLL启动限制、初次编译语法/声明、OSD字符串49→48字节纠正、OSD额外输入绑定补正。未改测试断言来获得PASS。开放轮廓仍可能漏计，调低可能增噪，不保证实物收益。未Git暂存/提交/推送，未DeepSeek B，未Programmer/JTAG/Flash；等待Work核定后交用户独立A，再由Work另行指定实物清单。
