# 合并版离线交付，待Work核定／用户独立A

Branch `codex/m5c-fusion-prototype`；基线HEAD `433a83e543cb40a52128d1eea4ae32ce83aecd16`，parent `b5f36414035193ab9c7aa8393732a93e10fe141e`。这是未提交冻结快照，没有candidate commit，暂存区为空。本轮未Git写入、未发送DeepSeek B、未操作硬件。

生产功能：LIVE／REC／PLAY／PAUSE＋原960×540 ROI的圆／轴对齐矩形／UNKNOWN识别；GAU2、H64/L32固定，RAW0／CNY5／COV6，默认COV。真实历史灰度通过同一识别链重新运算，capture ID可重复而display序号独立递增。真实首DE切换LIVE/clip上下文时同拍送next generation，撤旧PREV，不复位DDR或清队列。

录32完整720p灰度帧，每4camera抽1，每4完整display消费推进。payload29,491,200B，clip `[0x02000000,0x03FE1000)`内32个1MiB stride payload，live基址0/4/8/12MiB。约2.1秒采样动作、名义2.133秒回放循环；实际时长与地址物理资格仍待实物。

Fresh I3物理：19,768 XLR、106 RAM10、9 DSP，原始各200路径setup最小+0.183ns、hold最小+0.023ns。18组328精确端点，40条Gray经过8888复位AND门（最高位与binary同值），101条直接held mailbox字段含2bit视图；同7组5ns预算和对应hold语义，无clockwide falsepath。内部no_clock、unconstrained_internal_endpoints、multiple_clock均0。所有实际BIT输入DB绑定通过；XML只有运行元数据变化。

BIT `reports/shape_replay_20261028/artifacts/StarEye_Shape_Replay.bit`，2392110B，SHA-256 `d69dae300d37b78eda2a9e9b3b722f5c5ec5d506a01a202226b96cfa3f774d81`；原生和交付副本一致。

测试：原41条wideROI边界向量不改期望通过；新键控通过；新完整720p摄像→DDR→历史→GAU/Canny→adapter/分类/单级OSD验证独立gold与历史分类，覆盖圆、矩形、三角形UNKNOWN／三视图／暂停重复ID／循环／返回LIVE／重录；额外真实首DE上下文与旧clip在途读排空门通过。具体原始结果及覆盖不足补测关系以VALIDATION_RESULT.json为准，保留所有FAIL，不把未命中场景称RTL故障或通过。

复用未变回放11个PASS用例：CF32小几何控制／守卫／按键，6故障，CF2完整720p及四帧局部像素。原首组fault1夹具误拒冷hardstop、后组修正及历史TB精确SHA还原已披露。27关键生产拷贝与父逐字相同，所有父生产清单保护通过。未运行旧全局BFS／计件／72帧历史全量。

修复记录：旧控件接受释放时held清零被旧stable分支覆盖，连续短按累积成错误长按。Work定位后，最小复现第三次短按误发长按，旧完整联动主动停止；这是实际RTL阻断，不能说旧长例功能通过。只在新shape_replay控件加接受释放优先guard，bootstrap同修；K1九次短按、K2五次短按、两长按、混合序列与长阈值释放临界拍全部通过，并重跑受影响完整联动及fresh物理。旧5baf50e17cd9d5b6f7fd578147004c17ec260a3bb8bc1dc9089182020000f566 BIT明确SUPERSEDED_NOT_FOR_DELIVERY；旧原生日志/控件/物理输入保留，旧canny_replay父不回写。

限制：新结合版尚未外部A或上板；窄hold、外部7输入135输出、PLL异步SR、PVT、全容量与新增clip区实测、暖复位及真实最坏DDR服务均未获新资格。硬停沿用仅冷重新配置恢复且可撤销stalled WVALID的隔离边界。ModelSim有未使用输出端口警告，不能宣称零警告。操作详见OPERATING_NOTES.md。
