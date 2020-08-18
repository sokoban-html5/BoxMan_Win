# 推箱快手Windows版

## 版权说明

1. 本软件中的部分代码，采用或参考了网上的开源代码，在此表示感谢。
2. 本软件中使用到的图片素材来源于网络，版权归原作者所有。
3. 本软件中附带的关卡文件，版权归关卡原作者所有。

## 版本说明

### V2.1，2019-11-26
1. 即景菜单优化；
2. 快捷键方面的优化；
3. 其它优化。

### V2.0，2019-11-22

1. 修正因1.5版逆推坐标变化后导致的状态被重复保存的bug；
2. 修正数箱子时，仓管员在目标位被忽略的bug；
3. 修复正逆相合或逆推过关时，个别关卡会被误报的bug；
4. 完善“现场XSB”导出功能；
5. 修正没有打开关卡点击“动作编辑”按钮报错的bug；
6. 加载比赛关卡时，增加对第二副关的支持；
7. 其它优化。

### V1.9，2019-10-23

1. 打开新的关卡文档时，若后台的线程（打开关卡文档的线程）正忙，则强制停止改后台线程；
2. 增强字符串和日期时间的转换功能；
3. 优化关卡解析功能；
4. 整体优化。

### V1.8，2019-9-21

1. 有可达提示时，使用拖动光标，否则使用缺省光标；
2. 优化 Sqllie 数据库查询速度。

### V1.7，2019-9-11

1. 修复逆推过关时，错误拼接答案的bug；
2. 修复逆推状态处理时，计算人初始位置的bug；
3. 完善关卡文档解析算法；
4. 限制可达提示点的最小尺寸，以避免超大关卡时，提示点过小看不到；
5. 新增对启动参数的支持，启动参数为两个，前者为关卡文档名，后者为关序号；
6. 改用 Sqllie 数据库保存答案和状态；
7. 关卡编辑器和截图识别工具，与 BoxMan 打包在一起；
8. 增强了对即景模式下正逆相合的检查。

### V1.6，2019-8-30

1. 修正导出功能有时失效的bug；
2. 修正多次运行程序会报错的bug；
3. 其它优化。

### V1.5，2019-8-20

1. 增加导出全部关卡及答案的功能；
2. 修复逆推过关检查的bug；
3. 完善逆推动作导入导出时，人的定位坐标，左上角的由[0, 0]改为[1, 1]；
4. 完善动作动画处理代码；
5. 增强关卡打开功能，有答案自动加载第一个发现的答案，否则，若有状态保存，自动加载最新保存的状态；
6. 导入关卡加入周转库时，改追加到文档尾为插入到文档首;
7. 修正 Ctrl + Alt + M 不能正确导出“后续动作”的bug。

### V1.4，2019-8-1

1. 左侧边栏增设了“显示/隐藏”开关按钮；
2. 增强了地图的右键功能；
3. 修复了在没有关卡数据时，切换到“逆推模式”报错的bug；
4. 修复了因尚未开始比赛而加载不到关卡时，不能正确解析并提示的bug；
5. 修复了加载剪切板关卡后，不能正确进入浏览界面的bug；
6. 优化了滚轮操作；
7. 优化了动画相关代码；
8. 对文档打开相关操作进行了优化；
9. 优化寻径算法，减少内存申请，同时提升效率。

### V1.3，2019-7-15

1. 增加数箱子功能。【Ctrl + 拖动鼠标左键】可以增加选择区域，【Alt + 拖动鼠标左键】可以消减选择区域。同步统计被选区域中的箱子数、目标数、完成目标数；
2. 增加箱子编号、通道编码功能。双击箱子，可为箱子编号，编号仅支持 0--9；双击通道，可为通道编码，编号仅支持 A--Z；
3. 增加快速提取“寄存器”动作功能，F5--F8 分别对应“寄存器 1”--“寄存器 4”，当对应的“寄存器”中保存有动作时，用快键键可以快速提取出动作，并按关卡现场旋转状态，从现场当前点，立即执行 1 次提取到的动作；
4. 增加了选关快键，并有适当调换，同时为【上一关】、【下一关】、【撤销】、【重做】按钮，提供了右键功能；
5. 增加了动作录制功能；
6. 增加了“关卡周转库”功能，允许将剪切板导入的关卡或下载的比赛关卡快速保存到程序目录下的“BoxMan.xsb”文档。在“关卡周转库”中，程序会采用追加的方式，把关卡添加到文档尾部。需要注意的是，虽然添加时不限制文档中的关卡数量，但是，解析（打开）时，程序仅仅读出前100个关卡。注意，对于其它的关卡文档，保存时均采用“覆盖”方式；
7. 采用多线程方式加载关卡文档；
8. 增加窗口最小化或失去焦点时，暂停动画播放功能；
9. 完善功能和修复bug。

### V1.2，2019-7-5，至此版本，程序已完成游戏基本功能，包括：

1. 支持方向键和“点推”两种方式进行游戏；
2. 支持撤销、重做（动作限定在20万步以内）、穿越、瞬移、逆推、奇偶格特效、换肤及关卡旋转、图形选关等功能；
3. 支持答案的自动存档以及便捷的“状态”存取功能；
4. 支持关卡 XSB 和动作 Lurd 的导入导出，同时，具备了方便的动作编辑功能；
5. 支持推关卡时的“固定目标点”和“即景目标点”功能，以适应不同玩家需求；
6. 具备多种进退功能，以方便玩家进行不同形式的推演；
7. 对接“http://sokoban.cn”网站，方便比赛关卡的提取、答案的提交和答案列表的查看。