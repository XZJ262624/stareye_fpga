你是用户另一个可见会话的独立 Codex A，只读审查，不是实现者Astra或Work内部复核。

只读快照：F:/Projects/stareye_fpga/reports/canny_gaussian_standalone_fast_20261022/snapshot
清单：F:/Projects/stareye_fpga/reports/canny_gaussian_standalone_fast_20261022/snapshot/FROZEN_MANIFEST.json
清单SHA-256：cd13a3a60f10f3044f0800e136c1577ec9580fe91c652a12261595fb2210e4dd
branch codex/m5c-fusion-prototype；baseline HEAD b5f36414035193ab9c7aa8393732a93e10fe141e；parent 9dea12d9f0d29f57aa6d3acb75695da9e0d53d2c。
本轮尚未提交，candidate commit为无。五个新增目录在baseline中不存在；不得把快照冒称commit。来源差异见快照reports/canny_gaussian_standalone_fast_20261022/FOCUSED_TECHNICAL_DIFF.patch和DERIVATION_MANIFEST.json，指向已逐文件冻结的gaussian来源。

先核逐文件size/SHA与快照清单，再阅读DELIVERY_REPORT.md、真实编译闭包和必要原日志。只读快照，不审持续变化工作区，不修改/生成/暂存/提交，不运行Programmer、不下载、不写Flash、不调用B。允许只读Git确认baseline身份/目录不存在，不以外部工作区替代快照。

BIT reports/canny_gaussian_standalone_fast_20261022/artifacts/StarEye_Canny_Gaussian_Standalone.bit，2750379字节，SHA-256 8c0fb30e4b5f8f2fcad2eca27cf5945ff4bc3643aedfb915470a33c0c45550ed。冻结内有同路径副本。fresh新map/interface/place/route通过，XLR36322、RAM181、DSP1；normal I3 setup +0.161ns/hold +0.018ns，内部未约束0。短门、实际新backend取消恢复/首发布lease、42帧720p全SUT及2帧GAU融合逐坐标金模门通过，完整原日志在快照。不得将直供参考两帧门说成DDR，也不得把本轮结论外推为旧V1/V2全通过。

重点检查：
1. 去UART/pair后首次发布能直接被融合租用；STATS_WAIT、取消/timeout、已受理真实B/末R、writer/read lease/slot fencing没有被绕过或假ACK；保留命名含pair的租约仲裁是否必要且安全。
2. MED0–3/GAU4–6、SOF配置代际、源资格、TTL、行缓存与红局部/青新增坐标对齐；这里不是全七模式GAU或同算子A/B。SUT的cadence加速仅测试调度，非生产FPS保证。
3. 首STA -0.816ns失败与物理别名修复：逐一审462目的D真实驱动Q及canonical字段证明、257新增lease_identity源；只保持原5ns bundle约束/hold语义，不遗漏别名、不误纳其他异步数据、不泛化falsepath。核实际map/SDC/STA及保留失败原件，控制offer/held稳定/生命周期围栏仍成立。
4. 新实际I2C 3040/C000唯一写入且stream-enable前，OSD仅去PREV、方向未翻转；顶层管脚/时钟/分辨率保持。
5. 测试与BIT源绑定、原生XML只变运行元数据；基本STA继承PLL异步SR、外部7/135未约束、窄hold/PVT/暖复位限制，不能说成实物已通过。

输出问题表字段：严重程度、文件/位置、问题、证据、影响、建议。区分阻断、非阻断和已披露限制。最后结论只能PASS、PASS_WITH_FINDINGS或FAIL；给出审查快照manifestSHA和BIT SHA。审查结论交用户/Work，不自行推进硬件或Git。
