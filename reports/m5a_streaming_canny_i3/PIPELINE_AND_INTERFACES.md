# 模块、流水延迟与暂停协议

仅rtl/m5a_streaming_canny的新副本/模块被本工程使用，M2～M4原工程及共享核未修改。顶层example_top用同一个clk_pixel连接控制、流处理和OSD，三个ce均常1。独立模块测试可拉低ce，板载HDMI光栅不因算法测试而停钟。复位同步器保持真实时钟运行，算法状态在同步释放后按CE接受；不使用门控时钟实现停顿。

## 接口

| 模块 | 输入 | 输出/功能 |
|---|---|---|
| m5a_direction | signed11 gx,gy | 组合2位方向，明确19位移位加法 |
| m5a_neighborhood | clk/ce/rst_n/SOF/DE、参数BITS数据 | 两行同步RAM、9点窗口、中心坐标/有效 |
| m5a_nms | 中心MAG12、DIR2、支持位、光栅 | NMS12、完整支持、中心x/y |
| m5a_dual_threshold | NMS12、support、high8 | low8、strong、weak，组合分类 |
| m5a_local_hysteresis | support/strong/weak及光栅 | 局部Canny bit、完整支持、中心x/y |
| m5a_centered_sobel | 原RAW和同步/帧参数 | 58位旧模式包、正式端口MAG12/DIR2/支持，M4中心对齐 |
| m5a_stream_top | 原RAW8、DE/HS/VS/SOF、filter/high/mode、ce | RGB24、相同延迟光栅/坐标、RAW/旧MAG/BIN/OVR/NMS/Canny诊断输出 |
| m5a_colorize | 七模式及相同坐标数据 | 组合RGB888，红色ff0000 |
| m5a_controls | 原两键低有效、frame_start | 已生效及待提交mode3/high8 |
| m5a_osd | RGB和同步、mode3/high8、ce | 一拍后RGB及同步、模式/H/L文字 |

CE适配复用模块为line_buffer/window/median/median_stream/sobel/legacy_threshold/sobel_stream/m32_stream/packet_delay。fullMAG及DIR通过正式模块端口导出，不用可综合的层次引用。测试允许层次读观察端口以定位错误。

## 时延约定与实测

下表n为原像素在上升沿被采样的CE计数。跨模块采样边界已计入，不能把寄存器数量简单相加后漏掉一拍。

| 位置 | 原像素对应时刻（H=1650） |
|---|---|
| 中值窗口输入至核心输出 | 窗口2级+排序9级，原最新右下样本n→n+10；其中心是(x−1,y−1) |
| M32中值中心重锚包 | n+H+11 = n+1661 |
| 旧M32 slot/Sobel阈值出口 | n+H+16 = n+1666 |
| M4等价中心Sobel/原RAW包 | n+2H+17 = n+3317 |
| NMS中心包 | n+3H+21 = n+4971 |
| 局部连接/七模式组合RGB | n+4H+25 = n+6625 |
| OSD与HDMI像素输入 | n+4H+26 = n+6626 |

Sobel窗口/梯度/幅值/旧阈值共5个采样级：最新右下样本n→n+4。方向组合量化与幅值级同时采样，再随旧阈值一级，因此完整梯度及方向和旧Sobel出口同拍。NMS与连接分别两级窗口+一级比较/连接，最新右下样本n→n+2；中心在空间上回退一行一列，各自需要原packet额外H+4个CE拍。两个packet模块参数DELAY=H+3，跨模块输入采样再加1。双阈值与colorize为组合0级。

RAW/DE/HS/VS/模式/阈值/滤波标签/坐标统一最终延迟6626个CE拍，约89.059µs@74.4MHz。相对M4最终3318拍增加3308拍。小帧H280实测1146拍和完整720p实测6626拍均由测试逐拍同步/像素队列证实。

## 行缓存和实际RAM10映射

| 用途 | 逻辑尺寸 | 映射RAM10 |
|---|---|---:|
| 中值两行 | 2×1280×8 | 4 |
| 中值原RAW重锚包 | 1662×24 | 5 |
| Sobel两行 | 2×1280×8 | 4 |
| M4等价显示包 | 1651×56 | 12 |
| NMS两行 | 2×1280×15（support+dir+mag） | 6 |
| NMS中心包 | 1654×58 | 12 |
| 局部连接两行 | 2×1280×3（support/strong/weak） | 2 |
| 最终显示包 | 1654×67（加入NMS8/support） | 14 |

M4等价显示RAM实际存56位，输出时才组合加入同拍center_support/center_edge两位，形成58位接口；这两位不存于前一个56位RAM。原M4该RAM存54位，新版因独立保留MAG8/BIN1并将mode从2位扩至3位增加2位；该深度使用2048×5配置，54位需11块、56位需12块，与map.v实测一致。

算法新增空间窗口是NMS两行与连接两行；包含median/Sobel共8条逻辑图像行，没有整帧缓存。整机105个RAM10，其余46块来自原厂外围/FIFO。相对M4的70块，增加35=显示包扩展1+NMS行6+NMS包12+连接行2+最终包14。实际映射来源绑定map.v，不能用逻辑位数直接替代厂商物理块数量。

## 停顿、空白、帧与复位

ce=0时所有流水寄存器、同步/坐标/支持标签、行RAM读写、pending写地址/数据、packet地址/计数和重锚监视器一起保持；输出内容保持，消费者同样只在ce=1采样。ce=1且DE=0表示正常消隐，光栅packet和同步继续前进；DE低不能当作暂停。固定行周期以接受的CE拍计数。

连续活动WIDTH个像素、每行H_TOTAL个接受拍的协议保持。坏DE长度/行周期关闭中心边缘支持，下一VS边界重启。无SOF的复位后片段不能被重新编号为帧首。RAM不清零，ready/窗口支持域保证旧值不进入新帧边缘。非法DE洞和合法CE暂停分别测试，不把两者混称valid停顿。
