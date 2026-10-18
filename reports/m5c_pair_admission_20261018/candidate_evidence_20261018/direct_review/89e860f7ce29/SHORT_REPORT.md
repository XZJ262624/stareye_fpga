# latest-request 修复短门交接

功能修改仅 `rtl/m5c_pair_diag/m5c_pair_backend.sv`：UI及时ACK独立pair邮箱；保存最新完整64SID+valid，当前有效消息优先于缓存；选择须与真实fusion acquire session完整相等。原全部其余选择条件、fresh publication、8attempt、原display/TTL/身份/lease/排空、协议及像素capture不改。`backend.diff`/`SOURCE_CHANGE.json`含原字节与新SHA。资源增加65个逻辑寄存位及比较选择，实际映射尚未量测。

## 有限证据范围

- lifecycle_160429 两例新backend真实发布/lease/transfer/arbiter/type4 DONE→TAKE、正常pair封存与kill码3、已受理W背压32拍后真实B排空/释放及第二job发布。capture沿用原独立TB默认SEPARATE0，故这两例仅生命周期重新绑定，不替代生产资格生成证明。
- queue_v2_160916 case0：实际normal224bit和pair64bit邮箱、display_session/backend真实publication和lease。显式环境queue_hold模拟telemetry pending，旧SID7排队、最新SID12已到UI，旧acquire不select/arm/消耗fresh/attempt；环境模拟PIX旧offer的正常release，经真实session/cache/reader drain后，同pub的SID12实际select/ACK/arm、200×8完整pack5采集/B/meta/type4/type6..10及下一pub。显式SEPARATE1/eligible1模型、FIFO/reset观测；不是独立fusion_display产生eligible，也不是全720p。
- highsid_161341：旧7与0000000100000007低32相等，旧acquire被拒；新高64SID actualACK/arm成功后正常finish。高SID是控制刺激，未承诺完整age有效采集。
- sameedge_match_161124：缓存0000000100000007、实际acquire7，同拍UIvalid7优先，真实selected/ACK/arm。该同拍message通过明确backend UI输入模型注入，不force内部state，不声称mailbox相位穷尽。
- edges_v2_161319 case2：无任何pair请求时正常fusion acquire不得诊断选择；其后实际SID12消息与acquire完成同pub采集、真实排空和恢复。
- edges_v3：真实mailbox reset release后send/receive/take/缓存有效，再pair局部reset清valid；正常fusion无请求不select，随后12同pub完整恢复。case4缓存7但同拍UI新valid12与acquire7，优先新消息而拒旧acquire，后续12正常。以最终RESULT为准，不用报告提前赋PASS。
- queue_mutant_160747：仅删除 `pair_effective_request_session==pair_session&&`，逆变换原字节一致，compile0，actualbackend命中唯一 `LATEST_SID_STALE_ACQUIRE_SELECTED`，ModelSim rawexit0明确为expected Fatal，不当正向PASS。该负向继承param0 capture但在capture之前的错误选择当沿终止。

## 保留的失败与适用限制

queue_160619 case1、queue_v2_160916 case1、edges_161040 case2曾将人工4G高SID继续用于完整current，与真实reference低seq差超过120，原controller正确返回reason17，TB误期待完整成功而FAIL。原FAIL/输入不改；HIGH_SID_FIXTURE_FAILURE逐包CRC核精确17。修正版将高位相等测试限于真实arm，普通完整采集用合法SID12，不放宽TTL或修改descriptor。

edges_v2 case3的RESET_SETUP_NO_REQUEST@190ns是TB在邮箱异步reset释放前send，未建立待清缓存。v3等待真实source busy解除，完成send→ACK返回且显式检查cached valid后才拉局部reset；无内部force。原失败保留。

实例未接输出的ModelSim告警保留；并非完整DDR mask reader响应验证，reader aready/rvalid为0且由真实abort/drain生命周期释放。忙时中间请求可被源邮箱丢弃，latest只指UI实际观察到的最新消息，不等于即时PIX帧号。原近SOF/firsttap晚到安全拒绝仍允许。8attempt/terminal/stop/denial的未改控制器历史证据仍是原源有限继承，本次不称新增穷尽验证。原param1十二guard保留；后续远端完整真实视频和fresh物理必须绑定新backend，旧完整结果不能替代。

`SOFTWARE_WIRE_INTERIM.json`复用只读可信pack5严格decoder核实际新raw，明确test_sizes=(1600,512,512)几何豁免；不是生产fullsize数据。补充最终case软件核和所有输入/工具posthash写入SHORT_HANDBACK/manifest。不改schema，也不把日志字符串当唯一正确性证明。

后续参见NEXT_FREEZE_PLAN.md。当前无Git写入/硬件/本机长视频/新I3启动；旧candidate与bit不变。等待Work内部源冻结后继续新包和物理。
