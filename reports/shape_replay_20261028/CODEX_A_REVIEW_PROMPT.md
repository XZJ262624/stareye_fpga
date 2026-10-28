# 用户独立Codex A审查提示词

你是用户另一个可见Codex对话中的独立Codex A，只读审查星眸回放＋简易形状识别专用版。不要把Work内部检查视为独立A。基线branch `codex/m5c-fusion-prototype`、HEAD `433a83e543cb40a52128d1eea4ae32ce83aecd16`、parent `b5f36414035193ab9c7aa8393732a93e10fe141e`。本次尚未提交，没有candidate commit；只审已冻结快照，禁止审持续变化工作区。

冻结入口：`F:/Projects/stareye_fpga/reports/shape_replay_20261028/snapshot/FROZEN_MANIFEST.json`。
Manifest SHA-256：`229651c8328909af42f5dffc016d0aec7413597de26bc8e3be936e299f453774`。先逐文件核snapshot文件大小与SHA，并确认manifest中source/snapshot记录一致；source表示冻结时身份，无需读取活动工作区。所有审查读取限定snapshot/files。实际交付BIT `reports/shape_replay_20261028/artifacts/StarEye_Shape_Replay.bit`、2392110B、SHA `d69dae300d37b78eda2a9e9b3b722f5c5ec5d506a01a202226b96cfa3f774d81`。

先读快照内HANDOFF_SHAPE_REPLAY_20261028.md、DELIVERY_REPORT.md、VALIDATION_RESULT.json、OPERATING_NOTES.md；查新rtl/shape_replay、efinity/shape_replay_i3与明确父拷贝的差异。27依赖字节复用，原960×540/16px/80..440形状判据不改；不是计件或全局融合版。真实DDR录像32帧与新三视图/形状上下文是实际范围。

重点：1.真实末B+完整EOF登记、每4camera抽样与完整display4次消费、live/clip地址权限及只读lease；2.PLAY/PAUSE重复capture ID合法而displayseq独立，实际首DE的effective generation与原PREV撤旧、view2bit握手原子SOF应用；3.录制开始撤旧clip、取消不复活，旧clip在途读可排空但不得与重录写冲突；4.原Canny RAW0/CNY5/COV6及GAU2 H64/L32、原识别/完整性逐字复用，历史分类来自历史灰度而非当前camera；5.单级OSD/960×540框/头部不重叠；6.具体CF32小几何、父CF2和新CF3/CF1完整720p覆盖边界，失败夹具及补测闭合诚实；7.实际映射18组328精确CDC、Gray MSB经8888复位门而非虚构直连、同5ns/hold语义、原始STA/BIT/DB输入绑定。

另须重点审查CONTROL_FIX_RECORD.json：连续短按释放归零被覆盖的真实阻断、旧BIT作废、仅新控件的接受release优先guard及连续K1/K2/长短混合/阈值临界拍验证。旧未修控件父被保护而未回写，不能把其旧按键PASS说成覆盖本次缺陷。

禁止修改、暂存、提交、运行Programmer、下载、SPI Active或Flash；不要发送第二审查或任何外部服务。不得依据有限离线模型冒称512MiB/新增clip区物理认证、实际fps、PVT或暖复位。若发现问题，只报告证据与建议。

输出问题表列：严重程度、文件/位置、问题、证据、影响、建议。最终结论只能为PASS、PASS_WITH_FINDINGS或FAIL。审查后技术字节改变必须补审受影响差异。此提示词不放行硬件，用户返回A结果后由Work另行给指定BIT实物清单。
