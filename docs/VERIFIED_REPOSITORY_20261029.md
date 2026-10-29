# 星眸已验收工程与Git查询

仓库目录：`F:/Projects/stareye_fpga`。主开发分支：`codex/m5c-fusion-prototype`。本次验收标签：`stareye-count-edge-keys-20261029`。标签固定可调阈值工业计件版，后续HEAD变化时仍可查询。

| 功能 | 工程/产物入口 | 状态 |
|---|---|---|
| 工业螺丝计件、按键调阈值 | `efinity/part_count_edge_keys_i3/Ti60_Demo.xml`；`reports/part_count_edge_keys_20261028/artifacts/StarEye_CountEdgeKeys.bit` | 独立A PASS，2026-10-29用户反馈全部测试正常 |
| DDR短片回放＋圆/矩形识别 | `efinity/shape_replay_i3/Ti60_Demo.xml`；`reports/shape_replay_20261028/artifacts/StarEye_Shape_Replay.bit` | 2026-10-28用户反馈验收通过，提交38d7e42f |
| 双路Canny＋高斯历史独立版 | 查询提交433a83e5内工程和报告 | 已有历史提交，功能/阈值以其报告为准 |

本次源码、Efinity工程/IP与约束、实际使用的共用RTL、定向测试和软件参考依赖、指定BIT、原始报告及v2审查快照按精确清单归档。生产清单100项，XML55项源码入口已解析。快照304项/94207555B，manifest SHA d2a449a7b3e60bd7cec1b059a9904cdd91da970a3961b660eb05880389479fb1。用户私人照片、编辑示意图、安装工具和不相关工作区修改不属于本次交付；Git状态显示其他未提交资料不代表本版缺源。

## 常用查询（PowerShell）

```powershell
Set-Location 'F:\Projects\stareye_fpga'
git -c safe.directory=F:/Projects/stareye_fpga log --oneline -10
git -c safe.directory=F:/Projects/stareye_fpga show --stat stareye-count-edge-keys-20261029
git -c safe.directory=F:/Projects/stareye_fpga ls-tree -r --name-only stareye-count-edge-keys-20261029
git -c safe.directory=F:/Projects/stareye_fpga show stareye-count-edge-keys-20261029:reports/part_count_edge_keys_20261028/FINAL_CONFIGURATION.json
git -c safe.directory=F:/Projects/stareye_fpga status --short --untracked-files=no
```

第1条看提交历史；第2条看本次提交概览；第3条列完整版本文件；第4条查看阈值/按键配置；第5条只看跟踪文件修改，避免遍历大量历史生成物。也可以用编辑器Git历史界面查看这个标签。无需执行checkout覆盖现有工作区。

## 独立备份和恢复

离线完整Git备份在 `releases/StarEye_verified_20261029.bundle`，包含当前分支从起点至验收提交的Git历史以及验收标签，不只是源码ZIP。生成后使用`git bundle verify`核验；对应大小/SHA与提交身份存`releases/StarEye_verified_20261029_RECEIPT.json`。这些备份文件不再重复纳入Git自身。

恢复到一个尚不存在的新目录：

```powershell
git clone 'F:\Projects\stareye_fpga\releases\StarEye_verified_20261029.bundle' 'F:\Projects\stareye_fpga_restored'
git -C 'F:\Projects\stareye_fpga_restored' log -5 --oneline
```

工程依赖Efinity2025.1、适用Ti60F225的I3器件/IP支持，以及ModelSim（需要重跑仿真时）。厂商工具和许可证不打进仓库。现有脚本工具路径基于E:/Efinity/2025.1与E:/Modelsim_10.1c/win64，换机需安装并按实际位置配置。`prepare.py`/`implement.py`/`seal_review.py`是固定历史分叉/封存脚本，含身份和首次创建断言，不能对已存在工程盲目重放；正常入口为已保存XML和`run_tests.py`，复验输出新目录。

## 本次BIT与操作

BIT2549817B，SHA a1b3ad05a379a096c9bbcec1bf00c08c6a183002bf5c1bf4dc1d1fcb28c366fb。默认H48/L24；K1减8、K2加8，H8～128饱和、L为半值；双短RAW/MSK；双长重新布防诊断。阈值保存在当前配置内，断电/重新配置恢复默认。E4/E5/E9图像门保持关闭，原几何/容量/身份/TTL/三确认仍保留。有限模型及一次实物通过不扩大为暖复位、PVT或最坏DDR服务资格。用户未提供最佳阈值和观察时长，归档不补造。
