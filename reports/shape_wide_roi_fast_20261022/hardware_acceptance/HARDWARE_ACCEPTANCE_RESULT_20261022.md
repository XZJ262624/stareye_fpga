# 扩大ROI版实物验收归档（2026-10-22）

对象：未提交冻结快照，基线9dea12d9f0d29f57aa6d3acb75695da9e0d53d2c。
冻结MANIFEST SHA-256：fbe52d5807cdda0a770a8a54d22c53db76b799ffaf9c672761d48acd0b4c9c52。
BIT：reports/shape_wide_roi_fast_20261022/artifacts/StarEye_Shape_WideROI.bit，2312202字节。
SHA-256：7b92293979d8169e8f8ff77a65131cf2452699aea1929ab362fec616316b466a。

用户确认指定路径/SHA一致；相机/HDMI连接，JTAG临时配置，未SPI Active、未写Flash。约8秒出图。镜像方向、OSD及新绿色框正常。
H64/COV圆形3次、矩形3次（含较大目标及偏左偏右）均正常识别；旧框外、新框内位置正常识别；空白和三角形为UNKNOWN（负例次数未提供）。三模式、阈值及实时更新正常；连续观察5分钟，无黑屏、花屏、错列、冻结或重启。无照片或视频。

用户判断：通过。Work签收本次扩大ROI增量的受控实物验收通过，随后按快速流程提交归档。此记录不代表30分钟稳定性、抗条纹、旋转、跨PVT或暖复位能力；没有新增上述功能。
