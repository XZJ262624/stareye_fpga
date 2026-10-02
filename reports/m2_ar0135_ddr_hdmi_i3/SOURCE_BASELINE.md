# M2已编译源基线与当前工程状态

2026-10-03。用户已确认新I3镜像JTAG/实时取图/720p60/10～15分钟基础验收PASS；本说明区分对应编译源与后来再生成的工作副本。

## 已验证构建输入快照

[final_build/source_snapshot/Ti60_Demo.xml](final_build/source_snapshot/Ti60_Demo.xml)及同目录69个必要项目/业务RTL/IP输入文件，共2,689,858字节，逐一与final_build/build_input_after.json的SHA256匹配。缺失/变更的旧IP输入从厂商只读原件查找，只有哈希完全匹配才归档；没有覆盖当前工作副本，没有改写源码/版权声明，没有编译。

范围包含22项设计源、项目XML、接口/peri、实际I3 SDC和旧参考SDC、11项IP源码/参数与头文件/DDR初始化输入。排除厂商附带Testbench/devkit、IPM缓存及构建输出。DDR ddr3_controller.bin是小型IP初始化源码输入，需要保留，不能当下载bitstream排除。

快照记录见[SOURCE_BASELINE.json](SOURCE_BASELINE.json)。归档路径没有再次编译，快照证明输入字节身份；复现须使用安装版Efinity2025.1.110.5.9并先核对路径/工程配置。官方工具、安装器与许可缓存不入库。

## 当前工作副本

当前工程仍位于efinity/m2_ar0135_ddr_hdmi_i3，Ti60F225/I3、example_top、实际I3 SDC保持。22业务设计源、peri/SDC、DdrCtrl v5.14与W0_FIFO_8 v8.0匹配最终构建。当前GUI保存后的XML及其他IP有变化：CSI/DSI v5.14、其他FIFO v8.0及.v→.sv/ooc=false。完整差异清单见JSON，包含附带测试文件；这些未重新编译，不推测修改者，不自动把旧bit验收扩展为当前全部再生成输入验证。

提交保留当前工程必要文件和独立编译源快照，两者有明确用途；不进行隐式恢复/再生成，不修改现有业务RTL。用户反馈与下载原始日志/下载时哈希的证据层级见[ACCEPTANCE_REPORT.md](ACCEPTANCE_REPORT.md)。

bit仍2,137,974字节，SHA256 524213AA27C5797074E9BD71D0761EB31F9D09AEFAC825FA7201CAA6DD33940A；只记录身份，不提交文件。最终实现/报告绑定见[FINAL_IMPLEMENTATION_BINDING.md](FINAL_IMPLEMENTATION_BINDING.md)。
