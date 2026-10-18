# Work：latest request修复的完整资格范围

本文件由Work核短门后激活，激活记录见同目录WORK_SHORT_GATE_DECISION.json。未激活前不得据本文件启动原生构建。

冻结身份：branch `codex/m5c-fusion-prototype`；HEAD `3c693037b79b4129856a2c43f2bcfe54ce18d623`，parent `711b802c8229544ded7f71905dcce16a3d57ac90`。当前WIP不是新candidate。唯一功能变化为`rtl/m5c_pair_diag/m5c_pair_backend.sv`，SHA-256 `25dc750eaa7ed216b58081986fb7a2ba1586bcdb0e63b09b944b695e295fbff1`。

Codex exec继续独占技术写入。按`implementation/NEXT_FREEZE_PLAN.md`新建隔离物理目录及远端V3包装目录，不覆盖任何历史失败、合格V2、物理数据库、bit或LATEST指针。Work负责检查和内部核定，普通内部步骤不等待用户重复授权。

## 本机构建

- 冻结107项当前构建输入及工具/脚本，逐一核对与旧合格输入关系；预期只backend发生功能变化，XML与11settings仅允许可逆路径元数据重定位。
- 必须fresh map；随后精确核实际选择器、资源、interface、place、route、完整STA和CDC/控制审计。XLR≤51680、RAM10≤204、DSP≤128，预算不放宽。
- 68组3790项与两项独立key_meta选择器区别记录。新增latest64/valid的实际D/CE/SR及局部reset均需覆盖；原held→接收域64位数据的5ns、hold和skew束缚不可漏绑。若优化发生合并或改名，提交原/新native结构与实际连线、精确目标清单及SDC差异给Work核定，再运行后续阶段；不得套旧alias、扩大falsepath或取消检查。
- 保留三继承PLL异步SR端点未计时、外部7输入/135输出、加密IP、冷重新配置恢复等边界。不能把normal STA通过写成全芯片无例外通过。
- 每阶段在后续原生工具覆盖前封存输入/输出、实际退出码/日志和hash；持久管理器必须真实启动并有可核进度，不能把计划描述为运行。

## 远端V3

- 以固定V2 manifest逐文件复制；63项模拟执行输入中仅backend应变化，其余62逐字节保持。完整TB、gold/oracle、ledger、service384/RT负载、921600像素、1152次current B及1次metadata B、CRC/BFS、真实释放和下一发布要求均保留。
- 新包/清单/runner身份必须版本化；ModelSim2020.4优化+acc，远端须先同包同工具compatibility再从time0完整运行，不继承V2收据。不迁移仿真进度，不在本机重复运行约两小时完整视频。
- 允许本机bounded编译/兼容检查；制作可直接交付ZIP、SHA、中文操作提示词与结果导出。不得打包用户capture、私人文件、密钥、工具安装包或不必要历史资料。外部电脑仍需用户实际转移并启动，不能宣称已远端执行。

## 停止边界

本次授权不含Git提交/暂存、bit转换、Programmer、串口打开、JTAG、SPI Active、Flash或新candidate外发。完整功能与物理证据到齐后交Work核定下一范围；正式固定candidate双独审、用户实物节点仍必须停止。远端需用户执行时交付具体包和操作步骤，同时继续可独立完成的本地构建。
