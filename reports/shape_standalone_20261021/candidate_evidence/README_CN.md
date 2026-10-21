这是本版离线资格的**完整可审文本证据集合**，所有对象保存原字节，不改历史FAIL、pending或撤销版。`SOURCE_TO_OBJECT_INDEX.json`将原路径逐项映射到`objects/<SHA256>.txt`；相同内容只保存一次，避免Windows深路径及重复数据。原生网表、所有原生STA路径报告、时钟/端点/metadata/RAM/DSP/CDC审计、PRE/POST、实际视频日志、修复因果和旧FAIL均按索引可读。

查原路径，例如：

```
python scripts/shape_standalone/read_candidate_evidence_v1.py --path reports/shape_standalone_20261021/FULL720P_FINAL_RECEIPT.json
```

从`OFFLINE_FINAL_RECEIPT.json`、`FULL720P_FINAL_RECEIPT.json`、`PHYSICAL_CLOSED_RECEIPT.json`、`SOURCE_MANIFEST.json`对应对象进入。最终物理根为`physical_recovery_v4_20261021_174108`。同目录最终`FINAL_PHYSICAL_RECEIPT.json`和`NATIVE_PRIMITIVE_CLOCK_COVERAGE_V3.json`才是闭合资格，早期`FULL_NATIVE_STA_EXECUTION_RECEIPT`的pending历史保留。v3约束集合序列化失败已撤销；原失败、修复、v4fresh结果同时保留，不用被撤销结果证明PASS。完整视频最终根`system720p_72_175528`，旧H48夹具失败根`system720p_72_173637`；最终明确一次真实H64→80事件，36是H80源帧数。

`EXCLUDED_DATABASE_REFERENCES.json`明确列出原生二进制DB、ModelSim库、work_pnr/work_syn/work_query及归档DB引用；这些对象只保存原始hash，不提供为“可审文本”，不冒称已在candidate。原完整3213条证据manifest也以原字节对象提供。此集合不能代替许可工具、原生DB或硬件环境；审查者没有运行的项目必须明示。

后续`SUPPLEMENTAL_OBJECT_INDEX.json`只新增本阶段实际离线生成、隔离解包/100us编译和新增支持脚本等证据，不修改旧索引或任何原3213文件。`COVERAGE_ASSERTIONS.json`给出关键范围的逐项存在与size/SHA核对。源代码作为主要候选文件独立可读；本索引的历史副本须按当时输入身份理解，不能用当前source SHA冒填早门。
