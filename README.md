# 桌面便签 (Sticky Notes)

悬浮在桌面上的暖纸质感待办便签。单张便签窗口,可拖动、调大小、调透明度、勾选完成,带流畅动画。

## 技术栈

- Python 3.13
- PySide6 (Qt 6) + QML

## 功能

- 单张主便签,贴在桌面任意位置,位置和尺寸自动记忆
- 添加 / 勾选完成 / 删除待办事项
- 勾选完成时文字划线 + 淡出动画
- 新增待办滑入动画,删除时缩小消失
- 便签透明度可调 (55% ~ 100%)
- 拉边调整便签尺寸(宽 220~520,高 260~700)
- 待办显示添加/完成时间,可切换排序(按添加时间 / 完成时间)
- 关闭便签(✕)只隐藏窗口,数据永不丢失
- 系统托盘:双击或右键菜单显示便签 / 退出
- 数据存本地 SQLite,重启后恢复,历史数据自动合并到主便签

## 运行

```bash
pip install -r requirements.txt
python main.py
```

## 打包成 exe

```bash
pip install pyinstaller
pyinstaller --noconsole --name StickyNotes main.py
```

生成的可执行文件在 `dist/StickyNotes/`。

## 使用

- **拖动**:按住便签纸的空白处拖动
- **调整大小**:拉便签四边或四角
- **添加待办**:顶部输入框输入后回车,或点 "+"
- **完成待办**:点待办文字或圆形按钮
- **删除待办**:鼠标悬停在待办行,点右侧 "✕"
- **隐藏便签**:点右上角 "✕"(数据保留,托盘可重新显示)
- **透明度**:点左下角滑块图标弹出调节

## 目录结构

```
main.py              # 入口:QApplication + 托盘 + 加载便签
notes_cli.py         # 命令行接口,供 Agent 读写待办
app/
  store.py           # SQLite 数据层
  bridge.py          # Python <-> QML 桥接
  tray.py            # 系统托盘
  single_instance.py # 单实例限制
qml/
  StickyNote.qml     # 单张便签界面 + 动画
```

## 数据位置

便签数据保存在 `%APPDATA%/StickyNotes/notes.db`。

## 供 Agent 使用(Claude Code / Cline 等桌面 Agent)

桌面 Agent 可以通过 `notes_cli.py` 读取和修改待办事项,与便签程序实时同步。

```bash
python notes_cli.py list            # 查看未完成待办
python notes_cli.py list --all      # 查看全部待办(含已完成)
python notes_cli.py add "任务内容"   # 添加待办
python notes_cli.py done <id>       # 标记完成
python notes_cli.py undo <id>       # 标记未完成
python notes_cli.py delete <id>     # 删除待办
python notes_cli.py count           # 统计未完成/总数
python notes_cli.py path            # 打印数据库路径
```

给 Agent 的提示词建议:

> 我的待办事项在桌面便签里,数据库位于 `%APPDATA%/StickyNotes/notes.db`。
> 请通过 `python notes_cli.py list` 查看待办,用 `python notes_cli.py add "..."`、
> `done <id>`、`delete <id>` 来管理。完成后用 `python notes_cli.py list` 确认。
