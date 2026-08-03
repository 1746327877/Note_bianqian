# 桌面便签 (Sticky Notes)

悬浮在桌面上的暖纸质感待办便签。多张独立便利贴,可拖动、调透明度、勾选完成,带流畅动画。

## 技术栈

- Python 3.13
- PySide6 (Qt 6) + QML

## 功能

- 多张独立便签,贴在桌面任意位置,位置自动记忆
- 添加 / 勾选完成 / 删除待办事项
- 勾选完成时文字划线 + 淡出 + 弹性动画
- 新增待办滑入动画,删除时缩小消失
- 便签透明度可调 (55% ~ 100%)
- 每张便签自动配色(纸色 + 胶带色)
- 系统托盘:双击新建便签,右键菜单新建 / 退出
- 数据存本地 SQLite,重启后恢复

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
- **添加待办**:顶部输入框输入后回车,或点 "+"
- **完成待办**:点待办文字或圆形按钮
- **删除待办**:鼠标悬停在待办行,点右侧 "✕"
- **删除便签**:点右上角 "✕"
- **透明度**:拖动便签底部滑块

## 目录结构

```
main.py              # 入口:QApplication + 托盘 + 加载便签
app/
  store.py           # SQLite 数据层
  bridge.py          # Python <-> QML 桥接
  tray.py            # 系统托盘
qml/
  StickyNote.qml     # 单张便签界面 + 动画
```

## 数据位置

便签数据保存在 `%APPDATA%/StickyNotes/notes.db`。
