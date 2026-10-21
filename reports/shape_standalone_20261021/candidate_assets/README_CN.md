本目录包含识别独立版候选准备的冻结测试数据及实际离线配置文件，尚未提交candidate、尚未开始独立审查、未获准实物测试。

`GOLD_MANIFEST.json`逐项列出727个真实依赖文件，原始合计1,656,828,989字节。`frozen_test_assets.zip`按路径排序、固定时间和文件模式、压缩级别6保存原字节；全部成员已实际解压到独立目录并核size/SHA，没有重算或调整黄金值。旧GAU V2其余源/用例/输出不属于此版资格。

`PRIMARY_SOURCE_MANIFEST.json`是91生产输入、13当前TB、10辅助文件的精确114项集合。它与资产包可在**全新、空的隔离仓库根**中恢复，禁止解包到现有工程或旧冻结包。使用安装的Python执行：

```
python scripts/shape_standalone/restore_candidate_assets_v1.py --destination <全新隔离目录> --probe100us
```

本轮已实际执行此命令的等价安装Python调用，114源/727gold真实恢复且100us编译PASS，收据见`MATERIALIZATION_AND_COMPILE100US.json`。该检查仅100us；完整72帧资格来自原先实际最终运行，未在此阶段重复。隔离后的当前入口为`<隔离目录>/scripts/shape_standalone/run_video.py`，完整视频需显式`--frames 72`；如审查者未运行，必须报告未运行。脚本写入仅隔离副本的运行输出，旧原件不变。

这里的727项闭合当前测试台实际读取的原始数据、gold、expected及oracle绑定。`oracle_sources/`另提供10份独立整数分类/空间模型、原始定义和案例来源代码的原字节只读副本，路径映射在`ORACLE_PROVENANCE.json`。这些来源生成脚本未在本阶段执行；某些历史脚本仍引用原目录，不能称它们具有独立的一键生成环境。不得为复现修改truth或expected。核104/356、components100/128、controls/OSD及负例的实际原始命令、PRE/POST、通过标记均可按candidate_evidence原路径索引查阅。

正式可打开工程为`efinity/shape_standalone_i3/Ti60_Demo.xml`。相对设计文件、11份IP设置及生成源在91项生产输入内。IP设置中的历史base_path是保留的生成元数据，未进行IP再生成；不能将旧路径当成本轮使用旧工程构建的证据。Efinity2025.1.110.5.9（含有效许可、加密IP支持）和ModelSim10.1c是外部安装工具，不随候选打包。完整DDR/hardPHY、实际传感器、I2C和TMDS电气不因仿真通过而成为实物资格。

`artifacts/Ti60_Demo.hex`是本轮在全新镜像中从已审计route LBF实际离线生成的ASCII HEX；同时保留工具实际输出的`Ti60_Demo.hex.bin`。`ARTIFACT_METADATA.json`记录两种文件的size/SHA/CRC、LBF SHA、源及STA回执和原始工具命令。HEX解码后与bin逐字节相同，载荷771158字节，载荷CRC32=94649cab。ASCII HEX文件的CRC与载荷CRC含义不同，不混用。没有执行program/USB/JTAG/Flash。配置文件存在不代表可以上板，必须先经Work固定candidate双独立审查及另一个实物放行节点。
