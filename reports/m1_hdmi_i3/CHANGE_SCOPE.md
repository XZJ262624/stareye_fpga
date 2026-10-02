# M1变更范围

2026-10-02，当前拟提交完整清单、字节总量及最大文件以[COMMIT_SCOPE.md](COMMIT_SCOPE.md)为准。本轮独立M1提交已获用户授权；不使用git add .。

历史2026-10-01离线提案为76文件、713,377字节；该数字不代表加入实物验收与脚本整改后的当前范围。

当前包含项目状态/阶段/交接/资料文档、AR0135接线前资料预核查、英文HDMI工程10份源配置、M1脚本和选择的文本证据。原厂六份RTL不变，未修改PLL/管脚/SDC；主会话未重新编译/下载/Flash。

排除document、reference、tools、bit/hex、outflow/work/work_syn/work_pnr、锁/缓存/临时文件、安装器/驱动/PDF/视频及二进制数据库。既有.gitignore无需修改；隔离STA目录处于已有/efinity/**/work/规则之下，reports仍保留关键结果，不全局忽略log/rpt/bin/hex。
