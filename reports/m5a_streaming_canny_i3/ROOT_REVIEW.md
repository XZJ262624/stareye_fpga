# 主会话独立复核记录

## 历史离线独立复核（实物签收前）

2026-10-07。GPT-6 Astra / ultra完成架构、RTL、全套仿真、故障测试、完整Efinity构建和新STA；后续文档整理时达到额度限制，主会话接回写权限，完成最终24CLI重跑、总门禁、归档及独立范围审查。未声称剩余主会话工作由Astra执行。

主会话静态审查CE统一停顿、RAM地址/读写、窗口/帧支持、11位有符号梯度、19位方向比较、12位MAG、NMS中心方向、8邻域一跳无反馈、packet布局/6626拍对齐、原RAW保留、模式帧边界及OSD。用独立256个0/255核顶点枚举证明实际L1上界1530。实际HDL新库重编译测试、8370像素独立算法复核、最终STA原文Slack提取、20RTL故障/24CLI实际退出和源/报告/bit哈希校验均通过。

3,022保护文件及原1,550未跟踪资料保留；唯一旧M4临时锁缺失如实单列，未恢复或推测原因。暂存为空、HEAD不变。最终拟提交文件另见范围清单；不包括生成物、reference/tools或历史无关未跟踪资料。

结论：M5A流式局部Canny/Canny-lite离线开发、仿真、完整I3编译及最终已约束STA通过；实物待验收，不记录M5A最终实物PASS。 厂商AR0135参考链路继承的固定首行冻结异常保持DEFERRED，未定位、未修复，本轮未诊断或掩盖。+0.026 ns窄hold裕量、跨PVT未经严格证明、PLL异步复位/I/O约束/CDC、旧Flash流水灯冷启动及R3/R4共享风险继续保留。

机器证据：[ROOT_FINAL_REVIEW.json](ROOT_FINAL_REVIEW.json)、[ROOT_HDL_REVIEW.json](ROOT_HDL_REVIEW.json)、[总门禁](DELEGATE_FINAL_GATE.json)。

## 2026-10-07实物归档

M5A流式局部Canny/Canny-lite完成离线算法验证、完整I3编译、STA及实物功能验收，阶段PASS。 用户本次仅明确提供总体实物功能PASS；详见[实物验收报告](HARDWARE_ACCEPTANCE.md)。上述离线结论及机器JSON保持原生成时点含义，不能充当分项实物记录。当前厂商首行例外及范围以实物报告为准。主会话本轮对验收边界、文件范围、暂存blob与最终提交的独立复核见[ROOT_HARDWARE_ARCHIVE_REVIEW.md](ROOT_HARDWARE_ARCHIVE_REVIEW.md)，由主会话填写。
