# 扩大ROI增量封存

实物反馈见hardware_acceptance/HARDWARE_ACCEPTANCE_RESULT_20261022.md。生产工程efinity/shape_wide_roi_i3/Ti60_Demo.xml；BIT见artifacts/StarEye_Shape_WideROI.bit。
review_snapshot/MANIFEST.json为提交前历史冻结清单，candidate_commit=null准确反映当时状态；其original路径为本次提交包含或继承的实际文件，snapshot路径为本机历史审查副本，不重复加入Git。后续固定提交补审从Git blob导出original文件并重新核验，不依赖未提交副本。
范围：ROI960×540，目标边缘bbox80..440；没有细条纹抗扰。41项定向RTL、两帧720p adapter/recognizer/OSD及fresh构建/basic STA有效；没有重做完整DDR/GAU整机回归或全端点审计。原始失败与恢复日志保留。
